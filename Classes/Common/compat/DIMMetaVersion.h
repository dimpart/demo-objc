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
//  DIMMetaVersion.h
//  DIMClient
//
//  Created by Albert Moky on 2023/12/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/*
 *  @enum MKMMetaVersion
 *
 *  @abstract Defined for algorithm that generating address.
 *
 *  @discussion Generate and check ID/Address
 *
 *      MKMMetaVersion_MKM give a seed string first, and sign this seed to get
 *      fingerprint; after that, use the fingerprint to generate address.
 *      This will get a firmly relationship between (username, address and key).
 *
 *      MKMMetaVersion_BTC use the key data to generate address directly.
 *      This can build a BTC address for the entity ID (no username).
 *
 *      MKMMetaVersion_ExBTC use the key data to generate address directly, and
 *      sign the seed to get fingerprint (just for binding username and key).
 *      This can build a BTC address, and bind a username to the entity ID.
 *
 *  Bits:
 *      0000 0001 - this meta contains seed as ID.name
 *      0000 0010 - this meta generate BTC address
 *      0000 0100 - this meta generate ETH address
 *      ...
 */
typedef NS_ENUM(UInt8, DIMMetaVersion) {
    
    DIMMetaVersion_DEFAULT = 0x01,
    DIMMetaVersion_MKM     = 0x01,  // 0000 0001
    
    DIMMetaVersion_BTC     = 0x02,  // 0000 0010
    DIMMetaVersion_ExBTC   = 0x03,  // 0000 0011
    
    DIMMetaVersion_ETH     = 0x04,  // 0000 0100
    DIMMetaVersion_ExETH   = 0x05   // 0000 0101
};
typedef UInt8 MKMMetaVersion;

#ifdef __cplusplus
extern "C" {
#endif

NSString * _Nullable DIMMetaVersionParseString(id type);

BOOL DIMMetaVersionHasSeed(id type);

UInt8 DIMMetaVersionParseInt(id type, UInt8 defaultValue);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

NS_ASSUME_NONNULL_END
