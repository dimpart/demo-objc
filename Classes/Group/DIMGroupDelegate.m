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
//  DIMGroupDelegate.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/13.
//

#import <FiniteStateMachine/FiniteStateMachine.h>

#import "DIMClientFacebook.h"

#import "DIMGroupDelegate.h"

@implementation DIMGroupDelegate

- (id<DIMArchivist>)archivist {
    DIMFacebook *facebook = [self facebook];
    return [facebook archivist];
}

- (nullable id<MKMBulletin>)bulletinForID:(id<MKMID>)gid {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook bulletinForID:gid];
}

- (BOOL)saveDocument:(id<MKMDocument>)doc {
    id<DIMArchivist> archivist = [self archivist];
    return [archivist saveDocument:doc];
}

//
//  Entity DataSource
//

// Override
- (nullable id<MKMMeta>)metaForID:(id<MKMID>)did {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook metaForID:did];
}

// Override
- (NSArray<id<MKMDocument>> *)documentsForID:(id<MKMID>)did {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook documentsForID:did];
}

//
//  Group DataSource
//

// Override
- (nullable id<MKMID>)founderOfGroup:(id<MKMID>)group {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook founderOfGroup:group];
}

// Override
- (nullable id<MKMID>)ownerOfGroup:(id<MKMID>)group {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook ownerOfGroup:group];
}

// Override
- (NSArray<id<MKMID>> *)membersOfGroup:(id<MKMID>)group {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook membersOfGroup:group];
}

@end

@implementation DIMGroupDelegate (Members)

- (NSString *)buildGroupNameWithMembers:(NSArray<id<MKMID>> *)members {
    NSUInteger count = [members count];
    NSAssert(count > 0, @"members should not be empty here");
    DIMCommonFacebook *facebook = [self facebook];
    NSString *text = [facebook getName:members.firstObject];
    NSString *nickname;
    for (NSUInteger i = 1; i < count; ++i) {
        nickname = [facebook getName:[members objectAtIndex:i]];
        if ([nickname length] == 0) {
            continue;
        }
        text = [text stringByAppendingFormat:@", %@", nickname];
        if ([text length] > 32) {
            text = [text substringToIndex:28];
            return [text stringByAppendingString:@" ..."];
        }
    }
    return text;
}

- (BOOL)saveMembers:(NSArray<id<MKMID>> *)members forGroup:(id<MKMID>)gid {
    DIMClientFacebook *facebook = [self facebook];
    return [facebook saveMembers:members forGroup:gid];
}

@end

@implementation DIMGroupDelegate (Administrators)

- (NSArray<id<MKMID>> *)administratorsOfGroup:(id<MKMID>)gid {
    DIMClientFacebook *facebook = [self facebook];
    return [facebook administratorsOfGroup:gid];
}

- (BOOL)saveAdministrators:(NSArray<id<MKMID>> *)admins forGroup:(id<MKMID>)gid {
    DIMClientFacebook *facebook = [self facebook];
    return [facebook saveAdministrators:admins forGroup:gid];
}

@end

@implementation DIMGroupDelegate (Membership)

- (BOOL)isFounder:(id<MKMID>)uid ofGroup:(id<MKMID>)gid {
    NSAssert([uid isUser] && [gid isGroup], @"ID error: %@, %@", uid, gid);
    id<MKMID> founder = [self founderOfGroup:gid];
    if (founder) {
        return [founder isEqual:uid];
    }
    // check member's public key with group's meta.key
    id<MKMMeta> gMeta = [self metaForID:gid];
    id<MKMMeta> uMeta = [self metaForID:uid];
    if (gMeta == nil || uMeta == nil) {
        NSAssert(false, @"failed to get meta for group: %@, user: %@", gid, uid);
        return NO;
    }
    return [DIMMetaUtils meta:gMeta matchPublicKey:uMeta.publicKey];
}

- (BOOL)isOwner:(id<MKMID>)uid ofGroup:(id<MKMID>)gid {
    NSAssert([uid isUser] && [gid isGroup], @"ID error: %@, %@", uid, gid);
    id<MKMID> owner = [self ownerOfGroup:gid];
    if (owner) {
        return [owner isEqual:uid];
    }
    if ([gid type] == MKMEntityType_Group) {
        // this is a polylogue
        return [self isFounder:uid ofGroup:gid];
    }
    NSAssert(false, @"only polylogue so far");
    return NO;
}

- (BOOL)isMember:(id<MKMID>)uid ofGroup:(id<MKMID>)gid {
    NSAssert([uid isUser] && [gid isGroup], @"ID error: %@, %@", uid, gid);
    NSArray<id<MKMID>> *members = [self membersOfGroup:gid];
    return [members containsObject:uid];
}

- (BOOL)isAdministrator:(id<MKMID>)uid ofGroup:(id<MKMID>)gid {
    NSAssert([uid isUser] && [gid isGroup], @"ID error: %@, %@", uid, gid);
    NSArray<id<MKMID>> *admins = [self administratorsOfGroup:gid];
    return [admins containsObject:uid];
}

@end

#pragma mark -

@interface DIMTripletsHelper ()

@property (strong, nonatomic) DIMGroupDelegate *delegate;

@end

@implementation DIMTripletsHelper

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    DIMGroupDelegate *delegate = nil;
    return [self initWithDelegate:delegate];
}

/* designated initializer */
- (instancetype)initWithDelegate:(DIMGroupDelegate *)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (DIMCommonFacebook *)facebook {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate facebook];
}

- (DIMCommonMessenger *)messenger {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate messenger];
}

- (id<DIMAccountDBI>)database {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook database];
}

@end
