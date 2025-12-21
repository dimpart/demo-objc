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
//  DIMAccountUtils.m
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMCore/Ext.h>

#import "DIMAccountUtils.h"

@implementation DIMMetaUtils

+ (BOOL)meta:(id<MKMMeta>)meta matchID:(id<MKMID>)did {
    NSAssert([meta isValid], @"meta not valid: %@", meta);
    // check ID.name
    NSString *seed = [meta seed];
    NSString *name = [did name];
    if ([name length] == 0) {
        if ([seed length] > 0) {
            return NO;
        }
    } else if ([name isEqualToString:seed]) {
        // OK
    } else {
        return NO;
    }
    // check ID.address
    id<MKMAddress> old = [did address];
    id<MKMAddress> gen = MKMAddressGenerate(meta, [old network]);
    return [old isEqual:gen];
}

+ (BOOL)meta:(id<MKMMeta>)meta matchPublicKey:(id<MKVerifyKey>)PK {
    NSAssert([meta isValid], @"meta not valid: %@", meta);
    if ([meta.publicKey isEqual:PK]) {
        return YES;
    }
    // check with seed & fingerprint
    NSString *seed = [meta seed];
    if ([seed length] == 0) {
        // NOTICE: ID with BTC/ETH address has no name, so
        //         just compare the key.data to check matching
        return NO;
    }
    NSData *fingerprint = [meta fingerprint];
    if ([fingerprint length] == 0) {
        // fingerprint should not be empty here
        return NO;
    }
    // check whether keys equal by verifying signature
    NSData *data = MKUTF8Encode(seed);
    return [PK verify:data withSignature:fingerprint];
}

@end

#pragma mark -

@implementation DIMDocumentUtils

+ (nullable NSString *)getDocumentType:(id<MKMDocument>)doc {
    MKMSharedAccountExtensions *ext = [MKMSharedAccountExtensions sharedInstance];
    return [ext.helper getDocumentType:doc.dictionary defaultValue:nil];
}

+ (BOOL)time:(nullable NSDate *)thisTime isBefore:(nullable NSDate *)oldTime {
    if (thisTime && oldTime) {
        //return [thisTime compare:oldTime] < 0;
    } else {
        return NO;
    }
    // check 'isBefore()'
    return [thisTime timeIntervalSince1970] < [oldTime timeIntervalSince1970];
}

+ (BOOL)timeIsExpired:(id<MKMDocument>)thisDoc compareTo:(id<MKMDocument>)oldDoc {
    return [self time:thisDoc.time isBefore:oldDoc.time];
}

+ (nullable id<MKMDocument>)lastDocument:(NSArray<id<MKMDocument>> *)documents
                                 forType:(nullable NSString *)type {
    if (!type || [type isEqualToString:@"*"]) {
        type = @"";
    }
    BOOL checkType = [type length] > 0;
    
    id<MKMDocument> last = nil;
    NSString *docType;
    BOOL matched;
    for (id<MKMDocument> doc in documents) {
        // 1. check type
        if (checkType) {
            docType = [self getDocumentType:doc];
            matched = [docType length] == 0 || [docType isEqualToString:type];
            if (!matched) {
                // type not matched, skip it
                continue;
            }
        }
        // 2. check time
        if (!last && [self timeIsExpired:doc compareTo:last]) {
            // skip expired document
            continue;
        }
        // got it
        last = doc;
    }
    return last;
}

+ (nullable id<MKMVisa>)lastVisa:(NSArray<id<MKMDocument>> *)documents {
    id<MKMVisa> last;
    bool matched;
    for (id doc in documents) {
        // 1. check type
        matched = [doc conformsToProtocol:@protocol(MKMVisa)];
        if (!matched) {
            // type not matched, skip it
            continue;
        }
        // 2. check time
        if (!last && [self timeIsExpired:doc compareTo:last]) {
            // skip expired document
            continue;
        }
        // got it
        last = doc;
    }
    return last;
}

+ (nullable id<MKMBulletin>)lastBulletin:(NSArray<id<MKMDocument>> *)documents {
    id<MKMBulletin> last;
    bool matched;
    for (id doc in documents) {
        // 1. check type
        matched = [doc conformsToProtocol:@protocol(MKMBulletin)];
        if (!matched) {
            // type not matched, skip it
            continue;
        }
        // 2. check time
        if (!last && [self timeIsExpired:doc compareTo:last]) {
            // skip expired document
            continue;
        }
        // got it
        last = doc;
    }
    return last;
}

@end
