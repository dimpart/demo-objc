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
//  DIMCommonProcessor.m
//  DIMClient
//
//  Created by Albert Moky on 2025/10/28.
//

#import "DIMCommonFacebook.h"

#import "DIMCommonProcessor.h"

@implementation DIMCommonProcessor

- (__kindof DIMEntityChecker *)entityChecker {
    __kindof DIMFacebook *facebook = [self facebook];
    if ([facebook isKindOfClass:[DIMCommonFacebook class]]) {
        DIMCommonFacebook *cf = facebook;
        return [cf entityChecker];
    }
    NSAssert(facebook, @"facebook error: %@", facebook);
    return nil;
}

// Override
- (id<DIMContentProcessorFactory>)createFactoryWithFacebook:(DIMFacebook *)facebook
                                                  messenger:(DIMMessenger *)transceiver {
    id<DIMContentProcessorCreator> cpc;
    cpc = [self createCreatorWithFacebook:facebook messenger:transceiver];
    return [[DIMContentProcessorFactory alloc] initWithCreator:cpc];
}

- (id<DIMContentProcessorCreator>)createCreatorWithFacebook:(DIMFacebook *)facebook
                                                  messenger:(DIMMessenger *)transceiver {
    NSAssert(false, @"implement me!");
    return nil;
}

// private
- (BOOL)checkVisaTime:(id<DKDContent>)content withMessage:(id<DKDReliableMessage>)rMsg {
    DIMEntityChecker *checker = [self entityChecker];
    if (!checker) {
        NSAssert(false, @"should not happen");
        return NO;
    }
    BOOL docUpdated = NO;
    // check sender document time
    NSDate *lastDocTime = [rMsg dateForKey:@"SDT" defaultValue:nil];
    if (lastDocTime) {
        NSDate *now = [[NSDate alloc] init];
        if ([lastDocTime timeIntervalSince1970] > [now timeIntervalSince1970]) {
            // calibrate the clock
            lastDocTime = now;
        }
        id<MKMID> sender = [rMsg sender];
        docUpdated = [checker setLastDocumentTime:lastDocTime forIdentifier:sender];
        // check whether needs update
        if (docUpdated) {
            NSLog(@"checking for new visa: %@", sender);
            DIMFacebook *facebook = [self facebook];
            [facebook documents:sender];
        }
    }
    return docUpdated;
}

// Override
- (NSArray<id<DKDContent>> *)processContent:(id<DKDContent>)content withReliableMessageMessage:(id<DKDReliableMessage>)rMsg {
    NSArray<id<DKDContent>> *responses = [super processContent:content
                                    withReliableMessageMessage:rMsg];

    // check sender's document times from the message
    // to make sure the user info synchronized
    [self checkVisaTime:content withMessage:rMsg];
    
    return responses;
}

@end
