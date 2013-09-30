//
//  GameManager.h
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 11/17/12.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"
#import "SimpleAudioEngine.h"
#import "DanceMove.h"
#import "MatchmakingServer.h"
#import "AVCamCaptureManager.h"

@interface GameManager : NSObject <AVCamCaptureManagerDelegate>

@property (nonatomic) BOOL isMusicOn;
@property (nonatomic) BOOL isSoundEffectsOn;
@property (nonatomic) GameManagerSoundState managerSoundState;
@property (nonatomic, strong) NSMutableDictionary *listOfSoundEffectFiles;
@property (nonatomic, strong) NSMutableDictionary *soundEffectsState;

// individual dance moves practice
@property (nonatomic, strong) DanceMove *individualDanceMove;
@property (nonatomic, strong) NSMutableArray *danceMoveIterationResults;

// networking
@property (nonatomic, strong) MatchmakingServer *server;

// video recording
@property (nonatomic, strong) AVCamCaptureManager *captureManager;

+(GameManager*)sharedGameManager;
-(void)runSceneWithID:(SceneTypes)sceneID;
-(void)setupAudioEngine;
-(void)preloadSoundEffects;
//-(ALuint)playSoundEffect:(NSString*)soundEffectKey;
-(void)playSoundEffect:(NSString*)sfxFileName;
-(void)stopSoundEffect:(ALuint)soundEffectID;
-(void)playBackgroundTrack:(NSString*)trackFileName;
-(void)stopBackgroundTrack;

/* Video Recording */
-(void)setupVideoRecordingSession;
-(void)startRecording;
-(void)stopRecording;

@end
