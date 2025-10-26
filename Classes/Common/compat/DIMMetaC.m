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
//  DIMMetaC.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/11.
//

#import "DIMMetaC.h"

@implementation DIMCompatibleMetaFactory

// Override
- (nullable id<MKMMeta>)parseMeta:(NSDictionary *)info {
    id<MKMMeta> meta = nil;
    MKMSharedAccountExtensions *ext = [MKMSharedAccountExtensions sharedInstance];
    NSString *version = [ext.helper getMetaType:info defaultValue:nil];
    if ([version length] == 0) {
        NSAssert(false, @"meta type error: %@", info);
    } else if ([version isEqualToString:@"MKM"] ||
               [version isEqualToString:@"mkm"] ||
               [version isEqualToString:@"1"]) {
        meta = [[DIMDefaultMeta alloc] initWithDictionary:info];
    } else if ([version isEqualToString:@"BTC"] ||
               [version isEqualToString:@"btc"] ||
               [version isEqualToString:@"2"]) {
        meta = [[DIMBTCMeta alloc] initWithDictionary:info];
    } else if ([version isEqualToString:@"ETH"] ||
               [version isEqualToString:@"eth"] ||
               [version isEqualToString:@"4"]) {
        meta = [[DIMETHMeta alloc] initWithDictionary:info];
    } else {
        // TODO: other types of meta
        NSAssert(false, @"meta type not supported: %@", version);
    }
    return [meta isValid] ? meta : nil;
}

@end
