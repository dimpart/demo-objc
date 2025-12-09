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
//  DIMGroupDelegate.h
//  DIMClient
//
//  Created by Albert Moky on 2023/12/13.
//

#import "DIMAccountDBI.h"
#import "DIMCommonFacebook.h"
#import "DIMCommonMessenger.h"

NS_ASSUME_NONNULL_BEGIN

@interface DIMGroupDelegate : DIMTwinsHelper <MKMGroupDataSource>

@property (readonly, strong, nonatomic, nullable) id<DIMArchivist> archivist;

- (nullable id<MKMBulletin>)bulletinForID:(id<MKMID>)gid;

- (BOOL)saveDocument:(id<MKMDocument>)doc;

@end

@interface DIMGroupDelegate (Members)

- (NSString *)buildGroupNameWithMembers:(NSArray<id<MKMID>> *)members;

- (BOOL)saveMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)gid;

@end

@interface DIMGroupDelegate (Administrators)

- (NSArray<id<MKMID>> *)administratorsOfGroup:(id<MKMID>)gid;

- (BOOL)saveAdministrators:(NSArray<id<MKMID>> *)admins group:(id<MKMID>)gid;

@end

@interface DIMGroupDelegate (Membership)

- (BOOL)isFounder:(id<MKMID>)uid group:(id<MKMID>)gid;

- (BOOL)isOwner:(id<MKMID>)uid group:(id<MKMID>)gid;

- (BOOL)isMember:(id<MKMID>)uid group:(id<MKMID>)gid;

- (BOOL)isAdministrator:(id<MKMID>)uid group:(id<MKMID>)gid;

@end

#pragma mark -

@interface DIMTripletsHelper : NSObject

@property (readonly, strong, nonatomic) DIMGroupDelegate *delegate;

@property (readonly, weak, nonatomic, nullable) __kindof DIMCommonFacebook *facebook;
@property (readonly, weak, nonatomic, nullable) __kindof DIMCommonMessenger *messenger;

@property (readonly, weak, nonatomic, nullable) id<DIMAccountDBI> database;

- (instancetype)initWithDelegate:(DIMGroupDelegate *)delegate
NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
