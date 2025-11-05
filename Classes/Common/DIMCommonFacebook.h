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
//  DIMCommonFacebook.h
//  DIMClient
//
//  Created by Albert Moky on 2023/3/4.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

#import <DIMClient/DIMAccountDBI.h>
#import <DIMClient/DIMAddressNameServer.h>
#import <DIMClient/DIMEntityChecker.h>
#import <DIMClient/DIMCommonArchivist.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Common Facebook with Database
 */
@interface DIMCommonFacebook : DIMFacebook

@property (readonly, strong, nonatomic) id<DIMAccountDBI> database;

@property (strong, nonatomic, nullable) __kindof DIMEntityChecker *entityChecker;

- (instancetype)initWithDatabase:(id<DIMAccountDBI>)adb
NS_DESIGNATED_INITIALIZER;

- (void)setArchivist:(DIMCommonArchivist *)barrack;

//
//  Current User
//
- (nullable __kindof id<MKMUser>)currentUser;
- (void)setCurrentUser:(id<MKMUser>)user;

@end

@interface DIMCommonFacebook (Documents)

- (nullable __kindof id<MKMDocument>)document:(id<MKMID>)ID
                                      forType:(nullable NSString *)type;

- (nullable __kindof id<MKMVisa>)visa:(id<MKMID>)ID;
- (nullable __kindof id<MKMBulletin>)bulletin:(id<MKMID>)ID;

- (nullable NSString *)getName:(id<MKMID>)ID;

- (nullable id<MKPortableNetworkFile>)getAvatar:(id<MKMID>)user;

@end

@interface DIMCommonFacebook (Group)

- (NSArray<id<MKMID>> *)administrators:(id<MKMID>)group;

- (BOOL)saveAdministrators:(NSArray<id<MKMID>> *)admins forGroup:(id<MKMID>)group;

- (BOOL)saveMembers:(NSArray<id<MKMID>> *)newMembers forGroup:(id<MKMID>)group;

@end

NS_ASSUME_NONNULL_END
