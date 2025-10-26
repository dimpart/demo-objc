// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
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
//  DIMCheckers.m
//  DIMSDK
//
//  Created by Albert Moky on 2023/12/10.
//  Copyright © 2023 Albert Moky. All rights reserved.
//

#import "DIMCheckers.h"

@interface DIMFrequencyChecker () {
    
    NSMutableDictionary<NSString *, NSNumber *> *_records;
    NSTimeInterval _expires;
}

@end

@implementation DIMFrequencyChecker

- (instancetype)init {
    return [self initWithDuration:3600];
}

/* designated initializer */
- (instancetype)initWithDuration:(NSTimeInterval)lifeSpan {
    if (self = [super init]) {
        _records = [[NSMutableDictionary alloc] init];
        _expires = lifeSpan;
    }
    return self;
}

// private
- (BOOL)_forceExpired:(NSString *)key timestamp:(NSTimeInterval)now {
    [_records setObject:@(now + _expires) forKey:key];
    return YES;
}

// private
- (BOOL)_checkExpired:(NSString *)key timestamp:(NSTimeInterval)now {
    NSNumber *expired = [_records objectForKey:key];
    if (/*expired && */[expired doubleValue] > now) {
        // record exists and not expired yet
        return NO;
    }
    [_records setObject:@(now + _expires) forKey:key];
    return YES;
}

- (BOOL)isExpired:(NSString *)key time:(NSDate *)current force:(BOOL)update {
    if (!current) {
        current = [[NSDate alloc] init];
    }
    // if force == true:
    //     ignore last updated time, force to update now
    // else:
    //     check last update time
    if (update) {
        return [self _forceExpired:key timestamp:current.timeIntervalSince1970];
    } else {
        return [self _checkExpired:key timestamp:current.timeIntervalSince1970];
    }
}

- (BOOL)isExpired:(NSString *)key time:(NSDate *)current {
    return [self isExpired:key time:current force:NO];
}

@end

#pragma mark -

@interface DIMRecentTimeChecker () {
    
    NSMutableDictionary<NSString *, NSNumber *> *_times;
}

@end

@implementation DIMRecentTimeChecker

- (instancetype)init {
    if (self = [super init]) {
        _times = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (BOOL)setLastTime:(NSDate *)time forKey:(NSString *)key {
    if (!time) {
        NSAssert(false, @"recent time empty: %@", key);
        return NO;
    }
    return [self _setLastTime:time.timeIntervalSince1970 forKey:key];
}

// private
- (BOOL)_setLastTime:(NSTimeInterval)now forKey:(NSString *)key {
    NSNumber *last = [_times objectForKey:key];
    if (/* !last || */[last doubleValue] < now) {
        [_times setObject:@(now) forKey:key];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isExpired:(NSDate *)time forKey:(NSString *)key {
    if (!time) {
        NSAssert(false, @"recent time empty: %@", key);
        return YES;
    }
    return [self _isExpired:time.timeIntervalSince1970 forKey:key];
}

// private
- (BOOL)_isExpired:(NSTimeInterval)now forKey:(NSString *)key {
    NSNumber *last = [_times objectForKey:key];
    return /*last && */[last doubleValue] > now;
}

@end
