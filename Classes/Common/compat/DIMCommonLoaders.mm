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
//  DIMCommonLoaders.m
//  DIMClient
//
//  Created by Albert Moky on 2025/10/25.
//

#import "DIMDigestX.h"

#import "DIMEntityID.h"
#import "DIMAddressC.h"
#import "DIMMetaC.h"

#import "DIMAnsCommand.h"
#import "DIMHandshakeCommand.h"
#import "DIMLoginCommand.h"
#import "DIMMuteCommand.h"
#import "DIMBlockCommand.h"
#import "DIMReportCommand.h"

#import "DIMCommonLoaders.h"

@implementation DIMCommonExtensionLoader

// Override
- (void)registerCustomizedFactories {
    
    // Application Customized
    DIMContentRegisterClass(DKDContentType_Customized, DIMCustomizedContent);
    DIMContentRegisterClass(DKDContentType_Application, DIMCustomizedContent);

    // [super registerCustomizedFactories];
}

// Override
- (void)registerCommandFactories {
    [super registerCommandFactories];
    
    // ANS
    DIMCommandRegisterClass(DIMCommand_ANS, DIMAnsCommand);
    
    // Handshake
    DIMCommandRegisterClass(DIMCommand_Handshake, DIMHandshakeCommand);
    // Login
    DIMCommandRegisterClass(DIMCommand_Login, DIMLoginCommand);
    
    // Mute
    DIMCommandRegisterClass(DIMCommand_Mute, DIMMuteCommand);
    // Block
    DIMCommandRegisterClass(DIMCommand_Block, DIMBlockCommand);
    
    // Report: online, offline
    DIMCommandRegisterClass(DIMCommand_Report,  DIMReportCommand);
    DIMCommandRegisterClass(DIMCommand_Online,  DIMReportCommand);
    DIMCommandRegisterClass(DIMCommand_Offline, DIMReportCommand);

    // Group command (deprecated)
    // ...
}

@end

@implementation DIMCommonPluginLoader

// Override
- (void)registerDigesters {
    [super registerDigesters];
    
    [self registerMD5Digester];
    [self registerSHA1Digester];
}

- (void)registerMD5Digester {
    // MD5
    id<MKMessageDigester> md = [[DIMMD5Digester alloc] init];
    [MKMD5 setDigester:md];
}

- (void)registerSHA1Digester {
    // SHA1
    id<MKMessageDigester> md = [[DIMSHA1Digester alloc] init];
    [MKSHA1 setDigester:md];
}

// Override
- (void)registerIDFactory {
    DIMEntityIDFactory *factory = [[DIMEntityIDFactory alloc] init];
    MKMIDSetFactory(factory);
}

// Override
- (void)registerAddressFactory {
    DIMCompatibleAddressFactory *factory = [[DIMCompatibleAddressFactory alloc] init];
    MKMAddressSetFactory(factory);
}

// Override
- (void)registerMetaFactories {
    id mkm = [[DIMCompatibleMetaFactory alloc] initWithType:MKMMetaType_MKM];
    id btc = [[DIMCompatibleMetaFactory alloc] initWithType:MKMMetaType_BTC];
    id eth = [[DIMCompatibleMetaFactory alloc] initWithType:MKMMetaType_ETH];
    
    MKMMetaSetFactory(@"1", mkm);
    MKMMetaSetFactory(@"2", btc);
    MKMMetaSetFactory(@"4", eth);
    
    MKMMetaSetFactory(@"mkm", mkm);
    MKMMetaSetFactory(@"btc", btc);
    MKMMetaSetFactory(@"eth", eth);
    
    MKMMetaSetFactory(@"MKM", mkm);
    MKMMetaSetFactory(@"BTC", btc);
    MKMMetaSetFactory(@"ETH", eth);
}

@end
