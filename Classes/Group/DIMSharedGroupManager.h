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
//  DIMSharedGroupManager.h
//  DIMClient
//
//  Created by Albert Moky on 2025/11/1.
//

#import <DIMClient/DIMGroupDelegate.h>
#import <DIMClient/DIMGroupEmitter.h>
#import <DIMClient/DIMGroupManager.h>
#import <DIMClient/DIMGroupAdminManager.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMSharedGroupManager : NSObject <MKMGroupDataSource>

@property (weak, nonatomic, nullable) DIMCommonFacebook *facebook;
@property (weak, nonatomic, nullable) DIMCommonMessenger *messenger;

@property (readonly, strong, nonatomic) DIMGroupDelegate *delegate;
@property (readonly, strong, nonatomic) DIMGroupManager *manager;
@property (readonly, strong, nonatomic) DIMGroupAdminManager *adminManager;
@property (readonly, strong, nonatomic) DIMGroupEmitter *emitter;

+ (instancetype)sharedInstance;

- (NSString *)buildGroupName:(NSArray<id<MKMID>> *)members;

- (BOOL)broadcastGroupDocument:(id<MKMBulletin>)doc;

/**
 *  Send group message
 */
- (id<DKDReliableMessage>)sendInstantMessage:(id<DKDInstantMessage>)iMsg
                                    priority:(NSInteger)prior;

- (BOOL)isOwner:(id<MKMID>)user group:(id<MKMID>)gid;

@end

@interface DIMSharedGroupManager (DataSource)

- (id<MKMBulletin>)getBulletin:(id<MKMID>)group;

- (NSArray<id<MKMID>> *)getAdministrators:(id<MKMID>)group;

/**
 *  Update 'administrators' in bulletin document
 */
- (BOOL)updateAdministrators:(NSArray<id<MKMID>> *)newAdmins group:(id<MKMID>)gid;

@end

@interface DIMSharedGroupManager (Management)

/**
 *  Create new group with members
 */
- (id<MKMID>)createGroup:(NSArray<id<MKMID>> *)members;

/**
 *  Reset group members
 */
- (BOOL)resetGroupMembers:(NSArray<id<MKMID>> *)newMembers group:(id<MKMID>)gid;

/**
 *  Expel members from this group
 */
- (BOOL)expelGroupMembers:(NSArray<id<MKMID>> *)expelMembers group:(id<MKMID>)gid;

/**
 *  Invite new members to this group
 */
- (BOOL)inviteGroupMembers:(NSArray<id<MKMID>> *)newMembers group:(id<MKMID>)gid;

/**
 *  Quit from this group
 */
- (BOOL)quitGroup:(id<MKMID>)gid;

@end

NS_ASSUME_NONNULL_END
