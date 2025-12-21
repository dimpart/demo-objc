// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
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
//  Common.h
//  DIMClient
//
//  Created by Albert Moky on 2019/2/25.
//  Copyright © 2019 DIM Group. All rights reserved.
//

#if !defined(__DIM_COMMON__)
#define __DIM_COMMON__ 1

//
//  MingKeMing
//

#import <DIMClient/DIMBot.h>
#import <DIMClient/DIMStation.h>
#import <DIMClient/DIMServiceProvider.h>

//
//  Utils
//

#import <DIMClient/DIMAccountUtils.h>
#import <DIMClient/DIMMessageUtils.h>
#import <DIMClient/DIMCache.h>
#import <DIMClient/DIMCheckers.h>
#import <DIMClient/DIMDigestX.h>

//
//  Compat
//

#import <DIMClient/DIMNetworkID.h>
#import <DIMClient/DIMAddressC.h>
#import <DIMClient/DIMEntityID.h>
#import <DIMClient/DIMMetaVersion.h>
#import <DIMClient/DIMMetaC.h>
#import <DIMClient/DIMCompressor.h>
#import <DIMClient/DIMCompatible.h>
#import <DIMClient/DIMCOmmonLoaders.h>

//
//  DBI
//

#import <DIMClient/DIMAccountDBI.h>
#import <DIMClient/DIMMessageDBI.h>
#import <DIMClient/DIMSessionDBI.h>

//
//  Contents
//

#import <DIMClient/DIMApplicationContent.h>

//
//  Commands
//

#import <DIMClient/DIMAnsCommand.h>
#import <DIMClient/DIMHandshakeCommand.h>
#import <DIMClient/DIMLoginCommand.h>
#import <DIMClient/DIMReportCommand.h>
#import <DIMClient/DIMMuteCommand.h>
#import <DIMClient/DIMBlockCommand.h>
#import <DIMClient/DIMGroupCommand.h>

//
//
//

#import <DIMClient/MKMAnonymous.h>
#import <DIMClient/DIMRegister.h>
#import <DIMClient/DIMAddressNameServer.h>
#import <DIMClient/DIMEntityChecker.h>
#import <DIMClient/DIMCommonArchivist.h>
#import <DIMClient/DIMCommonFacebook.h>
#import <DIMClient/DIMSession.h>
#import <DIMClient/DIMCommonPacker.h>
#import <DIMClient/DIMCommonProcessor.h>
#import <DIMClient/DIMCommonMessenger.h>

#endif /* ! __DIM_COMMON__ */
