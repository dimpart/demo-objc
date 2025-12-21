// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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
//  DIMBot.m
//  DIMCore
//
//  Created by Albert Moky on 2019/9/4.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMAccountUtils.h"

#import "DIMBot.h"

@implementation DIMBot

/* designated initializer */
- (instancetype)initWithID:(id<MKMID>)did {
    NSAssert(did.type == MKMEntityType_Bot, @"bot ID error: %@", did);
    if (self = [super initWithID:did]) {
        //
    }
    return self;
}

// Override
- (id<MKMDocument>)profile {
    NSArray<id<MKMDocument>> *docs = [self documents];
    return DIMDocumentGetLast(docs, @"*");
}

// Override
- (id<MKMID>)provider {
    id<MKMDocument> doc = [self profile];
    if (doc) {
        id ICP = [doc propertyForKey:@"provider"];
        return MKMIDParse(ICP);
    }
    return nil;
}

@end
