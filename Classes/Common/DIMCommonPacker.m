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
//  DIMCommonPacker.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/15.
//

#import "DIMAccountUtils.h"
#import "DIMMessageUtils.h"

#import "DIMCompatible.h"

#import "DIMCommonPacker.h"

@implementation DIMCommonPacker

- (nullable id<DIMArchivist>)archivist {
    DIMFacebook *facebook = [self facebook];
    return [facebook archivist];
}

// Override
- (id<DKDSecureMessage>)encryptMessage:(id<DKDInstantMessage>)iMsg {
    // make sure visa.key exists before encrypting message

    //
    //  Check FileContent
    //  ~~~~~~~~~~~~~~~~~
    //  You must upload file data before packing message.
    //
    __kindof id<DKDContent> content = [iMsg content];
    if ([content conformsToProtocol:@protocol(DKDFileContent)]) {
        id<DKDFileContent> file = content;
        NSData *data = [file data];
        if ([data length] > 0) {
            NSAssert(false, @"You should upload file data before calling sendInstantMessage: %@ -> %@ (%@)",
                     [iMsg sender], [iMsg receiver], [iMsg group]);
            return nil;
        }
    }

    // the intermediate node(s) can only get the message's signature,
    // but cannot know the 'sn' because it cannot decrypt the content,
    // this is usually not a problem;
    // but sometimes we want to respond a receipt with original sn,
    // so I suggest to expose 'sn' here.
    [iMsg setObject:@(content.sn) forKey:@"sn"];

    // 1. check contact info
    // 2. check group members info
    if ([self checkReceiverInInstantMessage:iMsg]) {
        // receiver is ready
    } else {
        NSLog(@"receiver not ready: %@", iMsg.receiver);
        return nil;
    }
    return [super encryptMessage:iMsg];
}

// Override
- (id<DKDSecureMessage>)verifyMessage:(id<DKDReliableMessage>)rMsg {
    // make sure sender's meta exists before verifying message
    if ([self checkAttachments:rMsg]) {
        // meta/visa ok
    } else {
        return nil;
    }
    // 1. check receiver/group with local user
    // 2. check sender's visa info
    if ([self checkSenderInReliableMessage:rMsg]) {
        // sender is ready
    } else {
        NSLog(@"sender not ready: %@", rMsg.sender);
        return nil;
    }
    return [super verifyMessage:rMsg];
}

// Override
- (id<DKDReliableMessage>)signMessage:(id<DKDSecureMessage>)sMsg {
    if ([sMsg conformsToProtocol:@protocol(DKDReliableMessage)]) {
        // already signed
        return (id<DKDReliableMessage>)sMsg;
    }
    return [super signMessage:sMsg];
}

@end

@implementation DIMCommonPacker (Suspend)

- (void)suspendReliableMessage:(id<DKDReliableMessage>)rMsg
                         error:(NSDictionary *)info {
    NSLog(@"TODO: suspendReliableMessage");
}

- (void)suspendInstantMessage:(id<DKDInstantMessage>)iMsg
                        error:(NSDictionary *)info {
    NSLog(@"TODO: suspendInstantMessage");
}

@end

@implementation DIMCommonPacker (Checking)

- (nullable id<MKEncryptKey>)messageKey:(id<MKMID>)user {
    NSAssert([user isUser], @"user ID error: %@", user);
    DIMFacebook *facebook = [self facebook];
    //return [facebook publicKeyForEncryption:user];
    NSArray<id<MKMDocument>> *docs = [facebook documentsForID:user];
    id<MKMVisa> visa = [DIMDocumentUtils lastVisa:docs];
    if (visa) {
        return [visa publicKey];
    }
    id<MKMMeta> meta = [facebook metaForID:user];
    if (meta) {
        id<MKVerifyKey> metaKey = [meta publicKey];
        if ([meta conformsToProtocol:@protocol(MKEncryptKey)]) {
            return (id<MKEncryptKey>)metaKey;
        }
    }
    return nil;
}

