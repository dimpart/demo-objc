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
//  DIMCommonArchivist.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/12.
//

#import "DIMCommonArchivist.h"

@interface DIMCommonArchivist () {
    
    id<DIMMemoryCache> _userCache;
    id<DIMMemoryCache> _groupCache;
}

@property (weak, nonatomic, nullable) __kindof DIMFacebook *facebook;

@property (strong, nonatomic) id<DIMAccountDBI> database;

@end

@implementation DIMCommonArchivist

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    DIMFacebook *facebook = nil;
    id<DIMAccountDBI> adb = nil;
    return [self initWithFacebook:facebook database:adb];
}

/* designated initializer */
- (instancetype)initWithFacebook:(DIMFacebook *)facebook
                        database:(id<DIMAccountDBI>)db {
    if (self = [super init]) {
        self.facebook = facebook;
        self.database = db;
        _userCache = [self createUserCache];
        _groupCache = [self createGroupCache];
    }
    return self;
}

// Override
- (void)cacheUser:(id<MKMUser>)user {
    if ([user dataSource] == nil) {
        [user setDataSource:self.facebook];
    }
    id<MKMID> did = [user identifier];
    [_userCache setObject:user forKey:did.string];
}

// Override
- (void)cacheGroup:(id<MKMGroup>)group {
    if ([group dataSource] == nil) {
        [group setDataSource:self.facebook];
    }
    id<MKMID> did = [group identifier];
    [_groupCache setObject:group forKey:did.string];
}

// Override
- (nullable __kindof id<MKMUser>)user:(id<MKMID>)did {
    return [_userCache objectForKey:did.string];
}

// Override
- (nullable __kindof id<MKMGroup>)group:(id<MKMID>)did {
    return [_groupCache objectForKey:did.string];
}

#pragma mark Archivist

// Override
- (BOOL)saveMeta:(id<MKMMeta>)meta withIdentifier:(id<MKMID>)did {
    //
    //  1. check valid
    //
    if ([self checkMeta:meta forID:did]) {
        // meta valid
    } else {
        NSAssert(false, @"meta not valid: %@", did);
        return NO;
    }
    //
    //  2. check duplicated
    //
    DIMFacebook *facebook = [self facebook];
    id<MKMMeta> old = [facebook meta:did];
    if (old) {
        // meta duplicated
        return YES;
    }
    //
    //  3. save into database
    //
    id<DIMAccountDBI> db = [self database];
    return [db saveMeta:meta forID:did];
}

// Override
- (BOOL)saveDocument:(id<MKMDocument>)doc {
    //
    //  1. check valid
    //
    if ([self checkDocumentValid:doc]) {
        // document valid
    } else {
        NSAssert(false, @"document not valid: %@", [doc identifier]);
        return NO;
    }
    //
    //  2. check expired
    //
    if ([self checkDocumentExpired:doc]) {
        // drop expired document
        return NO;
    }
    //
    //  3. save into database
    //
    id<DIMAccountDBI> db = [self database];
    return [db saveDocument:doc];
}

// Override
- (nullable __kindof id<MKVerifyKey>)metaKey:(id<MKMID>)did {
    DIMFacebook *facebook = [self facebook];
    id<MKMMeta> meta = [facebook meta:did];
    NSAssert(meta, @"failed to get meta for: %@", did);
    return [meta publicKey];
}

// Override
- (nullable __kindof id<MKEncryptKey>)visaKey:(id<MKMID>)did {
    DIMFacebook *facebook = [self facebook];
    NSArray<id<MKMDocument>> *docs = [facebook documents:did];
    if ([docs count] == 0) {
        return nil;
    }
    id<MKMVisa> visa = [DIMDocumentUtils lastVisa:docs];
    NSAssert(visa, @"failed to get visa for: %@", did);
    return [visa publicKey];
}

// Override
- (NSArray<id<MKMID>> *)localUsers {
    id<DIMAccountDBI> db = [self database];
    return [db localUsers];
}

@end

@implementation DIMCommonArchivist (Cache)

- (id<DIMMemoryCache>)createUserCache {
    return [[DIMThanosCache alloc] init];
}

- (id<DIMMemoryCache>)createGroupCache {
    return [[DIMThanosCache alloc] init];
}

- (NSUInteger)reduceMemory {
    NSUInteger cnt1 = [_userCache reduceMemory];
    NSUInteger cnt2 = [_groupCache reduceMemory];
    return cnt1 + cnt2;
}

@end

@implementation DIMCommonArchivist (Checking)

- (BOOL)checkMeta:(nonnull id<MKMMeta>)meta forID:(nonnull id<MKMID>)did {
    return [meta isValid] && [DIMMetaUtils meta:meta matchIdentifier:did];
}

- (BOOL)checkDocumentValid:(nonnull id<MKMDocument>)doc {
    //id<MKMID> did = [doc identifier];
    NSDate *docTime = [doc time];
    // check document time
    if (!docTime) {
        //NSAssert(false, @"document error: %@", doc);
    } else {
        // calibrate the clock
        // make sure the document time is not in the far future
        NSDate *now = [[NSDate alloc] init];
        NSTimeInterval nearFuture = [now timeIntervalSince1970] + 1800;
        if ([docTime timeIntervalSince1970] > nearFuture) {
            NSAssert(false, @"document time error: %@, %@", docTime, doc);
            return NO;
        }
    }
    // check valid
    return [self verifyDocument:doc];
}

- (BOOL)verifyDocument:(nonnull id<MKMDocument>)doc {
    if ([doc isValid]) {
        return YES;
    }
    id<MKMID> did = [doc identifier];
    DIMFacebook *facebook = [self facebook];
    id<MKMMeta> meta = [facebook meta:did];
    if (!meta) {
        // failed to get meta
        return NO;
    }
    id<MKVerifyKey> PK = [meta publicKey];
    return [doc verify:PK];
}

- (BOOL)checkDocumentExpired:(nonnull id<MKMDocument>)doc {
    id<MKMID> did = [doc identifier];
    NSString *type = [DIMDocumentUtils getDocumentType:doc];
    // check old documents with type
    DIMFacebook *facebook = [self facebook];
    NSArray<id<MKMDocument>> *documents = [facebook documents:did];
    if ([documents count] == 0) {
        return NO;
    }
    id<MKMDocument> old = [DIMDocumentUtils lastDocument:documents forType:type];
    return old && [DIMDocumentUtils timeIsExpired:doc compareTo:old];
}

@end
