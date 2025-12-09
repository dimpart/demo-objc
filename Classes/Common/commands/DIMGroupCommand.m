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
//  DIMGroupCommand.m
//  DIMClient
//
//  Created by Albert Moky on 2019/2/3.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMGroupCommand.h"

@implementation DIMHireGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid
               administrators:(NSArray<id<MKMID>> *)users {
    if (self = [self initWithCmd:DKDGroupCommand_Hire group:gid]) {
        self.administrators = users;
    }
    return self;
}

// Override
- (NSArray<id<MKMID>> *)administrators {
    NSArray *array = [self objectForKey:@"administrators"];
    if (array.count == 0) {
        return nil;
    }
    return MKMIDConvert(array);
}

// Override
- (void)setAdministrators:(NSArray<id<MKMID>> *)administrators {
    NSArray *array = MKMIDRevert(administrators);
    [self setObject:array forKey:@"administrators"];
}

@end

@implementation DIMFireGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid
               administrators:(NSArray<id<MKMID>> *)users {
    if (self = [self initWithCmd:DKDGroupCommand_Fire group:gid]) {
        self.administrators = users;
    }
    return self;
}

// Override
- (NSArray<id<MKMID>> *)administrators {
    NSArray *array = [self objectForKey:@"administrators"];
    if (array.count == 0) {
        return nil;
    }
    return MKMIDConvert(array);
}

// Override
- (void)setAdministrators:(NSArray<id<MKMID>> *)administrators {
    NSArray *array = MKMIDRevert(administrators);
    [self setObject:array forKey:@"administrators"];
}

@end

@implementation DIMResignGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)gid {
    if (self = [self initWithCmd:DKDGroupCommand_Resign group:gid]) {
        //
    }
    return self;
}

@end

#pragma mark - Conveniences

DIMHireGroupCommand *DIMGroupCommandHireAdministrators(id<MKMID> group,
                                                       NSArray<id<MKMID>> *admins) {
    return [[DIMHireGroupCommand alloc] initWithGroup:group administrators:admins];
}

DIMFireGroupCommand *DIMGroupCommandFireAdministrators(id<MKMID> group,
                                                       NSArray<id<MKMID>> *admins) {
    return [[DIMFireGroupCommand alloc] initWithGroup:group administrators:admins];
}

DIMResignGroupCommand *DIMGroupCommandResign(id<MKMID> group) {
    return [[DIMResignGroupCommand alloc] initWithGroup:group];
}

#pragma mark -

NSString * const DKDGroupCommand_Query  = @"query"; // Deprecated

@implementation DIMQueryGroupCommand

- (instancetype)initWithGroup:(id<MKMID>)groupID lastTime:(nullable NSDate *)time {
    if (self = [self initWithCmd:DKDGroupCommand_Query group:groupID]) {
        if (time) {
            [self setDate:time forKey:@"last_time"];
        }
    }
    return self;
}

- (NSDate *)lastTime {
    return [self dateForKey:@"last_time" defaultValue:nil];
}

@end

#pragma mark -

NSString * const DIMGroupHistory_App      = @"chat.dim.group";
NSString * const DIMGroupHistory_Mod      = @"history";
NSString * const DIMGroupHistory_ActQuery = @"query";

NSString * const DIMGroupKeys_App         = @"chat.dim.group";
NSString * const DIMGroupKeys_Mod         = @"keys";
NSString * const DIMGroupKeys_ActQuery    = @"query";    // 1. bot -> sender
NSString * const DIMGroupKeys_ActUpdate   = @"update";   // 2. sender -> bot
NSString * const DIMGroupKeys_ActRequest  = @"request";  // 3. member -> bot
NSString * const DIMGroupKeys_ActRespond  = @"respond";
