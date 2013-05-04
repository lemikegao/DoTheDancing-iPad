//
//  SearchingForDeviceLayer.m
//  DoTheDancing-iPad
//
//  Created by Michael Gao on 5/4/13.
//
//

#import "SearchingForDeviceLayer.h"
#import "GameManager.h"

@interface SearchingForDeviceLayer()

@property (nonatomic) CGSize screenSize;

@end

@implementation SearchingForDeviceLayer

-(id)init {
    self = [super init];
    if (self != nil) {
        _screenSize = [CCDirector sharedDirector].winSize;
        
        [self displaySearchingForDevice];
        [self displayBackButton];
        [self startSearchingForDevice];
    }
    
    return self;
}

-(void)displaySearchingForDevice {
    CCLabelTTF *searchingLabel = [CCLabelTTF labelWithString:@"Searching for device..." fontName:@"Helvetica" fontSize:40];
    searchingLabel.position = ccp(self.screenSize.width * 0.5, self.screenSize.height * 0.5);
    [self addChild:searchingLabel];
}

-(void)displayBackButton {
    CCMenuItemLabel *backButton = [CCMenuItemLabel itemWithLabel:[CCLabelTTF labelWithString:@"Back" fontName:@"Helvetica" fontSize:40] block:^(id sender) {
        [GameManager sharedGameManager].matchmakingPeer.quitReason = QuitReasonNone;
        [[GameManager sharedGameManager] runSceneWithID:kSceneTypeMainMenu];
    }];
    backButton.anchorPoint = ccp(0, 1);
    backButton.position = ccp(self.screenSize.width * 0.03, self.screenSize.height * 0.97);
    
    CCMenu *menu = [CCMenu menuWithItems:backButton, nil];
    menu.position = ccp(0, 0);
    [self addChild:menu];
}

-(void)startSearchingForDevice {
    GameManager *gm = [GameManager sharedGameManager];
    gm.matchmakingPeer = [[MatchmakingPeer alloc] init];
    gm.matchmakingPeer.delegate = self;
    [gm.matchmakingPeer startSearchingForPeersWithSessionID:SESSION_ID];
}

@end
