// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2023 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2023 Albert Moky
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// =============================================================================
//
//  DIMCompatible.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/11.
//

#import <DIMSDK/DIMSDK.h>

#import "DIMMetaC.h"

#import "DIMCompatible.h"

@interface DIMCompatible (Extended)

/// 'type' <-> 'version'
+ (void)fixMetaVersion:(NSMutableDictionary *)meta;

/// 'ID' <-> 'did'
+ (NSDictionary *)fixDocument:(NSMutableDictionary *)document;

+ (void)fixCmd:(NSMutableDictionary *)content;

/// 'ID' <-> 'did'
+ (void)fixDid:(NSMutableDictionary *)content;

+ (void)fixFileContent:(NSMutableDictionary *)content;

@end

@implementation DIMCompatible

+ (void)fixMetaAttachment:(id<DKDReliableMessage>)rMsg {
    id meta = [rMsg objectForKey:@"meta"];
    if (!meta) {
        // meta not found
    } else if ([meta isKindOfClass:[NSMutableDictionary class]]) {
        [self fixMetaVersion:meta];
    } else if ([meta isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mDict = [meta mutableCopy];
        [self fixMetaVersion:mDict];
        [rMsg setObject:mDict forKey:@"meta"];
    } else {
        NSAssert(false, @"meta error: %@", meta);
    }
}

+ (void)fixVisaAttachment:(id<DKDReliableMessage>)rMsg {
    id visa = [rMsg objectForKey:@"visa"];
    if (!visa) {
        // visa not found
    } else if ([visa isKindOfClass:[NSMutableDictionary class]]) {
        [self fixDocument:visa];
    } else if ([visa isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mDict = [visa mutableCopy];
        [self fixDocument:mDict];
        [rMsg setObject:mDict forKey:@"visa"];
    } else {
        NSAssert(false, @"visa error: %@", visa);
    }
}

@end

@implementation DIMCompatible (Extended)

/// 'type' <-> 'version'
+ (void)fixMetaVersion:(NSMutableDictionary *)meta {
    id type = [meta objectForKey:@"type"];
    if (!type) {
        type = [meta objectForKey:@"version"];
    } else if ([meta objectForKey:@"algorithm"]) {
        // deprecated version
    } else if ([type isKindOfClass:[NSString class]]) {
        // TODO: check number
        if ([type length] > 2) {
            // TODO: check number
            [meta setObject:type forKey:@"algorithm"];
        }
    }
    UInt8 version = DIMMetaVersionParseInt(type, 0);
    if (version > 0) {
        [meta setValue:@(version) forKey:@"type"];
        [meta setValue:@(version) forKey:@"version"];
    }
}

/// 'ID' <-> 'did'
+ (NSDictionary *)fixDocument:(NSMutableDictionary *)document {
    [self fixDid:document];
    return document;
}

+ (void)fixCmd:(NSMutableDictionary *)content {
    NSString *cmd = [content objectForKey:@"command"];
    if ([cmd length] == 0) {
        // 'command' not exists, copy the value from 'cmd'
        cmd = [content objectForKey:@"cmd"];
        if (cmd) {
            [content setObject:cmd forKey:@"command"];
        } else {
            NSAssert(false, @"command error: %@", content);
        }
    } else if ([content objectForKey:@"cmd"]) {
        // these two values must be equal
        NSAssert([[content objectForKey:@"cmd"] isEqualToString:cmd], @"command error: %@", content);
    } else {
        // copy value from 'command' to 'cmd'
        [content setObject:cmd forKey:@"cmd"];
    }
}

/// 'ID' <-> 'did'
+ (void)fixDid:(NSMutableDictionary *)content {
    NSString *did = [content objectForKey:@"did"];
    if ([did length] == 0) {
        // 'did' not exists, copy the value from 'ID'
        did = [content objectForKey:@"ID"];
        if (did) {
            [content setObject:did forKey:@"did"];
        //} else {
        //    NSAssert(false, @"did not exists: %@", content);
        }
    } else if ([content objectForKey:@"ID"]) {
        // these two values must be equal
        NSAssert([[content objectForKey:@"ID"] isEqualToString:did], @"did error: %@", content);
    } else {
        // copy value from 'did' to 'ID'
        [content setObject:did forKey:@"ID"];
    }
}

+ (void)fixFileContent:(NSMutableDictionary *)content {
    id pwd = [content objectForKey:@"key"];
    if (pwd) {
        // Tarsier version > 1.3.7
        // DIM SDK version > 1.1.0
        [content setObject:pwd forKey:@"password"];
    } else {
        // Tarsier version <= 1.3.7
        // DIM SDK version <= 1.1.0
        pwd = [content objectForKey:@"password"];
        if (pwd) {
            [content setObject:pwd forKey:@"key"];
        }
    }
}

@end

#pragma mark -

static NSArray<NSString *> *s_file_types = nil;

static inline BOOL isFileType(NSString *type) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (s_file_types == nil) {
            s_file_types = @[
                DKDContentType_File, @"file",
                DKDContentType_Image, @"image",
                DKDContentType_Audio, @"audio",
                DKDContentType_Video, @"video",
            ];
        }
    });
    return [s_file_types containsObject:type];
}

