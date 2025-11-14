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
//  DIMCommonArchivist.h
//  DIMClient
//
//  Created by Albert Moky on 2023/12/12.
//

#import <DIMSDK/DIMSDK.h>
#import <DIMClient/DIMAccountDBI.h>
#import <DIMClient/DIMCache.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMCommonArchivist : DIMBarrack <DIMArchivist>

// protected
@property (readonly, weak, nonatomic, nullable) __kindof DIMFacebook *facebook;

@property (readonly, strong, nonatomic) id<DIMAccountDBI> database;

- (instancetype)initWithFacebook:(DIMFacebook *)facebook
                        database:(id<DIMAccountDBI>)db
NS_DESIGNATED_INITIALIZER;

@end

@interface DIMCommonArchivist (Cache)

- (id<DIMMemoryCache>)createUserCache;
- (id<DIMMemoryCache>)createGroupCache;

/**
 * Call it when received 'UIApplicationDidReceiveMemoryWarningNotification',
 * this will remove 50% of cached objects
 *
 * @return number of survivors
 */
- (NSUInteger)reduceMemory;

@end

@interface DIMCommonArchivist (Checking)

// protected
- (BOOL)checkMeta:(id<MKMMeta>)meta forID:(id<MKMID>)did;

// protected
- (BOOL)checkDocumentValid:(id<MKMDocument>)doc;

// protected
- (BOOL)verifyDocument:(id<MKMDocument>)doc;

// protected
- (BOOL)checkDocumentExpired:(id<MKMDocument>)doc;

@end

NS_ASSUME_NONNULL_END
