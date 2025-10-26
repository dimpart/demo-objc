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
//  DIMCache.m
//  DIMClient
//
//  Created by Albert Moky on 2025/10/25.
//

#import "DIMCache.h"

@interface DIMThanosCache () {
    
    NSMutableDictionary *_caches;
}

@end

@implementation DIMThanosCache

- (instancetype)init {
    if (self = [super init]) {
        _caches = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (nullable id)objectForKey:(NSString *)aKey {
    return [_caches objectForKey:aKey];
}

- (void)setObject:(id)anObject forKey:(NSString *)aKey {
    [_caches setObject:anObject forKey:aKey];
}

- (NSUInteger)reduceMemory {
    NSUInteger snap = 0;
    snap = DIMThanos(_caches, snap);
    return snap;
}

@end

NSUInteger DIMThanos(NSMutableDictionary *planet, NSUInteger finger) {
    NSArray *people = [planet allKeys];
    // if ++finger is odd, remove it,
    // else, let it go
    for (id key in people) {
        if ((++finger & 1) == 1) {
            // kill it
            [planet removeObjectForKey:key];
        }
        // let it go
    }
    return finger;
}
