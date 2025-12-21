// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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
//  DIMServiceProvider.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMAccountUtils.h"
#import "DIMStation.h"

#import "DIMServiceProvider.h"

@implementation DIMServiceProvider

/* designated initializer */
- (instancetype)initWithID:(id<MKMID>)did {
    NSAssert(did.type == MKMEntityType_ISP, @"SP ID error: %@", did);
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
- (NSArray<id> *)stations {
    id<MKMDocument> doc = [self profile];
    if (doc) {
        id stations = [doc propertyForKey:@"stations"];
        if ([stations isKindOfClass:[NSArray class]]) {
            return stations;
        }
    }
    // TODO: load from local storage
    return nil;
}

@end

#pragma mark Comparison

static inline BOOL checkIdentifiers(id<MKMID> a, id<MKMID> b) {
    if (a == b) {
        // same object
        return YES;
    } else if ([a isBroadcast] || [b isBroadcast]) {
        return YES;
    }
    return [a isEqual:b];
}

static inline BOOL checkHosts(NSString *a, NSString *b) {
    if ([a length] == 0 || [b length] == 0) {
        return YES;
    }
    return [a isEqual:b];
}

static inline BOOL checkPorts(unsigned short a, unsigned short b) {
    if (a == 0 || b == 0) {
        return YES;
    }
    return a == b;
}

BOOL DIMSameStation(id<MKMStation> a, id<MKMStation> b) {
    if (a == b) {
        // same object
        return YES;
    }
    return checkIdentifiers([a identifier], [b identifier])
        && checkHosts([a host], [b host])
        && checkPorts([a port], [b port]);
}
