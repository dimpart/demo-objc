// license: https://mit-license.org
//
//  DIM-SDK : Decentralized Instant Messaging Software Development Kit
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
//  DIMGroupDelegate.m
//  DIMClient
//
//  Created by Albert Moky on 2023/12/13.
//

#import <FiniteStateMachine/FiniteStateMachine.h>

#import "DIMClientFacebook.h"

#import "DIMGroupDelegate.h"

@interface _GroupBotsManager : SMRunner {
    
    NSArray<id<MKMID>> *_commonAssistants;
    
    NSMutableSet<id<MKMID>> *_candidates;                       // bot IDs to be check
    
    NSMutableDictionary<id<MKMID>, NSNumber *> *_respondTimes;  // bot IDs with respond time
    
    //__weak DIMCommonMessenger *_transceiver;
}

@property (weak, nonatomic, nullable) DIMCommonMessenger *messenger;

@property (readonly, weak, nonatomic, nullable) DIMCommonFacebook *facebook;

+ (instancetype)sharedInstance;

/**
 *  When received receipt command from the bot
 *  update the speed of this bot.
 */
- (BOOL)updateRespondTime:(id<DKDReceiptCommand>)body envelope:(id<DKDEnvelope>)head;

/**
 *  When received new config from current Service Provider,
 *  set common assistants of this SP.
 */
- (void)setCommonAssistants:(NSArray<id<MKMID>> *)bots;

- (NSArray<id<MKMID>> *)getAssistants:(id<MKMID>)group;

/**
 *  Get the fastest group bot
 */
- (id<MKMID>)getFastestAssistant:(id<MKMID>)group;

@end

@implementation _GroupBotsManager

static _GroupBotsManager *s_grp_bot_man = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_grp_bot_man = [[self alloc] init];
    });
    return s_grp_bot_man;
}

- (instancetype)init {
    if (self = [super init]) {
        _commonAssistants = [[NSArray alloc] init];
        _candidates = [[NSMutableSet alloc] init];
        _respondTimes = [[NSMutableDictionary alloc] init];
        // TODO: start a background thread
    }
    return self;
}

- (DIMCommonFacebook *)facebook {
    DIMCommonMessenger *messenger = [self messenger];
    return [messenger facebook];
}

- (BOOL)updateRespondTime:(id<DKDReceiptCommand>)body envelope:(id<DKDEnvelope>)head {
//    NSString *app = [body stringForKey:@"app" defaultValue:nil];
//    if (!app) {
//        app = [body stringForKey:@"app_id" defaultValue:nil];
//    }
//    if ([app isEqualToString:@"chat.dim.group.assistant"]) {} else {
//        return NO;
//    }
    //
    //  1. check sender
    //
    id<MKMID> sender = [head sender];
    if (sender.type != MKMEntityType_Bot) {
        return NO;
    }
    id<DKDEnvelope> originalEnvelope = [body originalEnvelope];
    if ([originalEnvelope isEqual:sender]) {} else {
        NSAssert([originalEnvelope.receiver isBroadcast],
                 @"sender error: %@, %@", sender, originalEnvelope.receiver);
        return NO;
    }
    //
    //  2. check send time
    //
    NSDate *time = [originalEnvelope time];
    if (!time) {
        NSAssert(false, @"original time not found: %@", body);
        return NO;
    }
    NSDate *now = [[NSDate alloc] init];
    NSTimeInterval duration = [now timeIntervalSince1970] - [time timeIntervalSince1970];
    if (duration <= 0) {
        NSAssert(false, @"receipt time error: %@", time);
        return NO;
    }
    //
    //  3. check duration
    //
    NSNumber *cached = [_respondTimes objectForKey:sender];
    if (cached && cached.doubleValue <= duration) {
        return NO;
    }
    [_respondTimes setObject:@(duration) forKey:sender];
    return YES;
}

- (void)setCommonAssistants:(NSArray<id<MKMID>> *)bots {
    NSLog(@"add group bots: %@ into %@", bots, _candidates);
    [_candidates addObjectsFromArray:bots];
    _commonAssistants = bots;
}

- (NSArray<id<MKMID>> *)getAssistants:(id<MKMID>)group {
    DIMFacebook *facebook = [self facebook];
    NSArray<id<MKMID>> *bots = [facebook getAssistants:group];
    if ([bots count] == 0) {
        return _commonAssistants;
    }
    [_candidates addObjectsFromArray:bots];
    return bots;
}

