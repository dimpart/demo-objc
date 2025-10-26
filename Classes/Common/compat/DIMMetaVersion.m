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
//  DIMMetaVersion.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/11.
//

#import "DIMAddressC.h"

#import "DIMMetaVersion.h"

NSString * _Nullable DIMMetaVersionParseString(id type) {
    if ([type isKindOfClass:[NSString class]]) {
        return type;
    } else if ([type isKindOfClass:[NSNumber class]]) {
        return [type stringValue];
    } else {
        assert(type == nil);
        return nil;
    }
}

BOOL DIMMetaVersionHasSeed(id type) {
    UInt8 version = DIMMetaVersionParseInt(type, 0);
    return 0 < version && (version & DIMMetaVersion_MKM) == DIMMetaVersion_MKM;
}

UInt8 DIMMetaVersionParseInt(id type, UInt8 defaultValue) {
    if (!type) {
        return defaultValue;
    } else if ([type isKindOfClass:[NSNumber class]]) {
        return [type unsignedCharValue];
    } else if ([type isKindOfClass:[NSString class]]) {
        // fixed values
        if ([type isEqualToString:@"MKM"] || [type isEqualToString:@"mkm"]) {
            return DIMMetaVersion_MKM;
        } else if ([type isEqualToString:@"BTC"] || [type isEqualToString:@"btc"]) {
            return DIMMetaVersion_BTC;
        } else if ([type isEqualToString:@"ExBTC"]) {
            return DIMMetaVersion_ExBTC;
        } else if ([type isEqualToString:@"ETH"] || [type isEqualToString:@"eth"]) {
            return DIMMetaVersion_ETH;
        } else if ([type isEqualToString:@"ExETH"]) {
            return DIMMetaVersion_ExETH;
        }
        // TODO: other algorithms
    } else {
        return -1;
    }
    return [type intValue];
}
