//
//  MultiplayerWaitingRoomLayer.m
//  DoTheDancing-iPad
//
//  Created by Michael Gao on 7/31/13.
//
//

#import "MultiplayerWaitingRoomLayer.h"
#import "GameManager.h"

@interface MultiplayerWaitingRoomLayer()

@property (nonatomic) CGSize screenSize;
@property (nonatomic, strong) CCSpriteBatchNode *batchNode;
@property (nonatomic, strong) GameManager *gm;

// sprite management
@property (nonatomic, strong) CCSprite *loadingDots;
@property (nonatomic, strong) CCSprite *promptBg;
@property (nonatomic, strong) CCLabelBMFont *promptLabel;
@property (nonatomic, strong) CCMenu *startMenu;

// matchmaking
@property (nonatomic, strong) NSMutableArray *connectedPlayers;
@property (nonatomic, strong) NSMutableArray *playerAvatars;

@end

@implementation MultiplayerWaitingRoomLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        self.screenSize = [CCDirector sharedDirector].winSize;
        self.batchNode = [CCSpriteBatchNode batchNodeWithFile:@"spritesheet.pvr.ccz"];
        [self addChild:self.batchNode z:5];
        self.gm = [GameManager sharedGameManager];

        self.connectedPlayers = [NSMutableArray array];
        self.playerAvatars = [NSMutableArray array];

        [self displayBackground];
        [self displayTopBar];
        [self displayBackButton];

        [self displayWaitingPrompt];

        [self setupMatchmaking];
    }
    
    return self;
}

-(void)displayBackground {
    CCSprite *bg = [CCSprite spriteWithFile:@"mainmenu_bg.png"];
    bg.anchorPoint = ccp(0.5, 1);
    bg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height);
    [self addChild:bg z:-1];
}

-(void)displayTopBar {
    // top banner bg
    CCSprite *topBannerBg = [CCSprite spriteWithSpriteFrameName:@"instructions_top_banner.png"];
    topBannerBg.anchorPoint = ccp(0, 1);
    topBannerBg.position = ccp(0, self.screenSize.height);
    [self addChild:topBannerBg];
    
    // multiplayer label
    CCLabelBMFont *multiplayerLabel = [CCLabelBMFont labelWithString:@"Waiting Room" fntFile:@"economica-bold_64.fnt"];
    multiplayerLabel.color = ccc3(249, 185, 56);
    multiplayerLabel.position = ccp(self.screenSize.width * 0.5, topBannerBg.contentSize.height * 0.5);
    [topBannerBg addChild:multiplayerLabel];
}

-(void)displayBackButton {
    CCMenuItemSprite *backButton = [CCMenuItemSprite itemWithNormalSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_back1.png"] selectedSprite:[CCSprite spriteWithSpriteFrameName:@"instructions_button_back2.png"] block:^(id sender) {
        self.gm.server.quitReason = QuitReasonUserQuit;
        
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMainMenu];
    }];
    backButton.anchorPoint = ccp(0, 1);
    backButton.position = ccp(0, self.screenSize.height * 0.992);
    
    CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
    menu.position = ccp(0, 0);
    [self addChild:menu];
}

-(void)displayWaitingPrompt {
    // background
    self.promptBg = [CCSprite spriteWithSpriteFrameName:@"instructions_bg.png"];
    self.promptBg.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.7);
    [self addChild:self.promptBg];
    
    // label
    self.promptLabel = [CCLabelBMFont labelWithString:@"Waiting for dancers..." fntFile:@"economica-bold_40.fnt"];
    self.promptLabel.color = ccc3(56, 56, 56);
    self.promptLabel.anchorPoint = ccp(0.5, 1);
    self.promptLabel.position = ccp(self.promptBg.contentSize.width * 0.5, self.promptBg.contentSize.height * 0.9);
    [self.promptBg addChild:self.promptLabel];
    
    // loading dots
    self.loadingDots = [CCSprite spriteWithSpriteFrameName:@"waitingroom_loader1.png"];
    self.loadingDots.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.7);
    [self.batchNode addChild:self.loadingDots];
    
    // animate loading dots
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:@[[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"waitingroom_loader1.png"],
                              [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"waitingroom_loader2.png"],
                              [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"waitingroom_loader3.png"],
                              [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"waitingroom_loader4.png"],
                              [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"waitingroom_loader5.png"]]
                                                              delay:0.5];
    animation.restoreOriginalFrame = YES;
    id action = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:animation]];
    [self.loadingDots runAction:action];
}

-(void)setupMatchmaking {
    CCLOG(@"host: start accepting connections");
    self.gm.server = [[MatchmakingServer alloc] init];
    self.gm.server.delegate = self;
    self.gm.server.quitReason = QuitReasonConnectionDropped;       // set up default quit reason
    [self.gm.server startAcceptingConnectionsForSessionID:SESSION_ID];
    
    [self updateAvatars];
}

-(void)updateAvatars {
    while (self.playerAvatars.count < self.connectedPlayers.count) {
        CCSprite *avatar = [CCSprite spriteWithSpriteFrameName:@"waitingroom_avatar1.png"];
        avatar.position = ccp(self.screenSize.width * 0.15 * (self.playerAvatars.count+1), self.screenSize.height * 0.35);
        
        [self.playerAvatars addObject:avatar];
        [self.batchNode addChild:avatar];
    }
}

#pragma mark - MatchmakingServerDelegate

- (void)matchmakingServerClientDidConnect:(NSString *)peerID
{
    [self.connectedPlayers addObject:peerID];
    
    // update displayed avatars for host
    [self updateAvatars];
}

- (void)matchmakingServerClientDidDisconnect:(NSString *)peerID
{
    /* update displayed avatars for host */
    NSInteger peerAvatarIndex = 0;
    for (NSString *currentPeerId in self.connectedPlayers) {
        if ([currentPeerId isEqualToString:peerID]) {
            CCSprite *clientAvatar = self.playerAvatars[peerAvatarIndex];
            [clientAvatar removeFromParentAndCleanup:YES];
            [self.connectedPlayers removeObjectAtIndex:peerAvatarIndex];
            
            break;
        }
        
        peerAvatarIndex++;
    }
    
    // move proceeding avatars to the left
    for (int i=peerAvatarIndex+1; i<self.playerAvatars.count; i++) {
        CCSprite *currentAvatar = self.playerAvatars[i];
        currentAvatar.position = ccp(currentAvatar.position.x - self.screenSize.width * 0.15, currentAvatar.position.y);
    }
    
    [self.playerAvatars removeObjectAtIndex:peerAvatarIndex];
}

- (void)matchmakingServerSessionDidEnd
{
    // return to host or join page
    [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMainMenu];
}

- (void)matchmakingServerNoNetwork
{
    self.gm.server.quitReason = QuitReasonNoNetwork;
}


@end
