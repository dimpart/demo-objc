// license: https://mit-license.org
//
//  DIMP : Decentralized Instant Messaging Protocol
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
//  DIMHandshakeCommand.m
//  DIMCore
//
//  Created by Albert Moky on 2019/1/28.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#import "DIMHandshakeCommand.h"

DKDHandshakeState DKDHandshakeCheckState(NSString *title, NSString *_Nullable session) {
    if ([title isEqualToString:@"DIM!"]/* || [title isEqualToString:@"OK!"]*/) {
        return DKDHandshake_Success;
    } else if ([title isEqualToString:@"DIM?"]) {
        return DKDHandshake_Again;
    } else if ([session length] == 0) {
        return DKDHandshake_Start;
    } else {
        return DKDHandshake_Restart;
    }
}

@interface DIMHandshakeCommand ()

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic, nullable) NSString *sessionKey;

@property (nonatomic) DKDHandshakeState state;

@end

@implementation DIMHandshakeCommand

/* designated initializer */
- (instancetype)initWithDictionary:(NSDictionary *)dict {
    if (self = [super initWithDictionary:dict]) {
        // lazy
        _title = nil;
        _sessionKey = nil;
        _state = DKDHandshake_Init;
    }
    return self;
}

/* designated initializer */
- (instancetype)initWithType:(NSString *)type {
    if (self = [super initWithType:type]) {
        _title = nil;
        _sessionKey = nil;
        _state = DKDHandshake_Init;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title
                   sessionKey:(nullable NSString *)session {
    if (self = [self initWithCmd:DKDCommand_Handshake]) {
        // title
        if (title) {
            [self setObject:title forKey:@"title"];
        }
        _title = title;
        
        // session key
        if (session) {
            [self setObject:session forKey:@"session"];
        }
        _sessionKey = session;
        
        _state = DKDHandshake_Init;
    }
    return self;
}

- (instancetype)initWithSessionKey:(nullable NSString *)session {
    return [self initWithTitle:@"Hello world!" sessionKey:session];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMHandshakeCommand *content = [super copyWithZone:zone];
    if (content) {
        content.title = _title;
        content.sessionKey = _sessionKey;
        content.state = _state;
    }
    return content;
}

// Override
- (NSString *)title {
    if (!_title) {
        _title = [self objectForKey:@"title"];
    }
    return _title;
}

// Override
- (nullable NSString *)sessionKey {
    if (!_sessionKey) {
        _sessionKey = [self objectForKey:@"session"];
    }
    return _sessionKey;
}

// Override
- (DKDHandshakeState)state {
    if (_state == DKDHandshake_Init) {
        _state = DKDHandshakeCheckState(self.title, self.sessionKey);
    }
    return _state;
}

@end
