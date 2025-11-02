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
//  DIMClientFacebook.m
//  DIMClient
//
//  Created by Albert Moky on 2023/3/13.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMPlugins/Loader.h>

#import "DIMBroadcastUtils.h"
#import "MKMAnonymous.h"
#import "DIMRegister.h"
#import "DIMGroupManager.h"

#import "DIMCommonArchivist.h"

#import "DIMClientFacebook.h"

@implementation DIMClientFacebook

//
//  GroupDataSource
//

- (id<MKMID>)getFounder:(id<MKMID>)group {
    NSAssert([group isGroup], @"group ID error: %@", group);
    // check broadcast group
    if ([group isBroadcast]) {
        // founder of broadcast group
        return [DIMBroadcastUtils broadcastFounder:group];
    }
    // check bulletin document
    id<MKMBulletin> doc = [self getBulletin:group];
    if (!doc) {
        // the owner(founder) should be set in the bulletin document of group
        return nil;
    }
    // check local storage
    id<DIMAccountDBI> db = [self database];
    id<MKMID> user = [db founderOfGroup:group];
    if (user) {
        // got from local storage
        return user;
    }
    // get from bulletin document
    user = [doc founder];
    NSAssert(user, @"founder not designated for group: %@", group);
    return user;
}

- (id<MKMID>)getOwner:(id<MKMID>)group {
    NSAssert([group isGroup], @"group ID error: %@", group);
    // check broadcast group
    if ([group isBroadcast]) {
        // founder of broadcast group
        return [DIMBroadcastUtils broadcastOwner:group];
    }
    // check bulletin document
    id<MKMBulletin> doc = [self getBulletin:group];
    if (!doc) {
        // the owner(founder) should be set in the bulletin document of group
        return nil;
    }
    // check local storage
    id<DIMAccountDBI> db = [self database];
    id<MKMID> user = [db ownerOfGroup:group];
    if (user) {
        // got from local storage
        return user;
    }
    // check group type
    if ([group type] == MKMEntityType_Group) {
        // Polylogue owner is its founder
        user = [db founderOfGroup:group];
        if (!user) {
            user = [doc founder];
        }
    }
    NSAssert(user, @"owner not found for group: %@", group);
    return user;
}

- (NSArray<id<MKMID>> *)getMembers:(id<MKMID>)group {
    NSAssert([group isGroup], @"group ID error: %@", group);
    // check broadcast group
    if ([group isBroadcast]) {
        // founder of broadcast group
        return [DIMBroadcastUtils broadcastMembers:group];
    }
    id<MKMID> owner = [self getOwner:group];
    if (!owner) {
        //NSAssert(false, @"group owner not found: %@", group);
        return nil;
    }
    // check local storage
    id<DIMAccountDBI> db = [self database];
    NSArray<id<MKMID>> *members = [db membersOfGroup:group];
    DIMEntityChecker *checker = [self entityChecker];
    [checker checkMembers:members forID:group];
    if ([members count] == 0) {
        members = @[owner];
    } else {
        NSAssert([members.firstObject isEqual:owner], @"group owner must be the first member: %@", group);
    }
    return members;
}

- (NSArray<id<MKMID>> *)getAssistants:(id<MKMID>)group {
    NSAssert([group isGroup], @"group ID error: %@", group);
    // check bulletin document
    id<MKMBulletin> doc = [self getBulletin:group];
    if (!doc) {
        // the assistants should be set in the bulletin document of group
        return nil;
    }
    // check local storage
    id<DIMAccountDBI> db = [self database];
    NSArray<id<MKMID>> *bots = [db assistantsOfGroup:group];
    if ([bots count] > 0) {
        return bots;
    }
    // get from bulletin document
    return [doc assistants];
}

//
//  Organizational Structure
//

- (NSArray<id<MKMID>> *)getAdministrators:(id<MKMID>)group {
    NSAssert([group isGroup], @"group ID error: %@", group);
    // check bulletin document
    id<MKMBulletin> doc = [self getBulletin:group];
    if (!doc) {
        // the administrators should be set in the bulletin document of group
        return nil;
    }
    // the 'administrators' should be saved into local storage
    // when the newest bulletin document received,
    // so we must get them from the local storage only,
    // not from the bulletin document.
    id<DIMAccountDBI> db = [self database];
    return [db administratorsOfGroup:group];
}

- (BOOL)saveAdministrators:(NSArray<id<MKMID>> *)admins group:(id<MKMID>)gid {
    id<DIMAccountDBI> db = [self database];
    return [db saveAdministrators:admins group:gid];
}

- (BOOL)saveMembers:(NSArray<id<MKMID>> *)newMembers group:(id<MKMID>)gid {
    id<DIMAccountDBI> db = [self database];
    return [db saveMembers:newMembers group:gid];
}

@end

#pragma mark - ANS

static DIMAddressNameServer *_ans = nil;
static id<MKMIDFactory> _idFactory = nil;

@interface IDFactory : NSObject <MKMIDFactory>

@end

@implementation IDFactory

- (nonnull id<MKMID>)createIdentifierWithName:(NSString *)name
                                      address:(id<MKMAddress>)address
                                     terminal:(NSString *)location {
    return [_idFactory createIdentifierWithName:name address:address terminal:location];
}

- (id<MKMID>)generateIdentifier:(MKMEntityType)network
                       withMeta:(id<MKMMeta>)meta
                       terminal:(nullable NSString *)location {
    return [_idFactory generateIdentifier:network
                                 withMeta:meta
                                 terminal:location];
}

- (nullable id<MKMID>)parseIdentifier:(NSString *)identifier {
    // try ANS record
    id<MKMID> ID = [_ans getID:identifier];
    if (ID) {
        return ID;
    }
    // parse by original factory
    return [_idFactory parseIdentifier:identifier];
}

@end

@implementation DIMClientFacebook (ANS)

//
//  Address Name Service
//
+ (DIMAddressNameServer *)ans {
    return _ans;
}

+ (void)setANS:(DIMAddressNameServer *)ans {
    _ans = ans;
}

+ (void)prepare {
    OKSingletonDispatchOnce(^{

        // load plugins
        DIMExtensionLoader *ext = [[DIMExtensionLoader alloc] init];
        [ext load];
        DIMPluginLoader *plugin = [[DIMPluginLoader alloc] init];
        [plugin load];
        
        _idFactory = MKMIDGetFactory();
        MKMIDSetFactory([[IDFactory alloc] init]);
        
    });
}

@end
