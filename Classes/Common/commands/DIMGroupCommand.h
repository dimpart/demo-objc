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
//  DIMGroupCommand.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import <DIMCore/DIMCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DKDHireGroupCommand <DKDGroupCommand>

@property (strong, nonatomic, nullable) NSArray<id<MKMID>> *administrators;

@end

@interface DIMHireGroupCommand : DIMGroupCommand <DKDHireGroupCommand>

- (instancetype)initWithGroup:(id<MKMID>)gid
               administrators:(NSArray<id<MKMID>> *)users;

@end

@protocol DKDFireGroupCommand <DKDGroupCommand>

@property (strong, nonatomic, nullable) NSArray<id<MKMID>> *administrators;

@end

@interface DIMFireGroupCommand : DIMGroupCommand <DKDFireGroupCommand>

- (instancetype)initWithGroup:(id<MKMID>)gid
               administrators:(NSArray<id<MKMID>> *)users;

@end

@protocol DKDResignGroupCommand <DKDGroupCommand> @end

@interface DIMResignGroupCommand : DIMGroupCommand <DKDResignGroupCommand>

- (instancetype)initWithGroup:(id<MKMID>)gid;

@end

#pragma mark - Conveniences

#ifdef __cplusplus
extern "C" {
#endif

DIMHireGroupCommand *DIMGroupCommandHireAdministrators(id<MKMID> group,
                                                       NSArray<id<MKMID>> *admins);

DIMFireGroupCommand *DIMGroupCommandFireAdministrators(id<MKMID> group,
                                                       NSArray<id<MKMID>> *admins);

DIMResignGroupCommand *DIMGroupCommandResign(id<MKMID> group);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

#pragma mark -

FOUNDATION_EXPORT NSString * const DKDGroupCommand_Query;  // Deprecated

/**
 *  History command: {
 *      type : 0x88,
 *      sn   : 123,
 *
 *      command : "query",
 *      time    : 123.456,
 *
 *      group     : "{GROUP_ID}",
 *      last_time : 0
 *  }
 */
@protocol DKDQueryGroupCommand <DKDGroupCommand>

// Last group history time for querying
@property (readonly, strong, nonatomic, nullable) NSDate *lastTime;

@end

@interface DIMQueryGroupCommand : DIMGroupCommand <DKDQueryGroupCommand>

- (instancetype)initWithGroup:(id<MKMID>)groupID lastTime:(nullable NSDate *)time;

@end

#pragma mark -

/**
 *  Group Query Command: {
 *      "type" : i2s(0xCC),
 *      "sn"   : 123,
 *      "time" : 123.456,
 *
 *      "app"  : "chat.dim.group",
 *      "mod"  : "history",
 *      "act"  : "query",
 *
 *      "group"     : "{GROUP_ID}",
 *      "last_time" : 0,             // Last group history time for querying
 *  }
 */
@protocol DIMGroupHistory <NSObject>

+ (id<DKDCustomizedContent>)queryGroupHistory:(id<MKMID>)group
                                     lastTime:(nullable NSDate *)time;

@end

FOUNDATION_EXPORT NSString * const DIMGroupHistory_App;
FOUNDATION_EXPORT NSString * const DIMGroupHistory_Mod;
FOUNDATION_EXPORT NSString * const DIMGroupHistory_ActQuery;

FOUNDATION_EXPORT NSString * const DIMGroupKeys_App;
FOUNDATION_EXPORT NSString * const DIMGroupKeys_Mod;
FOUNDATION_EXPORT NSString * const DIMGroupKeys_ActQuery;    // 1. bot -> sender
FOUNDATION_EXPORT NSString * const DIMGroupKeys_ActUpdate;   // 2. sender -> bot
FOUNDATION_EXPORT NSString * const DIMGroupKeys_ActRequest;  // 3. member -> bot
FOUNDATION_EXPORT NSString * const DIMGroupKeys_ActRespond;  // 4. bot -> member

/**
 *  Group Keys Command: {
 *      "type" : i2s(0xCC),
 *      "sn"   : 123,
 *      "time" : 123.456,
 *
 *      "app"  : "chat.dim.group",
 *      "mod"  : "keys",
 *      "act"  : "query",   // "update", "request", "respond"
 *
 *      "group"  : "{GROUP_ID}",
 *      "from"   : "{SENDER_ID}",
 *      "to"     : ["{MEMBER_ID}", ],  // query for members
 *      "digest" : "{KEY_DIGEST}",     // query with digest
 *      "keys"   : {
 *          "digest"      : "{KEY_DIGEST}",
 *          "{MEMBER_ID}" : "{ENCRYPTED_KEY}",
 *      }
 *  }
 */
@protocol DIMGroupKeys <NSObject>

// TODO: ...
//+ (id<DKDCustomizedContent>)queryGroupKeys:(id<MKMID>)group;

@end

NS_ASSUME_NONNULL_END
