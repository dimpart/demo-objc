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
//  DIMDigestX.m
//  DIMClient
//
//  Created by Albert Moky on 2025/10/31.
//

#import <CommonCrypto/CommonDigest.h>

#import "DIMDigestX.h"

@implementation MKMD5

static id<MKMessageDigester> s_md5 = nil;

+ (void)setDigester:(nonnull id<MKMessageDigester>)hasher {
    s_md5 = hasher;
}

+ (nullable id<MKMessageDigester>)getDigester {
    return s_md5;
}

+ (nonnull NSData *)digest:(nonnull NSData *)data {
    NSAssert(s_md5, @"MD5 digester not set");
    return [s_md5 digest:data];
}

@end

@implementation MKSHA1

static id<MKMessageDigester> s_sha1 = nil;

+ (void)setDigester:(nonnull id<MKMessageDigester>)hasher {
    s_sha1 = hasher;
}

+ (nullable id<MKMessageDigester>)getDigester {
    return s_sha1;
}

+ (nonnull NSData *)digest:(nonnull NSData *)data {
    NSAssert(s_sha1, @"SHA-1 digester not set");
    return [s_sha1 digest:data];
}

@end

@implementation DIMMD5Digester

// Override
- (NSData *)digest:(NSData *)data {
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], digest);
    return [[NSData alloc] initWithBytes:digest length:CC_MD5_DIGEST_LENGTH];
}

@end

@implementation DIMSHA1Digester

// Override
- (NSData *)digest:(NSData *)data {
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1([data bytes], (CC_LONG)[data length], digest);
    return [[NSData alloc] initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}

@end
