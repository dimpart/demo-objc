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
//  DIMStation.m
//  DIMCore
//
//  Created by Albert Moky on 2018/10/13.
//  Copyright © 2018 DIM Group. All rights reserved.
//

#import "DIMAccountUtils.h"
#import "DIMServiceProvider.h"

#import "DIMStation.h"

id<MKMID> MKMAnyStation    = nil;
id<MKMID> MKMEveryStations = nil;

#define BroadcastIDCreate(N, A)                                                \
                [[MKMID alloc] initWithString:MKMIDConcat(N, A, nil)           \
                                         name:(N)                              \
                                      address:(A)                              \
                                     terminal:nil]                             \
                                             /* EOF 'BroadcastIDCreate(N, A)' */

void MKMInitializeBroadcastStationIdentifiers(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        MKMAnyStation    = BroadcastIDCreate(@"station",  MKMAnywhere);
        MKMEveryStations = BroadcastIDCreate(@"stations", MKMEverywhere);

    });
}

__attribute__((constructor))
static void autoInitializeStationIdentifiers(void) {
    MKMInitializeBroadcastStationIdentifiers();
}

@interface DIMStation () {
    
    NSString *_host;
    UInt16 _port;
}

// protected
@property (nonatomic, strong, nullable) id<MKMUser> user;

@property (strong, nonatomic, nullable) NSString *host;  // Domain/IP
@property (nonatomic) UInt16 port;                       // default: 9394

@property (strong, nonatomic, nullable) id<MKMID> provider;

@end

@implementation DIMStation

- (instancetype)init {
    NSAssert(false, @"DON'T call me");
    id<MKMID> did = MKMAnyStation;
    return [self initWithID:did];
}

/* designated initializer */
- (instancetype)initWithID:(id<MKMID>)did
                      host:(NSString *)IP
                      port:(UInt16)port {
    NSAssert(did.type == MKMEntityType_Station || did.type == MKMEntityType_Any, @"station ID error: %@", did);
    if (self = [super init]) {
        self.user = [[DIMUser alloc] initWithID:did];
        self.host = IP;
        self.port = port;
        self.provider = nil;
    }
    return self;
}

- (instancetype)initWithID:(id<MKMID>)did {
    NSString *ip = nil;
    return [self initWithID:did host:ip port:0];
}

- (instancetype)initWithHost:(NSString *)IP port:(UInt16)port {
    return [self initWithID:MKMAnyStation host:IP port:port];
}

- (id)copyWithZone:(nullable NSZone *)zone {
    DIMStation *server = [[self class] allocWithZone:zone];
    if (server) {
        server.user = _user;
        server.host = _host;
        server.port = _port;
        server.provider = _provider;
    }
    return server;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ ID=\"%@\" host=\"%@\" port=%u />", [self class], [self identifier], [self host], [self port]];
}

- (NSString *)debugDescription {
    return [self description];
}

- (BOOL)isEqual:(id)other {
    if ([other conformsToProtocol:@protocol(MKMStation)]) {
        return DIMSameStation(other, self);;
    } else if ([other conformsToProtocol:@protocol(MKMUser)]) {
        return [_user isEqual:other];
    } else if ([other conformsToProtocol:@protocol(MKMID)]) {
        return [_user.identifier isEqual:other];
    }
    return NO;
}

// Override
- (id<MKMDocument>)profile {
    NSArray<id<MKMDocument>> *docs = [self documents];
    return DIMDocumentGetLast(docs, @"*");
}

// Override
- (NSString *)host {
    NSString *IP = _host;
    if (!IP) {
        id<MKMDocument> doc = [self profile];
        id str = [doc propertyForKey:@"host"];
        _host = IP = MKConvertString(str, nil);
    }
    return IP;
}

// Override
- (UInt16)port {
    UInt16 po = _port;
    if (po == 0) {
        id<MKMDocument> doc = [self profile];
        id num = [doc propertyForKey:@"port"];
        _port = po = MKConvertUInt16(num, 0);
    }
    return po;
}

// Override
- (id<MKMID>)provider {
    id<MKMDocument> doc = [self profile];
    if (doc) {
        id ISP = [doc propertyForKey:@"provider"];
        return MKMIDParse(ISP);
    }
    return nil;
}

// Override
- (void)setIdentifier:(id<MKMID>)did {
    id<MKMEntityDataSource> delegate = [self dataSource];
    id<MKMUser> inner = [[DIMUser alloc] initWithID:did];
    [inner setDataSource:delegate];
    _user = inner;
}

#pragma mark Entity

// Override
- (id<MKMID>)identifier {
    return [_user identifier];
}

// Override
- (MKMEntityType)type {
    return [_user type];
}

// Override
- (id<MKMEntityDataSource>)dataSource {
    return [_user dataSource];
}

// Override
- (void)setDataSource:(id<MKMEntityDataSource>)dataSource {
    [_user setDataSource:dataSource];
}

// Override
- (id<MKMMeta>)meta {
    return [_user meta];
}

// Override
- (NSArray<id<MKMDocument>> *)documents {
    return [_user documents];
}

#pragma mark User

// Override
- (BOOL)verifyVisa:(id<MKMVisa>)visa {
    return [_user verifyVisa:visa];
}

// Override
- (BOOL)verify:(NSData *)data withSignature:(NSData *)signature {
    return [_user verify:data withSignature:signature];
}

// Override
- (id<DIMEncryptedBundle>)encryptBundle:(NSData *)plaintext {
    return [_user encryptBundle:plaintext];
}

// Override
- (NSSet<NSString *> *)terminals {
    return [_user terminals];
}

#pragma mark Local User

// Override
- (NSArray<id<MKMID>> *)contacts {
    return [_user contacts];
}

// Override
- (nullable id<MKMVisa>)signVisa:(id<MKMVisa>)visa {
    return [_user signVisa:visa];
}

// Override
- (NSData *)sign:(NSData *)data {
    return [_user sign:data];
}

// Override
- (nullable NSData *)decryptBundle:(id<DIMEncryptedBundle>)bundle {
    return [_user decryptBundle:bundle];
}

@end
