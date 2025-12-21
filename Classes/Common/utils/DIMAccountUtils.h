// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
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
//  DIMAccountUtils.h
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIMMetaUtils : NSObject

/**
 *  Check whether meta matches with entity ID
 *  (must call this when received a new meta from network)
 */
+ (BOOL)meta:(id<MKMMeta>)info matchID:(id<MKMID>)did;

/**
 *  Check whether meta matches with public key
 */
+ (BOOL)meta:(id<MKMMeta>)info matchPublicKey:(id<MKVerifyKey>)PK;

@end

#pragma mark Conveniences

#define DIMMetaMatchID(ID, meta) [DIMMetaUtils meta:(meta) matchID:(ID)]
#define DIMMetaMatchPK(PK, meta) [DIMMetaUtils meta:(meta) matchPublicKey:(PK)]

#pragma mark -

@interface DIMDocumentUtils : NSObject

+ (nullable NSString *)getDocumentType:(id<MKMDocument>)document;

/**
 *  Check whether this time is before old time
 */
+ (BOOL)time:(nullable NSDate *)thisTime isBefore:(nullable NSDate *)oldTime;

/**
 *  Check whether this document's time is before old document's time
 */
+ (BOOL)timeIsExpired:(id<MKMDocument>)thisDoc compareTo:(id<MKMDocument>)oldDoc;

/**
 *  Select last document matched the type
 */
+ (nullable __kindof id<MKMDocument>)lastDocument:(NSArray<id<MKMDocument>> *)docs
                                          forType:(nullable NSString *)type;

/**
 *  Select last visa document
 */
+ (nullable __kindof id<MKMVisa>)lastVisa:(NSArray<id<MKMDocument>> *)docs;

/**
 *  Select last bulletin document
 */
+ (nullable __kindof id<MKMBulletin>)lastBulletin:(NSArray<id<MKMDocument>> *)docs;

@end

#pragma mark Conveniences

#define DIMDocumentGetType(doc)         [DIMDocumentUtils getDocumentType:(doc)]
#define DIMDocumentGetLast(docs, T)     [DIMDocumentUtils lastDocument:(docs) forType:(T)]
#define DIMDocumentGetVisa(docs)        [DIMDocumentUtils lastVisa:(docs)]
#define DIMDocumentGetBulletin(docs)    [DIMDocumentUtils lastBulletin:(docs)]

NS_ASSUME_NONNULL_END