@implementation DIMCompatibleIncoming

/// change 'type' value from string to int
+ (void)fixContent:(NSMutableDictionary *)content {
    // get content type
    NSString *type = MKConvertString([content objectForKey:@"type"], nil);
    
    if (isFileType(type)) {
        // 1. 'key' <-> 'password'
        [DIMCompatible fixFileContent:content];
        return;
    }
    
    if ([DKDContentType_NameCard isEqualToString:type]) {
        // 1. 'ID' <-> 'did'
        [DIMCompatible fixDid:content];
        return;
    }
    
    if ([DKDContentType_Command isEqualToString:type]) {
        // 1. 'cmd' <-> 'command'
        [DIMCompatible fixCmd:content];
    }
    //
    //  get command name
    //
    NSString *cmd = MKConvertString([content objectForKey:@"command"], nil);
    if ([cmd length] == 0) {
        return;
    }
    
    //if ([DKDCommand_Receipt isEqualToString:cmd]) {
    //    // pass
    //}
    
//    if ([DKDCommand_Login isEqualToString:cmd]) {
//        // 2. 'ID' <-> 'did'
//        [DIMCompatible fixDid:content];
//        return;
//    }
    
    if ([DKDCommand_Documents isEqualToString:cmd]) {
        // 2. cmd: 'document' -> 'documents'
        [self fixDocs:content];
    }
    
    if ([DKDCommand_Meta isEqualToString:cmd] ||
        [DKDCommand_Documents isEqualToString:cmd]) {
        // 3. 'ID' <-> 'did'
        [DIMCompatible fixDid:content];
        
        // 4. 'type' <-> 'version'
        id meta = [content objectForKey:@"meta"];
        if (!meta) {
            // meta not found
        } else if ([meta isKindOfClass:[NSMutableDictionary class]]) {
            [DIMCompatible fixMetaVersion:meta];
        } else if ([meta isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *mDict = [meta mutableCopy];
            [DIMCompatible fixMetaVersion:mDict];
            [content setObject:mDict forKey:@"meta"];
        } else {
            NSAssert(false, @"meta error: %@", meta);
        }
    }
}

// private
+ (void)fixDocs:(NSMutableDictionary *)content {
    // cmd: 'document' -> 'documents'
    NSString *cmd = [content objectForKey:@"command"];
    if ([@"document" isEqualToString:cmd]) {
        [content setObject:@"documents" forKey:@"command"];
    }
    // 'document' -> 'documents
    id doc = [content objectForKey:@"document"];
    if (doc) {
        [content setObject:@[
            [DIMCompatible fixDocument:[doc mutableCopy]]
        ] forKey:@"documents"];
        [content removeObjectForKey:@"document"];
    }
}

@end

#pragma mark -

@interface DIMCompatibleOutgoing (Extended)

/// change 'type' value from string to int
+ (void)fixType:(NSMutableDictionary *)content;

+ (void)fixReceiptCommand:(NSMutableDictionary *)content;

@end

@implementation DIMCompatibleOutgoing

+ (void)fixContent:(__kindof id<DKDContent>)content {
    // fix content type
    [self fixType:content.dictionary];
    
    if ([content conformsToProtocol:@protocol(DKDFileContent)]) {
        // 1. 'key' <-> 'password'
        [DIMCompatible fixFileContent:content.dictionary];
        return;
    }
    
    if ([content conformsToProtocol:@protocol(DKDNameCard)]) {
        // 1. 'ID' <-> 'did'
        [DIMCompatible fixDid:content.dictionary];
        return;
    }
    
    if ([content conformsToProtocol:@protocol(DKDCommand)]) {
        // 1. 'cmd' <-> 'command'
        [DIMCompatible fixCmd:content.dictionary];
    }
    
    if ([content conformsToProtocol:@protocol(DKDReceiptCommand)]) {
        // 2. check for v2.0
        [self fixReceiptCommand:content.dictionary];
        return;
    }
    
//    if ([content conformsToProtocol:@protocol(DKDLoginCommand)]) {
//        // 2. 'ID' <-> 'did'
//        [DIMCompatible fixDid:content.dictionary];
//        // 3. fix ststion
//        id station = [content objectForKey:@"station"];
//        // ...
//        
//        // 4. fix provider
//        id provider = [content objectForKey:@"provider"];
//        // ...
//        
//        return;
//    }
    
    if ([content conformsToProtocol:@protocol(DKDDocumentCommand)]) {
        // 2. cmd: 'documents' -> 'document'
        [self fixDocs:content];
    }
    
    if ([content conformsToProtocol:@protocol(DKDMetaCommand)]) {
        // 3. 'ID' <-> 'did'
        [DIMCompatible fixDid:content.dictionary];
        
        // 4. 'type' <-> 'version'
        id meta = [content objectForKey:@"meta"];
        if (!meta) {
            // meta not found
        } else if ([meta isKindOfClass:[NSMutableDictionary class]]) {
            [DIMCompatible fixMetaVersion:meta];
        } else if ([meta isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *mDict = [meta mutableCopy];
            [DIMCompatible fixMetaVersion:mDict];
            [content setObject:mDict forKey:@"meta"];
        } else {
            NSAssert(false, @"meta error: %@", meta);
        }
    }
}

// private
+ (void)fixDocs:(id<DKDDocumentCommand>)content {
    // cmd: 'documents' -> 'document'
    NSString *cmd = content.cmd;
    if ([DKDCommand_Documents isEqualToString:cmd]) {
        [content setObject:@"document" forKey:@"cmd"];
        [content setObject:@"document" forKey:@"command"];
    }
    // 'documents' -> 'document'
    NSArray *array = [content objectForKey:@"documents"];
    if (array) {
        NSArray *docs = MKMDocumentConvert(array);
        id<MKMDocument> last = [DIMDocumentUtils lastDocument:docs forType:nil];
        if (last) {
            id info = [DIMCompatible fixDocument:last.dictionary];
            [content setObject:info forKey:@"document"];
        }
        if ([docs count] == 1) {
            [content removeObjectForKey:@"documents"];
        }
    }
    id document = [content objectForKey:@"document"];
    if (!document) {
        // document not found
    } else if ([document isKindOfClass:[NSMutableDictionary class]]) {
        [DIMCompatible fixDid:document];
    } else if ([document isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mDict = [document mutableCopy];
        [DIMCompatible fixDid:mDict];
        [content setObject:mDict forKey:@"document"];
    } else {
        NSAssert(false, @"document error: %@", document);
    }
}

@end

@implementation DIMCompatibleOutgoing (Extended)

/// change 'type' value from string to int
+ (void)fixType:(NSMutableDictionary *)content {
    id type = [content objectForKey:@"type"];
    if ([type isKindOfClass:[NSString class]]) {
        UInt8 number = MKConvertUInt8(type, -1);
        if (number >= 0) {
            [content setObject:@(number) forKey:@"type"];
        }
    }
}

+ (void)fixReceiptCommand:(NSMutableDictionary *)content {
    // TODO: check for v2.0
}

@end
