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
//  DIMEntityChecker.m
//  DIMSDK
//
//  Created by Albert Moky on 2023/12/10.
//  Copyright © 2023 Albert Moky. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import "DIMAccountUtils.h"
#import "DIMCheckers.h"

#import "DIMEntityChecker.h"

static inline DIMFrequencyChecker *_query_checker(void) {
    return [[DIMFrequencyChecker alloc] initWithDuration:DIMEntityChecker_QueryExpires];
}

static inline DIMFrequencyChecker *_respond_checker(void) {
    return [[DIMFrequencyChecker alloc] initWithDuration:DIMEntityChecker_RespondExpires];
}

static inline DIMRecentTimeChecker *_time_checkers(void) {
    return [[DIMRecentTimeChecker alloc] init];
}

@interface DIMEntityChecker () {
    
    // query checkers
    DIMFrequencyChecker<id<MKMID>> *_metaQueries;
    DIMFrequencyChecker<id<MKMID>> *_docsQueries;
    DIMFrequencyChecker<id<MKMID>> *_membersQueries;
    
    // response checker
    DIMFrequencyChecker<id<MKMID>> *_visaResponses;
    
    // recent time checkers
    DIMRecentTimeChecker<id<MKMID>> *_lastDocumentTimes;
    DIMRecentTimeChecker<id<MKMID>> *_lastHistoryTimes;
    
    NSMutableDictionary<id<MKMID>, id<MKMID>> *_lastActiveMembers;
}

@property (strong, nonatomic) id<DIMAccountDBI> database;

@end

@implementation DIMEntityChecker

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    id<DIMAccountDBI> db = nil;
    return [self initWithDatabase:db];
}

