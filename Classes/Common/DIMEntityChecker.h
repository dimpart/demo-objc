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
//  DIMEntityChecker.h
//  DIMSDK
//
//  Created by Albert Moky on 2023/12/10.
//  Copyright © 2023 Albert Moky. All rights reserved.
//

#import <DIMClient/DIMAccountDBI.h>
#import <DIMClient/DIMCheckers.h>

NS_ASSUME_NONNULL_BEGIN

// each query will be expired after 10 minutes
#define DIMEntityChecker_QueryExpires 600.0 /* seconds */

/// each respond will be expired after 10 minutes
#define DIMEntityChecker_RespondExpires 600.0 /* seconds */

@interface DIMEntityChecker : NSObject

@property (readonly, strong, nonatomic) id<DIMAccountDBI> database;

- (instancetype)initWithDatabase:(id<DIMAccountDBI>)adb
NS_DESIGNATED_INITIALIZER;

@end

@interface DIMEntityChecker (Meta)

// protected
- (BOOL)isMetaQueryExpired:(id<MKMID>)ID;

/**
 *  Check meta for querying
 *
 * @param ID - entity ID
 * @param meta - exists meta
 * @return ture on querying
 */
- (BOOL)checkMeta:(nullable id<MKMMeta>)meta forID:(id<MKMID>)ID;

/**
 *  check whether need to query meta
 */
// protected
- (BOOL)needsQueryMeta:(nullable id<MKMMeta>)meta forID:(id<MKMID>)ID;

/**
 *  Request for meta with entity ID
 *  (call 'isMetaQueryExpired()' before sending command)
 *
 * @param ID - entity ID
 * @return false on duplicated
 */
- (BOOL)queryMetaForID:(id<MKMID>)ID;

@end

@interface DIMEntityChecker (Documents)

// protected
- (BOOL)isDocumentsQueryExpired:(id<MKMID>)ID;

// protected
- (BOOL)isDocumentResponseExpired:(id<MKMID>)ID forceUpdate:(BOOL)force;

/**
 *  Check documents for querying/updating
 *
 * @param ID - entity ID
 * @param docs - exist document
 * @return true on querying
 */
- (BOOL)checkDocuments:(NSArray<id<MKMDocument>> *)docs forID:(id<MKMID>)ID;

/**
 *  check whether need to query documents
 */
// protected
- (BOOL)needsQueryDocuments:(NSArray<id<MKMDocument>> *)docs forID:(id<MKMID>)ID;

/**
 *  Request for documents with entity ID
 *  (call 'isDocumentQueryExpired()' before sending command)
 *
 * @param ID - entity ID
 * @param docs - exist documents
 * @return false on duplicated
 */
- (BOOL)queryDocuments:(NSArray<id<MKMDocument>> *)docs forID:(id<MKMID>)ID;

@end

@interface DIMEntityChecker (Members)

// protected
- (BOOL)isMembersQueryExpired:(id<MKMID>)group;

/**
 *  Set last active member for group
 */
- (void)setLastActiveMember:(id<MKMID>)member group:(id<MKMID>)gid;

// protected
- (nullable id<MKMID>)getLastActiveMember:(id<MKMID>)gid;

/**
 *  Check group members for querying
 *
 * @param group - group ID
 * @param members - exist members
 * @return true on querying
 */
- (BOOL)checkMembers:(NSArray<id<MKMID>> *)members forID:(id<MKMID>)group;

/**
 *  check whether need to query group members
 */
// protected
- (BOOL)needsQueryMembers:(NSArray<id<MKMID>> *)members forID:(id<MKMID>)group;

/**
 *  Request for group members with group ID
 *  (call 'isMembersQueryExpired()' before sending command)
 *
 * @param group - group ID
 * @param members - exist members
 * @return false on duplicated
 */
- (BOOL)queryMembers:(NSArray<id<MKMID>> *)members forID:(id<MKMID>)group;

@end

@interface DIMEntityChecker (Time)

/**
 *  Update 'SDT' - Sender Document Time
 */
- (BOOL)setLastDocumentTime:(NSDate *)time forID:(id<MKMID>)ID;

// protected
- (nullable NSDate *)lastTimeOfDocuments:(NSArray<id<MKMDocument>> *)docs
                                   forID:(id<MKMID>)ID;

/**
 *  Update 'GHT' - Group History Time
 */
- (BOOL)setLastHistoryTime:(NSDate *)time forID:(id<MKMID>)group;

// protected
- (nullable NSDate *)lastTimeOfHistoryForID:(id<MKMID>)group;

@end

@interface DIMEntityChecker (Responding)

/**
 *  Send my visa document to contact
 *  if document is updated, force to send it again.
 *  else only send once every 10 minutes.
 */
- (BOOL)sendVisa:(id<MKMVisa>)visa receiver:(id<MKMID>)to updated:(BOOL)update;

@end

NS_ASSUME_NONNULL_END