- (BOOL)checkSenderInReliableMessage:(id<DKDReliableMessage>)rMsg {
    id<MKMID> sender = [rMsg sender];
    NSAssert([sender isUser], @"sender error: %@", sender);
    // check sender's meta & document
    id<MKMVisa> visa = DIMMessageGetVisa(rMsg);
    if (visa) {
        // first handshake?
        id<MKMID> vid = MKMIDParse([visa objectForKey:@"did"]);
        NSAssert([vid isEqual:sender], @"visa ID not match: %@", sender);
        return [vid isEqual:sender];
    } else if ([self messageKey:sender]) {
        // sender is OK
        return YES;
    }
    // sender not ready, suspend message for waiting document
    NSDictionary *error = @{
        @"message": @"verify key not found",
        @"user": sender.string,
    };
    [self suspendReliableMessage:rMsg error:error];  // rMsg.put("error", error);
    return NO;
}

//- (BOOL)checkReceiverInReliableMessage:(id<DKDReliableMessage>)sMsg {
//    id<MKMID> receiver = [sMsg receiver];
//    // check group
//    id<MKMID> group = MKMIDParse([sMsg objectForKey:@"group"]);
//    if (!group && [receiver isGroup]) {
//        /// Transform:
//        ///     (B) => (J)
//        ///     (D) => (G)
//        group = receiver;
//    }
//    if (!group || [group isBroadcast]) {
//        /// A, C - personal message (or hidden group message)
//        //      the packer will call the facebook to select a user from local
//        //      for this receiver, if no user matched (private key not found),
//        //      this message will be ignored;
//        /// E, F, G - broadcast group message
//        //      broadcast message is not encrypted, so it can be read by anyone.
//        return YES;
//    }
//    /// H, J, K - group message
//    //      check for received group message
//    NSArray<id<MKMID>> *members = [self membersOfGroup:group];
//    if ([members count] > 0) {
//        // group is ready
//        return YES;
//    }
//    // group not ready, suspend message for waiting members
//    NSDictionary *error = @{
//        @"message": @"group not ready",
//        @"group": group.string,
//    };
//    [self suspendReliableMessage:sMsg error:error];  // rMsg.put("error", error);
//    return NO;
//}

- (BOOL)checkReceiverInInstantMessage:(id<DKDInstantMessage>)iMsg {
    id<MKMID> receiver = [iMsg receiver];
    if ([receiver isBroadcast]) {
        // broadcast message
        return YES;
    } else if ([receiver isGroup]) {
        // NOTICE: station will never send group message, so
        //         we don't need to check group info here; and
        //         if a client wants to send group message,
        //         that should be sent to a group bot first,
        //         and the bot will split it for all members.
        return NO;
    } else if ([self messageKey:receiver]) {
        // receiver is OK
        return YES;
    }
    // receiver not ready, suspend message for waiting document
    NSDictionary *error = @{
        @"message": @"encrypt key not found",
        @"user": receiver.string,
    };
    [self suspendInstantMessage:iMsg error:error];  // iMsg.put("error", error);
    return NO;
}

@end

@implementation DIMCommonPacker (Attachments)

- (BOOL)checkAttachments:(id<DKDReliableMessage>)rMsg {
    id<DIMArchivist> archivist = [self archivist];
    NSAssert(archivist, @"archivist not ready");
    id<MKMID> sender = [rMsg sender];
    // [Meta Protocol]
    id<MKMMeta> meta = DIMMessageGetMeta(rMsg);
    if (meta) {
        [archivist saveMeta:meta forID:sender];
    }
    // [Visa Protocol]
    id<MKMVisa> visa = DIMMessageGetVisa(rMsg);
    if (visa) {
        [archivist saveDocument:visa forID:sender];
    }
    //
    //  TODO: check [Visa Protocol] before calling this
    //        make sure the sender's meta(visa) exists
    //        (do it by application)
    //
    return YES;
}

@end
