// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
//
//                               Written in 2018 by Moky <albert.moky@gmail.com>
//
// =============================================================================
// The MIT License (MIT)
//
// Copyright (c) 2018 Albert Moky
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
//  DIMStation.h
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import <DIMSDK/DIMSDK.h>

NS_ASSUME_NONNULL_BEGIN

//
//  Broadcast IDs
//

FOUNDATION_EXPORT id<MKMID> MKMAnyStation;     // "station@anywhere"
FOUNDATION_EXPORT id<MKMID> MKMEveryStations;  // "stations@everywhere"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Initializes broadcast IDs.
 *
 * This function is designed to be automatically called before main()
 * using the GCC/Clang `__attribute__((constructor))` extension.
 *
 * Internally, it employs `dispatch_once` to ensure that the actual
 * initialization logic (creating NSString objects) is executed
 * exactly once across the application's lifecycle, and in a thread-safe manner.
 *
 * Manual invocation of this function is generally NOT required,
 * as it's automatically handled at program startup. It is primarily
 * exposed for extreme edge cases where the automatic invocation might
 * be circumvented (e.g., in highly specialized non-standard environments),
 * or for specific debugging/testing scenarios if necessary.
 * Multiple manual calls will still only result in a single initialization.
 */
void MKMInitializeBroadcastStationIdentifiers(void);

#ifdef __cplusplus
} /* end of extern "C" */
#endif

/**
 *  DIM Server
 *  ~~~~~~~~~~
 */
@protocol MKMStation <MKMUser>

// Station Document
@property (readonly, strong, nonatomic, nullable) __kindof id<MKMDocument> profile;

@property (readonly, strong, nonatomic, nullable) NSString *host;  // Domain/IP
@property (readonly, nonatomic) UInt16 port;                       // Default: 9394

// Provider: ISP (Station group)
@property (readonly, strong, nonatomic, nullable) id<MKMID> provider;

- (void)setIdentifier:(id<MKMID>)sid;

@end

@interface DIMStation : NSObject <MKMStation, NSCopying>

- (instancetype)initWithID:(id<MKMID>)did
                      host:(NSString *)IP
                      port:(UInt16)port
NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithID:(id<MKMID>)did;

- (instancetype)initWithHost:(NSString *)IP port:(UInt16)port;

@end

NS_ASSUME_NONNULL_END
