// license: https://mit-license.org
//
//  Ming-Ke-Ming : Decentralized User Identity Authentication
//
//                               Written in 2020 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2020 Albert Moky
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
//  DIMAddressC.m
//  DIMPlugins
//
//  Created by Albert Moky on 2020/12/12.
//  Copyright © 2020 Albert Moky. All rights reserved.
//

#import "DIMCache.h"
#import "DIMNetworkID.h"

#import "DIMAddressC.h"

@implementation DIMCompatibleAddressFactory

- (id<MKMAddress>)parse:(NSString *)address {
    NSComparisonResult res;
    NSUInteger len = [address length];
    if (len == 0) {
        NSAssert(false, @"address empty");
        return nil;
    } else if (len == 8) {
        // "anywhere"
        res = [MKMAnywhere.string caseInsensitiveCompare:address];
        if (res == NSOrderedSame) {
            return MKMAnywhere;
        }
    } else if (len == 10) {
        // "everywhere"
        res = [MKMEverywhere.string caseInsensitiveCompare:address];
        if (res == NSOrderedSame) {
            return MKMEverywhere;
        }
    }
    id<MKMAddress> addr;
    if (26 <= len && len <= 35) {
        // BTC address
        addr = [DIMBTCAddress parse:address];
    } else if (len == 42) {
        // ETH address
        addr = [DIMETHAddress parse:address];
    } else {
        NSAssert(false, @"invalid address: %@", address);
        addr = nil;
    }
    //
    //  TODO: parse for other types of address
    //
    if (addr == nil && 4 <= len && len <= 64) {
        return [[DIMUnknownAddress alloc] initWithString:address];
    }
    NSAssert(addr, @"invalid address: %@", address);
    return addr;
}

@end

@implementation DIMCompatibleAddressFactory (thanos)

- (NSInteger)reduceMemory {
    NSUInteger snap = 0;
    snap = DIMThanos(self.addresses, snap);
    return snap;
}

@end

#pragma mark -

@implementation DIMUnknownAddress

- (MKMEntityType)network {
    return MKMEntityType_User;  // 0
}

@end
