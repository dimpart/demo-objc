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
//  DIMCommonMessenger.m
//  DIMClient
//
//  Created by Albert Moky on 2023/3/5.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMCompatible.h"

#import "DIMCommonMessenger.h"

@interface DIMCommonMessenger () {
    
    DIMCommonFacebook *_facebook;
    
    id<DIMPacker> _packer;
    id<DIMProcessor> _processor;
    
    id<DIMCompressor> _compressor;
}

@property (strong, nonatomic) id<DIMSession> session;
@property (strong, nonatomic) id<DIMCipherKeyDelegate> database;

@end

@implementation DIMCommonMessenger

- (instancetype)init {
    NSAssert(false, @"don't call me!");
    DIMCommonFacebook *barrack = nil;
    id<DIMSession> session = nil;
    id<DIMMessageDBI> db = nil;
    return [self initWithFacebook:barrack session:session database:db];
}

/* designated initializer */
- (instancetype)initWithFacebook:(DIMCommonFacebook *)barrack
                         session:(id<DIMSession>)session
                        database:(id<DIMCipherKeyDelegate>)db {
    if (self = [super init]) {
        _facebook = barrack;
        _session = session;
        _database = db;
        
        _packer = nil;
        _processor = nil;
        _compressor = [self createMessageCompressor];
    }
    return self;
}

- (id<DIMCompressor>)createMessageCompressor {
    DIMMessageShortener *shortener = [[DIMMessageShortener alloc] init];
    return [[DIMMessageCompressor alloc] initWithShortener:shortener];
}

// Override
- (__kindof id<MKMEntityDelegate>)facebook {
    return _facebook;
}

// Override
- (__kindof id<DIMCompressor>)compressor {
    return _compressor;
}

// Override
- (__kindof id<DIMCipherKeyDelegate>)keyCache {
    return _database;
}

// Override
- (__kindof id<DIMPacker>)packer {
    return _packer;
}

- (void)setPacker:(id<DIMPacker>)messagePacker {
    _packer = messagePacker;
}

// Override
- (__kindof id<DIMProcessor>)processor {
    return _processor;
}

- (void)setProcessor:(id<DIMProcessor>)messageProcessor {
    _processor = messageProcessor;
}

#pragma mark Packer

// Override
- (NSData *)serializeMessage:(id<DKDReliableMessage>)rMsg {
    [DIMCompatible fixMetaAttachment:rMsg];
    [DIMCompatible fixVisaAttachment:rMsg];
    return [super serializeMessage:rMsg];
}

// Override
- (id<DKDReliableMessage>)deserializeMessage:(NSData *)data {
    if ([data length] <= 8) {
        // message data error
        return nil;
    // } else if (data.first != '{'.codeUnitAt(0) || data.last != '}'.codeUnitAt(0)) {
    //   // only support JsON format now
    //   return null;
    }
    id<DKDReliableMessage> rMsg = [super deserializeMessage:data];
    if (rMsg) {
        [DIMCompatible fixMetaAttachment:rMsg];
    }
    return rMsg;
}

#pragma mark InstantMessageDelegate

// Override
- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                  encryptKey:(NSData *)data
                 forReceiver:(id<MKMID>)receiver {
    @try {
        return [super message:iMsg encryptKey:data forReceiver:receiver];
    } @catch (NSException *exception) {
        // FIXME:
        NSLog(@"failed to encrypt key for receiver: %@, error: %@", receiver, exception);
    } @finally {
        //
    }
}

// Override
- (nullable NSData *)message:(id<DKDInstantMessage>)iMsg
                serializeKey:(id<MKSymmetricKey>)password {
    // TODO: reuse message key
    
    // 0. check message key
    id reused = [password objectForKey:@"reused"];
    id digest = [password objectForKey:@"digest"];
    if (!reused && !digest) {
        // flags not exist, serialize it directly
        return [super message:iMsg serializeKey:password];
    }
    // 1. remove before serializing key
    [password removeObjectForKey:@"reused"];
    [password removeObjectForKey:@"digest"];
    // 2. serialize key without flags
    NSData *data = [super message:iMsg serializeKey:password];
    // 3. put them back after serialized
    if (MKConvertBool(reused, NO)) {
        [password setObject:@(YES) forKey:@"reused"];
    }
    if (digest) {
        [password setObject:digest forKey:@"digest"];
    }
    // OK
    return data;
}

