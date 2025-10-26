// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2025 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2025 Albert Moky
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
//  DIMCompressor.m
//  DIMClient
//
//  Created by Albert Moky on 2025/10/25.
//

#import "DIMCompatible.h"

#import "DIMCompressor.h"

static inline NSMutableDictionary *_mutable_dictionary(__kindof NSDictionary *dict) {
    if ([dict isKindOfClass:[NSMutableDictionary class]]) {
        return dict;
    } else {
        return [dict mutableCopy];
    }
}

@implementation DIMCompatibleCompressor

- (instancetype)init {
    id<DIMShortener> shortener = [[DIMCompatibleShortener alloc] init];
    if (self = [super initWithShortener:shortener]) {
        
    }
    return self;
}

//// Override
//- (NSData *)compressContent:(NSMutableDictionary *)content
//                    withKey:(NSDictionary *)pwd {
//    [DIMCompatibleOutgoing fixContent:content];
//    return [super compressContent:content withKey:pwd];
//}

// Override
- (NSDictionary *)extractContent:(NSData *)data withKey:(NSDictionary *)pwd {
    NSDictionary *content = [super extractContent:data withKey:pwd];
    if (content) {
        NSMutableDictionary *mDict = _mutable_dictionary(content);
        [DIMCompatibleIncoming fixContent:mDict];
        content = mDict;
    }
    return content;
}

@end

@implementation DIMCompatibleShortener

// Override
- (void)dictionary:(NSMutableDictionary *)dict
           moveKey:(NSString *)from
             toKey:(NSString *)to {
    id value = [dict objectForKey:from];
    if (value) {
        if ([dict objectForKey:to]) {
            NSAssert(false, @"keys conflicted: %@ -> %@, %@", from, to, dict);
            return;
        }
        [dict removeObjectForKey:from];
        [dict setObject:value forKey:to];
    }
}

// Override
- (NSMutableDictionary *)compressContent:(NSDictionary *)content {
    // DON'T COMPRESS NOW
    return _mutable_dictionary(content);
}

// Override
- (NSMutableDictionary *)compressSymmetricKey:(NSDictionary *)key {
    // DON'T COMPRESS NOW
    return _mutable_dictionary(key);
}

// Override
- (NSMutableDictionary *)compressReliableMessage:(NSDictionary *)msg {
    // DON'T COMPRESS NOW
    return _mutable_dictionary(msg);
}

@end