- (id<MKMID>)getFastestAssistant:(id<MKMID>)group {
    NSArray<id<MKMID>> *bots = [self getAssistants:group];
    if ([bots count] == 0) {
        NSLog(@"group bots not found: %@", group);
        return nil;
    }
    id<MKMID> prime = nil;
    NSNumber *primeDuration;
    NSNumber *duration;
    for (id<MKMID> ass in bots) {
        duration = [_respondTimes objectForKey:ass];
        if (!duration) {
            NSLog(@"group bot not respond yet, ignore it: %@, %@", ass, group);
            continue;
        } else if (!primeDuration) {
            // first responded bot
        } else if (primeDuration < duration) {
            NSLog(@"this bot %@ is slower than %@, skip it, %@", ass, prime, group);
            continue;
        }
        prime = ass;
        primeDuration = duration;
    }
    if (!prime) {
        prime = [bots firstObject];
        NSLog(@"no bot responded, thake the first one: %@, %@", bots, group);
    } else {
        NSLog(@"got the fastest bot with respond time: %@, %@, %@", primeDuration, prime, group);
    }
    return prime;
}

// Override
- (BOOL)process {
    DIMCommonFacebook *facebook = [self facebook];
    DIMCommonMessenger *messenger = [self messenger];
    if (!facebook || !messenger) {
        return NO;
    }
    //
    //  1. check session
    //
    id<DIMSession> session = [messenger session];
    if ([session sessionKey] == nil || ![session isActive]) {
        // not login yet
        return NO;
    }
    //
    //  2. get visa
    //
    id<MKMVisa> visa;
    @try {
        id<MKMUser> me = [facebook currentUser];
        visa = [me visa];
        if (!visa) {
            NSLog(@"failed to get visa: %@", me);
            return NO;
        }
    } @catch (NSException *exception) {
        NSLog(@"failed to get current user: %@", exception);
        return NO;
    //} @finally {
    //    <#Code that gets executed whether or not an exception is thrown#>
    }
    DIMEntityChecker *checker = [facebook entityChecker];
    //
    //  3. check candidates
    //
    NSSet<id<MKMID>> *bots = _candidates;
    _candidates = [[NSMutableSet alloc] init];
    for (id<MKMID> item in bots) {
        if ([_respondTimes objectForKey:item]) {
            // no need to check again
            NSLog(@"group bot already responded: %@", item);
            continue;
        }
        // no respond yet, try to push visa to the bot
        @try {
            [checker sendVisa:visa receiver:item updated:NO];
        } @catch (NSException *exception) {
            NSLog(@"failed to query assistant: %@, %@", item, exception);
        //} @finally {
        //    <#Code that gets executed whether or not an exception is thrown#>
        }
    }
    return NO;
}

@end

#pragma mark -

@implementation DIMGroupDelegate

- (instancetype)initWithFacebook:(DIMCommonFacebook *)facebook
                       messenger:(DIMCommonMessenger *)transceiver {
    if (self = [super initWithFacebook:facebook messenger:transceiver]) {
        _GroupBotsManager *man = [_GroupBotsManager sharedInstance];
        [man setMessenger:transceiver];
    }
    return self;
}

- (id<DIMArchivist>)archivist {
    DIMFacebook *facebook = [self facebook];
    return [facebook archivist];
}

- (nullable id<MKMBulletin>)getBulletin:(id<MKMID>)gid {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook getBulletin:gid];
}

- (BOOL)saveDocument:(id<MKMDocument>)doc {
    id<DIMArchivist> archivist = [self archivist];
    return [archivist saveDocument:doc];
}

- (BOOL)updateRespondTime:(id<DKDReceiptCommand>)body envelope:(id<DKDEnvelope>)head {
    _GroupBotsManager *man = [_GroupBotsManager sharedInstance];
    return [man updateRespondTime:body envelope:head];
}

//
//  Entity DataSource
//

// Override
- (nullable id<MKMMeta>)getMeta:(id<MKMID>)ID {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook getMeta:ID];
}

// Override
- (NSArray<id<MKMDocument>> *)getDocuments:(id<MKMID>)ID {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook getDocuments:ID];
}

//
//  Group DataSource
//

// Override
- (nullable id<MKMID>)getFounder:(id<MKMID>)group {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook getFounder:group];
}

// Override
- (nullable id<MKMID>)getOwner:(id<MKMID>)group {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook getOwner:group];
}

// Override
- (NSArray<id<MKMID>> *)getAssistants:(id<MKMID>)group {
    _GroupBotsManager *man = [_GroupBotsManager sharedInstance];
    return [man getAssistants:group];
}

// Override
- (NSArray<id<MKMID>> *)getMembers:(id<MKMID>)group {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook getMembers:group];
}

@end

@implementation DIMGroupDelegate (Members)

