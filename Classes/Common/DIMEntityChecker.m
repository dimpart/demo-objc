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

- (BOOL)isMetaQueryExpired:(id<MKMID>)ID {
    return [_metaQueries isExpired:ID time:nil];
}

- (BOOL)checkMeta:(nullable id<MKMMeta>)meta forID:(id<MKMID>)ID {
    if ([self needsQueryMeta:meta forID:ID]) {
        //if (![self isMetaQueryExpired:ID]) {
        //    // query not expired yet
        //    return NO;
        //}
        return [self queryMetaForID:ID];
    } else {
        // no need to query meta again
        return NO;
    }
}

- (BOOL)needsQueryMeta:(nullable id<MKMMeta>)meta forID:(id<MKMID>)ID {
    if ([ID isBroadcast]) {
        // broadcast entity has no meta to query
        return NO;
    } else if (!meta) {
        // meta not found, sure to query
        return YES;
    }
    NSAssert([DIMMetaUtils meta:meta matchIdentifier:ID],
             @"meta not match: %@, %@", ID, meta);
    return NO;
}

- (BOOL)queryMetaForID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return NO;
}

@end

@implementation DIMEntityChecker (Documents)

- (BOOL)isDocumentsQueryExpired:(id<MKMID>)ID {
    return [_docsQueries isExpired:ID time:nil];
}

- (BOOL)isDocumentResponseExpired:(id<MKMID>)ID forceUpdate:(BOOL)force {
    return [_visaResponses isExpired:ID time:nil force:force];
}

- (BOOL)checkDocuments:(NSArray<id<MKMDocument>> *)docs forID:(id<MKMID>)ID {
    if ([self needsQueryDocuments:docs forID:ID]) {
        //if (![self isDocumentsQueryExpired:ID]) {
        //    // query not expired yet
        //    return NO;
        //}
        return [self queryDocuments:docs forID:ID];
    } else {
        // no need to update documents now
        return NO;
    }
}

- (BOOL)needsQueryDocuments:(NSArray<id<MKMDocument>> *)docs forID:(id<MKMID>)ID {
    if ([ID isBroadcast]) {
        // boradcast entity has no document to query
        return NO;
    } else if ([docs count] == 0) {
        // documents not found, sure to query
        return YES;
    }
    NSDate *current = [self lastTimeOfDocuments:docs forID:ID];
    return [_lastDocumentTimes isExpired:current forKey:ID];
}

- (BOOL)queryDocuments:(NSArray<id<MKMDocument>> *)docs forID:(id<MKMID>)ID {
    NSAssert(false, @"implement me!");
    return NO;
}

@end

@implementation DIMEntityChecker (Members)

- (BOOL)isMembersQueryExpired:(id<MKMID>)group {
    return [_membersQueries isExpired:group time:nil];
}

- (void)setLastActiveMember:(id<MKMID>)member group:(id<MKMID>)gid {
    [_lastActiveMembers setObject:member forKey:gid];
}

- (nullable id<MKMID>)getLastActiveMember:(id<MKMID>)gid {
    return [_lastActiveMembers objectForKey:gid];
}

- (BOOL)checkMembers:(NSArray<id<MKMID>> *)members forID:(id<MKMID>)group {
    if ([self needsQueryMembers:members forID:group]) {
        //if (![self isMembersQueryExpired:group]) {
        //    // query not expired yet
        //    return NO;
        //}
        return [self queryMembers:members forID:group];
    } else {
        // no need to update group members now
        return NO;
    }
}

- (BOOL)needsQueryMembers:(NSArray<id<MKMID>> *)members forID:(id<MKMID>)group {
    if ([group isBroadcast]) {
        // broadcast group has no members to query
        return NO;
    } else if ([members count] == 0) {
        // members not found, sure to query
        return YES;
    }
    NSDate *current = [self lastTimeOfHistoryForID:group];
    return [_lastHistoryTimes isExpired:current forKey:group];
}

- (BOOL)queryMembers:(NSArray<id<MKMID>> *)members forID:(id<MKMID>)group {
    NSAssert(false, @"implement me!");
    return NO;
}

@end

@implementation DIMEntityChecker (Time)

- (BOOL)setLastDocumentTime:(NSDate *)time forID:(id<MKMID>)ID {
    return [_lastDocumentTimes setLastTime:time forKey:ID];
}

- (NSDate *)lastTimeOfDocuments:(NSArray<id<MKMDocument>> *)docs forID:(id<MKMID>)ID {
    if ([docs count] == 0) {
        return nil;
    }
    NSDate *lastTime;
    NSDate *docTime;
    NSTimeInterval dt, lt = 0;
    for (id<MKMDocument> document in docs) {
        NSAssert([document.identifier isEqual:ID],
                 @"document ID not match: %@, %@", ID, document);
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

- (BOOL)setLastHistoryTime:(NSDate *)time forID:(id<MKMID>)group {
    return [_lastHistoryTimes setLastTime:time forKey:group];
}

- (NSDate *)lastTimeOfHistoryForID:(id<MKMID>)group {
    NSAssert(false, @"implement me!");
    return nil;
}

@end

@implementation DIMEntityChecker (Responding)

- (BOOL)sendVisa:(nonnull id<MKMVisa>)visa receiver:(nonnull id<MKMID>)to updated:(BOOL)update {
    NSAssert(false, @"implement me!");
    return NO;
}

@end
