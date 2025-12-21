// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2019 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2019 Albert Moky
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
//  DIMRegister.m
//  DIMClient
//
//  Created by Albert Moky on 2019/12/20.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <ObjectKey/ObjectKey.h>
#import <DIMPlugins/DIMPlugins.h>

#import "DIMHandshakeCommand.h"
#import "DIMReceiptCommand.h"
#import "DIMLoginCommand.h"
#import "DIMReportCommand.h"
#import "DIMMuteCommand.h"
#import "DIMBlockCommand.h"
#import "DIMAnsCommand.h"

#import "DIMEntityID.h"
#import "DIMMetaC.h"

#import "DIMRegister.h"

static inline id<MKMVisa> create_visa(id<MKMID> uid,
                                      NSString *nickname,
                                      _Nullable id<MKPortableNetworkFile> avatarUrl,
                                      id<MKEncryptKey> visaKey,
                                      id<MKSignKey> idKey) {
    assert([uid isUser]);
    id<MKMVisa> visa = [[DIMVisa alloc] init];
    [visa setString:uid forKey:@"did"];
    // App ID
    [visa setProperty:@"chat.dim.tarsier" forKey:@"app_id"];
    // nickname
    [visa setName:nickname];
    // avatar
    if (avatarUrl) {
        [visa setAvatar:avatarUrl];
    }
    // public key
    [visa setPublicKey:visaKey];
    // sign it
    NSData *sig = [visa sign:idKey];
    assert(sig);
    return visa;
}

static inline id<MKMBulletin> create_bulletin(id<MKMID> gid,
                                              NSString *title,
                                              id<MKSignKey> sKey,
                                              id<MKMID> founder) {
    assert([gid isGroup]);
    id<MKMBulletin> doc = [[DIMBulletin alloc] init];
    [doc setString:gid forKey:@"did"];
    // App ID
    [doc setProperty:@"chat.dim.tarsier" forKey:@"app_id"];
    // group founder
    [doc setProperty:founder.string forKey:@"founder"];
    // group name
    [doc setName:title];
    // sign it
    NSData *sig = [doc sign:sKey];
    assert(sig);
    return doc;
}

@interface DIMRegister ()

@property (strong, nonatomic) id<DIMAccountDBI> database;

@end

@implementation DIMRegister

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    id<DIMAccountDBI> db = nil;
    return [self initWithDatabase:db];
}

- (instancetype)initWithDatabase:(id<DIMAccountDBI>)db {
    if (self = [super init]) {
        self.database = db;
    }
    return self;
}

- (id<MKMID>)createUserWithName:(NSString *)nickname
                         avatar:(nullable id<MKPortableNetworkFile>)url {
    //
    //  Step 1: generate private key (with asymmetric algorithm)
    //
    id<MKPrivateKey> idKey = MKPrivateKeyGenerate(MKAsymmetricAlgorithm_ECC);
    //
    //  Step 2: generate meta with private key (and meta seed)
    //
    id<MKMMeta> meta = MKMMetaGenerate(MKMMetaType_ETH, idKey, nil);
    //
    //  Step 3: generate ID with meta
    //
    id<MKMID> uid = MKMIDGenerate(meta, MKMEntityType_User, nil);
    //
    //  Step 4: generate visa with ID and sign with private key
    //
    id<MKPrivateKey> msgKey = MKPrivateKeyGenerate(MKAsymmetricAlgorithm_RSA);
    id<MKEncryptKey> visaKey = (id<MKEncryptKey>)[msgKey publicKey];
    id<MKMVisa> visa = create_visa(uid, nickname, url, visaKey, idKey);
    //
    //  Step 5: save private key, meta & visa in local storage
    //          don't forget to upload them onto the DIM station
    //
    [_database saveMeta:meta forID:uid];
    [_database savePrivateKey:idKey withType:DIMPrivateKeyType_Meta forUser:uid];
    [_database savePrivateKey:msgKey withType:DIMPrivateKeyType_Visa forUser:uid];
    [_database saveDocument:visa];
    // OK
    return uid;
}

- (id<MKMID>)createGroupWithName:(NSString *)name founder:(id<MKMID>)founder {
    uint32_t seed = arc4random();
    NSString *string = [NSString stringWithFormat:@"Group-%u", seed];
    return [self createGroupWithName:name seed:string founder:founder];
}

- (id<MKMID>)createGroupWithName:(NSString *)name
                            seed:(NSString *)seed founder:(id<MKMID>)founder {
    //
    //  Step 1: get private key of founder
    //
    id<MKSignKey> sKey = [_database privateKeyForVisaSignature:founder];
    //
    //  Step 2: generate meta with private key (and meta seed)
    //
    id<MKMMeta> meta = MKMMetaGenerate(MKMMetaType_MKM, sKey, seed);
    //
    //  Step 3: generate ID with meta
    //
    id<MKMID> gid = MKMIDGenerate(meta, MKMEntityType_Group, nil);
    //
    //  Step 4: generate bulletin with ID and sign with founder's private key
    //
    id<MKMBulletin> doc = create_bulletin(gid, name, sKey, founder);
    //
    //  Step 5: save meta & bulletin in local storage
    //          don't forget to upload then onto the DIM station
    //
    [_database saveMeta:meta forID:gid];
    [_database saveDocument:doc];
    //
    //  Step 6: add founder as first member
    //
    [_database saveMembers:@[founder] forGroup:gid];
    // OK
    return gid;
}

@end
