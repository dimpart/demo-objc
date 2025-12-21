// license: https://mit-license.org
//
//  Dao-Ke-Dao: Universal Message Module
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
//  DIMMessageUtils.m
//  DIMSDK
//
//  Created by Albert Moky on 2025/10/11.
//  Copyright © 2025 Albert Moky. All rights reserved.
//

#import "DIMMessageUtils.h"

@implementation DIMMessageUtils

+ (id<MKMMeta>)metaInMessage:(id<DKDMessage>)msg {
    id meta = [msg objectForKey:@"meta"];
    return MKMMetaParse(meta);
}

+ (void)message:(id<DKDMessage>)msg setMeta:(id<MKMMeta>)meta {
    [msg setDictionary:meta forKey:@"meta"];
}

+ (id<MKMVisa>)visaInMessage:(id<DKDMessage>)msg {
    id visa = [msg objectForKey:@"visa"];
    id doc = MKMDocumentParse(visa);
    if ([doc conformsToProtocol:@protocol(MKMVisa)]) {
        return doc;
    }
    NSAssert(doc == nil, @"visa document error: %@", doc);
    return nil;
}

+ (void)message:(id<DKDMessage>)msg setVisa:(id<MKMVisa>)visa {
    [msg setDictionary:visa forKey:@"visa"];
}

@end