/* designated initializer */
- (instancetype)initWithDatabase:(id<DIMAccountDBI>)adb {
    if (self = [super init]) {
        self.database = adb;
        
        _metaQueries    = _query_checker();
        _docsQueries    = _query_checker();
        _membersQueries = _query_checker();
        
        _visaResponses = _respond_checker();
        
        _lastDocumentTimes = _time_checkers();
        _lastHistoryTimes  = _time_checkers();
        
        _lastActiveMembers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

@end

@implementation DIMEntityChecker (Meta)

- (BOOL)isMetaQueryExpired:(id<MKMID>)did {
    return [_metaQueries isExpired:did time:nil];
}

- (BOOL)checkMeta:(nullable id<MKMMeta>)meta forID:(id<MKMID>)did {
    if ([self needsQueryMeta:meta forID:did]) {
        //if (![self isMetaQueryExpired:did]) {
        //    // query not expired yet
        //    return NO;
        //}
        return [self queryMetaForID:did];
    } else {
        // no need to query meta again
        return NO;
    }
}

- (BOOL)needsQueryMeta:(nullable id<MKMMeta>)meta forID:(id<MKMID>)did {
    if ([did isBroadcast]) {
        // broadcast entity has no meta to query
        return NO;
    } else if (!meta) {
        // meta not found, sure to query
        return YES;
    }
    NSAssert([DIMMetaUtils meta:meta matchID:did],
             @"meta not match: %@, %@", did, meta);
    return NO;
}

- (BOOL)queryMetaForID:(id<MKMID>)did {
    NSAssert(false, @"implement me!");
    return NO;
}

@end

@implementation DIMEntityChecker (Documents)

- (BOOL)isDocumentsQueryExpired:(id<MKMID>)did {
    return [_docsQueries isExpired:did time:nil];
}

- (BOOL)isDocumentResponseExpired:(id<MKMID>)did forceUpdate:(BOOL)force {
    return [_visaResponses isExpired:did time:nil force:force];
}

- (BOOL)checkDocuments:(NSArray<id<MKMDocument>> *)docs forID:(id<MKMID>)did {
    if ([self needsQueryDocuments:docs forID:did]) {
        //if (![self isDocumentsQueryExpired:did]) {
        //    // query not expired yet
        //    return NO;
        //}
        return [self queryDocuments:docs forID:did];
    } else {
        // no need to update documents now
        return NO;
    }
}

- (BOOL)needsQueryDocuments:(NSArray<id<MKMDocument>> *)docs forID:(id<MKMID>)did {
    if ([did isBroadcast]) {
        // boradcast entity has no document to query
        return NO;
    } else if ([docs count] == 0) {
        // documents not found, sure to query
        return YES;
    }
    NSDate *current = [self lastTimeOfDocuments:docs forID:did];
    return [_lastDocumentTimes isExpired:current forKey:did];
}

- (BOOL)queryDocuments:(NSArray<id<MKMDocument>> *)docs forID:(id<MKMID>)did {
    NSAssert(false, @"implement me!");
    return NO;
}

@end

@implementation DIMEntityChecker (Members)

- (BOOL)isMembersQueryExpired:(id<MKMID>)group {
    return [_membersQueries isExpired:group time:nil];
}

- (void)setLastActiveMember:(id<MKMID>)member forGroup:(id<MKMID>)gid {
    [_lastActiveMembers setObject:member forKey:gid];
}

- (nullable id<MKMID>)getLastActiveMemberForGroup:(id<MKMID>)gid {
    return [_lastActiveMembers objectForKey:gid];
}

- (BOOL)checkMembers:(NSArray<id<MKMID>> *)members forGroup:(id<MKMID>)group {
    if ([self needsQueryMembers:members forGroup:group]) {
        //if (![self isMembersQueryExpired:group]) {
        //    // query not expired yet
        //    return NO;
        //}
        return [self queryMembers:members forGroup:group];
    } else {
        // no need to update group members now
        return NO;
    }
}

- (BOOL)needsQueryMembers:(NSArray<id<MKMID>> *)members forGroup:(id<MKMID>)group {
    if ([group isBroadcast]) {
        // broadcast group has no members to query
        return NO;
    } else if ([members count] == 0) {
        // members not found, sure to query
        return YES;
    }
    NSDate *current = [self lastTimeOfHistoryForGroup:group];
    return [_lastHistoryTimes isExpired:current forKey:group];
}

- (BOOL)queryMembers:(NSArray<id<MKMID>> *)members forGroup:(id<MKMID>)group {
    NSAssert(false, @"implement me!");
    return NO;
}

@end

@implementation DIMEntityChecker (Time)

- (BOOL)setLastDocumentTime:(NSDate *)time forID:(id<MKMID>)did {
    return [_lastDocumentTimes setLastTime:time forKey:did];
}

- (NSDate *)lastTimeOfDocuments:(NSArray<id<MKMDocument>> *)docs
                          forID:(id<MKMID>)did {
    if ([docs count] == 0) {
        return nil;
    }
    NSDate *lastTime;
    NSDate *docTime;
    NSTimeInterval dt, lt = 0;
    for (id<MKMDocument> document in docs) {
        //NSAssert([document.identifier isEqual:did],
        //         @"document ID not match: %@, %@", did, document);
        docTime = [document time];
        dt = [docTime timeIntervalSince1970];
        if (dt < 1) {
            NSAssert(false, @"document error: %@", document);
        } else if (!lastTime || lt < dt) {
            lastTime = docTime;
            lt = dt;
        }
    }
    return lastTime;
}

- (BOOL)setLastHistoryTime:(NSDate *)time forGroup:(id<MKMID>)group {
    return [_lastHistoryTimes setLastTime:time forKey:group];
}

- (NSDate *)lastTimeOfHistoryForGroup:(id<MKMID>)group {
    NSAssert(false, @"implement me!");
    return nil;
}

@end

@implementation DIMEntityChecker (Responding)

- (BOOL)sendVisa:(id<MKMVisa>)visa receiver:(id<MKMID>)to updated:(BOOL)update {
    NSAssert(false, @"implement me!");
    return NO;
}

@end