- (NSString *)buildGroupNameWithMembers:(NSArray<id<MKMID>> *)members {
    NSUInteger count = [members count];
    NSAssert(count > 0, @"members should not be empty here");
    DIMCommonFacebook *facebook = [self facebook];
    NSString *text = [facebook getName:members.firstObject];
    NSString *nickname;
    for (NSUInteger i = 1; i < count; ++i) {
        nickname = [facebook getName:[members objectAtIndex:i]];
        if ([nickname length] == 0) {
            continue;
        }
        text = [text stringByAppendingFormat:@", %@", nickname];
        if ([text length] > 32) {
            text = [text substringToIndex:28];
            return [text stringByAppendingString:@" ..."];
        }
    }
    return text;
}

- (BOOL)saveMembers:(NSArray<id<MKMID>> *)members group:(id<MKMID>)gid {
    DIMClientFacebook *facebook = [self facebook];
    return [facebook saveMembers:members forGroup:gid];
}

@end

@implementation DIMGroupDelegate (Assistants)

- (id<MKMID>)getFastestAssistant:(id<MKMID>)gid {
    _GroupBotsManager *man = [_GroupBotsManager sharedInstance];
    return [man getFastestAssistant:gid];
}

- (void)setCommonAssistants:(NSArray<id<MKMID>> *)bots {
    _GroupBotsManager *man = [_GroupBotsManager sharedInstance];
    [man setCommonAssistants:bots];
}

@end

@implementation DIMGroupDelegate (Administrators)

- (NSArray<id<MKMID>> *)getAdministrators:(id<MKMID>)gid {
    DIMClientFacebook *facebook = [self facebook];
    return [facebook getAdministrators:gid];
}

- (BOOL)saveAdministrators:(NSArray<id<MKMID>> *)admins group:(id<MKMID>)gid {
    DIMClientFacebook *facebook = [self facebook];
    return [facebook saveAdministrators:admins forGroup:gid];
}

@end

@implementation DIMGroupDelegate (Membership)

- (BOOL)isFounder:(id<MKMID>)uid group:(id<MKMID>)gid {
    NSAssert([uid isUser] && [gid isGroup], @"ID error: %@, %@", uid, gid);
    id<MKMID> founder = [self getFounder:gid];
    if (founder) {
        return [founder isEqual:uid];
    }
    // check member's public key with group's meta.key
    id<MKMMeta> gMeta = [self getMeta:gid];
    id<MKMMeta> uMeta = [self getMeta:uid];
    if (gMeta == nil || uMeta == nil) {
        NSAssert(false, @"failed to get meta for group: %@, user: %@", gid, uid);
        return NO;
    }
    return [DIMMetaUtils meta:gMeta matchPublicKey:uMeta.publicKey];
}

- (BOOL)isOwner:(id<MKMID>)uid group:(id<MKMID>)gid {
    NSAssert([uid isUser] && [gid isGroup], @"ID error: %@, %@", uid, gid);
    id<MKMID> owner = [self getOwner:gid];
    if (owner) {
        return [owner isEqual:uid];
    }
    if ([gid type] == MKMEntityType_Group) {
        // this is a polylogue
        return [self isFounder:uid group:gid];
    }
    NSAssert(false, @"only polylogue so far");
    return NO;
}

- (BOOL)isMember:(id<MKMID>)uid group:(id<MKMID>)gid {
    NSAssert([uid isUser] && [gid isGroup], @"ID error: %@, %@", uid, gid);
    NSArray<id<MKMID>> *members = [self getMembers:gid];
    return [members containsObject:uid];
}

- (BOOL)isAdministrator:(id<MKMID>)uid group:(id<MKMID>)gid {
    NSAssert([uid isUser] && [gid isGroup], @"ID error: %@, %@", uid, gid);
    NSArray<id<MKMID>> *admins = [self getAdministrators:gid];
    return [admins containsObject:uid];
}

- (BOOL)isAssistant:(id<MKMID>)bid group:(id<MKMID>)gid {
    NSAssert([bid isUser] && [gid isGroup], @"ID error: %@, %@", bid, gid);
    NSArray<id<MKMID>> *bots = [self getAssistants:gid];
    return [bots containsObject:bid];
}

@end

#pragma mark -

@interface DIMTripletsHelper ()

@property (strong, nonatomic) DIMGroupDelegate *delegate;

@end

@implementation DIMTripletsHelper

- (instancetype)init {
    NSAssert(false, @"DON'T call me!");
    DIMGroupDelegate *delegate = nil;
    return [self initWithDelegate:delegate];
}

/* designated initializer */
- (instancetype)initWithDelegate:(DIMGroupDelegate *)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
    }
    return self;
}

- (DIMCommonFacebook *)facebook {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate facebook];
}

- (DIMCommonMessenger *)messenger {
    DIMGroupDelegate *delegate = [self delegate];
    return [delegate messenger];
}

- (id<DIMAccountDBI>)database {
    DIMCommonFacebook *facebook = [self facebook];
    return [facebook database];
}

@end