// Override
- (NSData *)message:(id<DKDInstantMessage>)iMsg
   serializeContent:(id<DKDContent>)content
            withKey:(id<MKSymmetricKey>)password {
    [DIMCompatibleOutgoing fixContent:content];
    return [super message:iMsg serializeContent:content withKey:password];
}

#pragma mark Interfaces for Transmitting Message

// Override
- (DIMTransmitterResults *)sendContent:(id<DKDContent>)content
                                sender:(nullable id<MKMID>)from
                              receiver:(id<MKMID>)to
                              priority:(NSInteger)prior {
    if (!from) {
        id<MKMUser> current = [_facebook currentUser];
        NSAssert(current, @"current user not set");
        from = [current identifier];
    }
    id<DKDEnvelope> env = DKDEnvelopeCreate(from, to, nil);
    id<DKDInstantMessage> iMsg = DKDInstantMessageCreate(env, content);
    id<DKDReliableMessage> rMsg = [self sendInstantMessage:iMsg priority:prior];
    return [[DIMTransmitterResults alloc] initWithFirst:iMsg second:rMsg];
}

// private
- (BOOL)attachVisaTime:(id<DKDInstantMessage>)iMsg forSender:(id<MKMID>)sender {
    id<DKDContent> content = [iMsg content];
    if ([content conformsToProtocol:@protocol(DKDCommand)]) {
        // no need to attach times for command
        return NO;
    }
    DIMCommonFacebook *facebook = [self facebook];
    id<MKMVisa> doc = [facebook getVisa:sender];
    if (!doc) {
        NSAssert(false, @"failed to get visa document for sender: %@", sender);
        return NO;
    }
    // attach sender document time
    NSDate *lastDocTime = [doc time];
    if (!lastDocTime) {
        NSAssert(false, @"document error: %@", doc);
        return NO;
    }
    [iMsg setDate:lastDocTime forKey:@"SDT"];
    return YES;
}

// Override
- (id<DKDReliableMessage>)sendInstantMessage:(id<DKDInstantMessage>)iMsg
                                    priority:(NSInteger)prior {
    id<MKMID> sender = [iMsg sender];
    //
    //  0. check cycled message
    //
    if ([sender isEqual:iMsg.receiver]) {
        NSLog(@"drop cycled message: %@, %@ => %@, %@", iMsg.content,
              iMsg.sender, iMsg.receiver, iMsg.group);
        return nil;
    } else {
        NSLog(@"send instant message (type=%@): %@ => %@, %@", iMsg.content.type,
              iMsg.sender, iMsg.receiver, iMsg.group);
        // attach sender's document times
        // for the receiver to check whether user info synchronized
        BOOL ok = [self attachVisaTime:iMsg forSender:sender];
        NSAssert(ok || [iMsg.content conformsToProtocol:@protocol(DKDCommand)],
                 @"failed to attach document time: %@ => %@", sender, iMsg.content);;
    }
    //
    //  1. encrypt message
    //
    id<DKDSecureMessage> sMsg = [self encryptMessage:iMsg];
    if (!sMsg) {
        // public key not found?
        return nil;
    }
    //
    //  2. sign message
    //
    id<DKDReliableMessage> rMsg = [self signMessage:sMsg];
    if (!rMsg) {
        // TODO: set msg.state = error
        NSAssert(false, @"failed to sign message: %@", sMsg);
        return nil;
    }
    // 3. send message
    BOOL ok = [self sendReliableMessage:rMsg priority:prior];
    if (ok) {
        return rMsg;
    } else {
        // failed
        return nil;
    }
}

// Override
- (BOOL)sendReliableMessage:(id<DKDReliableMessage>)rMsg
                   priority:(NSInteger)prior {
    // 0. check cycled message
    if ([rMsg.sender isEqual:rMsg.receiver]) {
        NSLog(@"drop cycled message: %@ => %@, %@",
              rMsg.sender, rMsg.receiver, rMsg.group);
        return nil;
    }
    // 1. serialize message
    NSData *data = [self serializeMessage:rMsg];
    NSAssert(data, @"failed to serialize message: %@", rMsg);
    // 2. call gate keeper to send the message data package
    //    put message package into the waiting queue of current session
    return [_session queueMessage:rMsg package:data priority:prior];
}

@end
