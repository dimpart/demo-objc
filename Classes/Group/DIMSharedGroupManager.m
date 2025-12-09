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
//  DIMSharedGroupManager.m
//  DIMClient
//
//  Created by Albert Moky on 2025/11/1.
//

#import "DIMSharedGroupManager.h"

@interface DIMSharedGroupManager () {
    
    __weak DIMCommonFacebook *_barrack;
    __weak DIMCommonMessenger *_transceiver;
    
    DIMGroupDelegate *_delegate;
    DIMGroupManager *_manager;
    DIMGroupAdminManager *_adminManager;
    DIMGroupEmitter *_emitter;
}

@end

@implementation DIMSharedGroupManager

static DIMSharedGroupManager *s_grp_man = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_grp_man = [[self alloc] init];
    });
    return s_grp_man;
}

- (instancetype)init {
    if (self = [super init]) {
        _barrack = nil;
        _transceiver = nil;
        
        _delegate = nil;
        _manager = nil;
        _adminManager = nil;
        _emitter = nil;
    }
    return self;
}

- (DIMCommonFacebook *)facebook {
    return _barrack;
}

- (DIMCommonMessenger *)messenger {
    return _transceiver;
}

- (void)setFacebook:(DIMCommonFacebook *)facebook {
    _barrack = facebook;
    [self _clearDelegates];
}

- (void)setMessenger:(DIMCommonMessenger *)messenger {
    _transceiver = messenger;
    [self _clearDelegates];
}

- (void)_clearDelegates {
    _delegate = nil;
    _manager = nil;
    _adminManager = nil;
    _emitter = nil;
}

- (DIMGroupDelegate *)delegate {
    DIMGroupDelegate *proxy = _delegate;
    if (!proxy) {
        proxy = [[DIMGroupDelegate alloc] initWithFacebook:_barrack
                                                 messenger:_transceiver];
        _delegate = proxy;
    }
    return proxy;
}

- (DIMGroupManager *)manager {
    DIMGroupManager *proxy = _manager;
    if (!proxy) {
        DIMGroupDelegate *delegate = [self delegate];
        proxy = [[DIMGroupManager alloc] initWithDelegate:delegate];
        _manager = proxy;
    }
    return proxy;
}

- (DIMGroupAdminManager *)adminManager {
    DIMGroupAdminManager *proxy = _adminManager;
    if (!proxy) {
        DIMGroupDelegate *delegate = [self delegate];
        proxy = [[DIMGroupAdminManager alloc] initWithDelegate:delegate];
        _adminManager = proxy;
    }
    return proxy;
}

- (DIMGroupEmitter *)emitter {
    DIMGroupEmitter *proxy = _emitter;
    if (!proxy) {
        DIMGroupDelegate *delegate = [self delegate];
        proxy = [[DIMGroupEmitter alloc] initWithDelegate:delegate];
        _emitter = proxy;
    }
    return proxy;
}

- (NSString *)buildGroupName:(NSArray<id<MKMID>> *)members {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate buildGroupNameWithMembers:members];
}

- (BOOL)broadcastGroupDocument:(id<MKMBulletin>)doc {
    DIMGroupAdminManager *manager = [self adminManager];
    return [manager broadcastGroupDocument:doc];
}

- (id<DKDReliableMessage>)sendInstantMessage:(id<DKDInstantMessage>)iMsg
                                    priority:(NSInteger)prior {
    NSAssert(iMsg.content.group, @"group message error: %@", iMsg);
    [iMsg setObject:@(YES) forKey:@"GF"];
    DIMGroupEmitter *emitter = [self emitter];
    return [emitter sendInstantMessage:iMsg priority:prior];
}

- (BOOL)isOwner:(id<MKMID>)user group:(id<MKMID>)gid {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate isOwner:user group:gid];
}

#pragma mark Entity DataSource

- (id<MKMMeta>)metaForID:(id<MKMID>)did {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate metaForID:did];
}

- (NSArray<id<MKMDocument>> *)documentsForID:(id<MKMID>)did {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate documentsForID:did];
}

#pragma mark Group DataSource

- (id<MKMID>)founderOfGroup:(id<MKMID>)group {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate founderOfGroup:group];
}

- (id<MKMID>)ownerOfGroup:(id<MKMID>)group {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate ownerOfGroup:group];
}

- (NSArray<id<MKMID>> *)assistantsOfGroup:(id<MKMID>)group {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate assistantsOfGroup:group];
}

- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate membersOfGroup:group];
}

@end

@implementation DIMSharedGroupManager (DataSource)

- (id<MKMBulletin>)bulletinForID:(id<MKMID>)group {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate bulletinForID:group];
}

- (NSArray<id<MKMID>> *)administratorsOfGroup:(id<MKMID>)group {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate administratorsOfGroup:group];
}

- (BOOL)updateAdministrators:(NSArray<id<MKMID>> *)newAdmins group:(id<MKMID>)gid {
    DIMGroupAdminManager *manager = [self adminManager];
    return [manager updateAdministrators:newAdmins group:gid];
}

@end

@implementation DIMSharedGroupManager (Management)

- (id<MKMID>)createGroup:(NSArray<id<MKMID>> *)members {
    DIMGroupManager *manager = [self manager];
    return [manager createGroupWithMembers:members];
}

- (BOOL)resetGroupMembers:(NSArray<id<MKMID>> *)newMembers group:(id<MKMID>)gid {
    DIMGroupManager *manager = [self manager];
    return [manager resetMembers:newMembers group:gid];
}

- (BOOL)expelGroupMembers:(NSArray<id<MKMID>> *)expelMembers group:(id<MKMID>)gid {
    NSAssert([gid isGroup] && [expelMembers count] > 0, @"params error: %@, %@", gid, expelMembers);
    DIMCommonFacebook *facebook = [self facebook];
    
    id<MKMUser> user = [facebook currentUser];
    if (!user) {
        NSAssert(false, @"failed to get current user");
        return NO;
    }
    id<MKMID> me = [user identifier];
    DIMGroupDelegate *delegate = [self delegate];
    
    NSArray<id<MKMID>> *oldMembers = [delegate membersOfGroup:gid];
    BOOL isOwner = [delegate isOwner:me group:gid];
    bool isAdmin = [delegate isAdministrator:me group:gid];
    
    // check permission
    BOOL canReset = isOwner || isAdmin;
    if (canReset) {
        // You are the owner/admin, then
        // remove the members and 'reset' the group
        NSMutableArray<id<MKMID>> *members = [oldMembers mutableCopy];
        [members removeObjectsInArray:expelMembers];
        return [self resetGroupMembers:members group:gid];
    }
    
    NSAssert(false, @"Cannot expel members from group: %@", gid);
    return NO;
}

- (BOOL)inviteGroupMembers:(NSArray<id<MKMID>> *)newMembers group:(id<MKMID>)gid {
    DIMGroupManager *manager = [self manager];
    return [manager inviteMembers:newMembers group:gid];
}

- (BOOL)quitGroup:(id<MKMID>)gid {
    DIMGroupManager *manager = [self manager];
    return [manager quitGroup:gid];
}

@end
