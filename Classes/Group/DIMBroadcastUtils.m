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
//  DIMBroadcastUtils.m
//  DIMCore
//
//  Created by Albert Moky on 2023/12/7.
//  Copyright © 2023 DIM Group. All rights reserved.
//

#import "DIMBroadcastUtils.h"

@implementation DIMBroadcastUtils

+ (NSString *)groupSeed:(id<MKMID>)group {
    NSString *name = [group name];
    if (name) {
        NSUInteger len = [name length];
        if (len == 0) {
            return nil;
        } else if (len == 8) {
            NSComparisonResult res = [name caseInsensitiveCompare:@"everyone"];
            if (res == NSOrderedSame) {
                return nil;
            }
        }
    }
    return name;
}

+ (id<MKMID>)broadcastFounder:(id<MKMID>)group {
    NSString *name = [self groupSeed:group];
    if (!name) {
        // Consensus: the founder of group 'everyone@everywhere'
        //            'Albert Moky'
        return MKMIDParse(@"moky@anywhere");
    } else {
        // DISCUSS: who should be the founder of group 'xxx@everywhere'?
        //          'anyone@anywhere', or 'xxx.founder@anywhere'
        return MKMIDParse([name stringByAppendingString:@".founder@anywhere"]);
    }
}

+ (id<MKMID>)broadcastOwner:(id<MKMID>)group {
    NSString *name = [self groupSeed:group];
    if (!name) {
        // Consensus: the owner of group 'everyone@everywhere'
        //            'anyone@anywhere'
        return MKMAnyone;
    } else {
        // DISCUSS: who should be the owner of group 'xxx@everywhere'?
        //          'anyone@anywhere', or 'xxx.owner@anywhere'
        return MKMIDParse([name stringByAppendingString:@".owner@anywhere"]);
    }
}

+ (NSArray<id<MKMID>> *)broadcastMembers:(id<MKMID>)group {
    NSString *name = [self groupSeed:group];
    NSMutableArray<id<MKMID>> *mArray = [[NSMutableArray alloc] init];
    if (!name) {
        // Consensus: the member of group 'everyone@everywhere'
        //            'anyone@anywhere'
        [mArray addObject:MKMAnyone];
    } else {
        // DISCUSS: who should be the member of group 'xxx@everywhere'?
        //          'anyone@anywhere', or 'xxx.member@anywhere'
        id<MKMID> owner = MKMIDParse([name stringByAppendingString:@".owner@anywhere"]);
        id<MKMID> member = MKMIDParse([name stringByAppendingString:@".member@anywhere"]);
        [mArray addObject:owner];
        [mArray addObject:member];
    }
    return mArray;
}

@end
