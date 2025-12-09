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
//  DIMCommonFacebook.m
//  DIMClient
//
//  Created by Albert Moky on 2023/3/4.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "MKMAnonymous.h"
#import "DIMCommonArchivist.h"

#import "DIMCommonFacebook.h"

@interface DIMCommonFacebook () {
    
    DIMCommonArchivist *_barrack;
    
    id<MKMUser> _currentUser;
}

@property (strong, nonatomic) id<DIMAccountDBI> database;

@end

@implementation DIMCommonFacebook

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    id<DIMAccountDBI> db = nil;
    return [self initWithDatabase:db];
}

/* designated initializer */
- (instancetype)initWithDatabase:(id<DIMAccountDBI>)adb {
    if (self = [super init]) {
        self.database = adb;
    }
    return self;
}

// Override
- (__kindof DIMBarrack *)barrack {
    return _barrack;
}

// Override
- (__kindof id<DIMArchivist>)archivist {
    return _barrack;
}

- (void)setArchivist:(DIMCommonArchivist *)barrack {
    _barrack = barrack;
}

#pragma mark Current User

- (id<MKMUser>)currentUser {
    // Get current user (for signing and sending message)
    id<MKMUser> user = _currentUser;
    if (user) {
        return user;
    }
    id<DIMAccountDBI> adb = [self database];
    NSArray<id<MKMID>> *localUsers = [adb localUsers];
    if ([localUsers count] == 0) {
        return nil;
    }
    id<MKMID> current = [localUsers firstObject];
    NSAssert([self privateKeyForSignature:current], @"user error: %@", current);
    user = [self userForID:current];
    _currentUser = user;
    return user;
}

- (void)setCurrentUser:(id<MKMUser>)currentUser {
    if (!currentUser.dataSource) {
        currentUser.dataSource = self;
    }
    _currentUser = currentUser;
}

// Override
- (nullable id<MKMID>)selectLocalUserForID:(id<MKMID>)receiver {
    id<MKMUser> user = _currentUser;
    if (user) {
        id<MKMID> current = [user identifier];
        if ([receiver isBroadcast]) {
            // broadcast message can be decrypted by anyone, so
            // just return current user here
            return current;
        } else if ([receiver isGroup]) {
            // group message (recipient not designated)
            //
            // the messenger will check group info before decrypting message,
            // so we can trust that the group's meta & members MUST exist here.
            NSArray<id<MKMID>> *members = [self membersOfGroup:receiver];
            if ([members count] == 0) {
                NSAssert(false, @"members not found: %@", receiver);
                return nil;
            } else if ([members containsObject:current]) {
                return current;
            }
        } else if ([receiver isEqual:current]) {
            return current;
        }
    }
    // check local users
    return [super selectLocalUserForID:receiver];
}

#pragma mark Entity DataSource

// Override
- (id<MKMMeta>)metaForID:(id<MKMID>)did {
    id<DIMAccountDBI> adb = [self database];
    id<MKMMeta> meta = [adb metaForID:did];
    [self.entityChecker checkMeta:meta forID:did];
    return meta;
}

// Override
- (NSArray<id<MKMDocument>> *)documentsForID:(id<MKMID>)did {
    id<DIMAccountDBI> adb = [self database];
    NSArray<id<MKMDocument>> *docs = [adb documentsForID:did];
    [self.entityChecker checkDocuments:docs forID:did];
    return docs;
}

#pragma mark User DataSource

// Override
- (NSArray<id<MKMID>> *)contactsOfUser:(id<MKMID>)user {
    id<DIMAccountDBI> adb = [self database];
    return [adb contactsOfUser:user];
}

// Override
- (NSArray<id<MKDecryptKey>> *)privateKeysForDecryption:(id<MKMID>)user {
    id<DIMAccountDBI> adb = [self database];
    return [adb privateKeysForDecryption:user];
}

// Override
- (id<MKSignKey>)privateKeyForSignature:(id<MKMID>)user {
    id<DIMAccountDBI> adb = [self database];
    return [adb privateKeyForSignature:user];
}

// Override
- (id<MKSignKey>)privateKeyForVisaSignature:(id<MKMID>)user {
    id<DIMAccountDBI> adb = [self database];
    return [adb privateKeyForVisaSignature:user];
}

@end

@implementation DIMCommonFacebook (Documents)

- (nullable __kindof id<MKMDocument>)document:(id<MKMID>)did
                                      forType:(nullable NSString *)type {
    NSArray<id<MKMDocument>> *docs = [self documentsForID:did];
    id<MKMDocument> doc = [DIMDocumentUtils lastDocument:docs
                                                 forType:type];
    // compatible for document type
    if (!doc && [type isEqualToString:MKMDocumentType_Visa]) {
        doc = [DIMDocumentUtils lastDocument:docs
                                     forType:MKMDocumentType_Profile];
    }
    return doc;
}

- (nullable __kindof id<MKMVisa>)visaForID:(id<MKMID>)did {
    NSArray<id<MKMDocument>> *docs = [self documentsForID:did];
    return [DIMDocumentUtils lastVisa:docs];
}

- (nullable __kindof id<MKMBulletin>)bulletinForID:(id<MKMID>)did {
    NSArray<id<MKMDocument>> *docs = [self documentsForID:did];
    return [DIMDocumentUtils lastBulletin:docs];
}

- (nullable NSString *)getName:(id<MKMID>)did {
    NSString *type;
    if ([did isUser]) {
        type = MKMDocumentType_Visa;
    } else if ([did isGroup]) {
        type = MKMDocumentType_Bulletin;
    } else {
        type = @"*";
    }
    // get name from document
    id<MKMDocument> doc = [self document:did forType:type];
    if (doc) {
        NSString *name = [doc propertyForKey:@"name"];
        if ([name length] > 0) {
            return name;
        }
    }
    // get name from ID
    return [MKMAnonymous name:did];
}

- (nullable id<MKPortableNetworkFile>)getAvatar:(id<MKMID>)user {
    id<MKMVisa> doc = [self visaForID:user];
    return [doc avatar];
}

@end

@implementation DIMCommonFacebook (Group)

- (NSArray<id<MKMID>> *)administratorsOfGroup:(id<MKMID>)group {
    NSAssert(false, @"implement me!");
    return nil;
}

- (BOOL)saveAdministrators:(NSArray<id<MKMID>> *)admins forGroup:(id<MKMID>)group {
    NSAssert(false, @"implement me!");
    return NO;
}

- (BOOL)saveMembers:(NSArray<id<MKMID>> *)newMembers forGroup:(id<MKMID>)group {
    NSAssert(false, @"implement me!");
    return NO;
}

@end
