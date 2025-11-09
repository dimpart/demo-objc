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
//  DIMAppCustomizedProcessor.m
//  DIMClient
//
//  Created by Albert Moky on 2025/11/8.
//

#import "DIMGroupCommand.h"

#import "DIMAppCustomizedProcessor.h"

static inline NSString *build_key(NSString *app, NSString *mod) {
    return [[NSString alloc] initWithFormat:@"%@:%@", app, mod];;
}

@interface DIMAppCustomizedProcessor () {
    
    NSMutableDictionary<NSString *, id<DIMCustomizedContentHandler>> *_handlers;
}

@end

@implementation DIMAppCustomizedProcessor

- (instancetype)initWithFacebook:(DIMFacebook *)facebook
                       messenger:(DIMMessenger *)transceiver {
    if (self = [super initWithFacebook:facebook messenger:transceiver]) {
        _handlers = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)setContentHandler:(id<DIMCustomizedContentHandler>)handler
                forModule:(NSString *)mod
            inApplication:(NSString *)app {
    [_handlers setObject:handler forKey:build_key(app, mod)];
}

- (nullable id<DIMCustomizedContentHandler>)contentHandlerForModule:(NSString *)mod
                                                      inApplication:(NSString *)app {
    return [_handlers objectForKey:build_key(app, mod)];
}

// Override
- (id<DIMCustomizedContentHandler>)filterApplication:(NSString *)app
                                          withModule:(NSString *)mod
                                             content:(id<DKDCustomizedContent>)body
                                            messasge:(id<DKDReliableMessage>)rMsg {
    id<DIMCustomizedContentHandler> handler;
    handler = [self contentHandlerForModule:mod inApplication:app];
    if (!handler) {
        // default handler
        handler = [super filterForModule:mod inApplication:app content:body messasge:rMsg];
    }
    return handler;
}

@end

@implementation DIMGroupHistoryHandler

// Override
- (NSArray<id<DKDContent>> *)handleAction:(NSString *)act
                                   sender:(id<MKMID>)uid
                                  content:(id<DKDCustomizedContent>)body
                                  message:(id<DKDReliableMessage>)rMsg {
    if ([body group] == nil) {
        NSAssert(false, @"group command error: %@, sender: %@", body, uid);
        NSString *text = @"Group command error.";
        return [self respondReceipt:text envelope:rMsg.envelope content:body extra:nil];
    } else if ([act isEqualToString:DIMGroupHistory_ActQuery]) {
        return [self transformQueryCommand:body message:rMsg];
    }
    NSAssert(false, @"unknown action: %@, %@, sender: %@", act, body, uid);
    return [super handleAction:act sender:uid content:body message:rMsg];
}

// private
- (NSArray<id<DKDContent>> *)transformQueryCommand:(id<DKDCustomizedContent>)body
                                           message:(id<DKDReliableMessage>)rMsg {
    DIMMessenger *transceiver = [self messenger];
    if (!transceiver) {
        NSAssert(false, @"messenger lost");
        return nil;
    }
    NSMutableDictionary *info = [body copyDictionary:NO];
    [info setObject:DKDContentType_Command forKey:@"type"];
    [info setObject:DKDGroupCommand_Query forKey:@"command"];
    id<DKDContent> query = DKDContentParse(info);
    if ([query conformsToProtocol:@protocol(DKDQueryGroupCommand)]) {
        return [transceiver processContent:query
                withReliableMessageMessage:rMsg];
    }
    NSAssert(false, @"query command error: %@, %@, sender: %@", query, body, rMsg.sender);
    NSString *text = @"Query command error.";
    return [self respondReceipt:text envelope:rMsg.envelope content:body extra:nil];
}

@end
