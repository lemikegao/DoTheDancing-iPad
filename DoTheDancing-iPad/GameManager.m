//
//  GameManager.m
//  chinAndCheeksTemplate
//
//  Created by Michael Gao on 11/17/12.
//
//

#import "GameManager.h"
#import "MainMenuScene.h"
#import "SearchingForDeviceScene.h"
#import "ConnectedToDeviceScene.h"
#import "DanceMoveSelectionScene.h"
#import "DanceMoveInstructionsScene.h"
#import "DanceMoveSeeInActionScene.h"
#import "DanceMoveDanceScene.h"
#import "DanceMoveResultsScene.h"
#import "MultiplayerWaitingRoomScene.h"

@interface GameManager()

@property (nonatomic) SceneTypes currentScene;
@property (nonatomic) BOOL hasAudioBeenInitialized;
@property (nonatomic, strong) SimpleAudioEngine *soundEngine;

@end

@implementation GameManager

static GameManager *_sharedGameManager = nil;   // singleton

+(GameManager*)sharedGameManager {
    @synchronized([GameManager class]) {
        if(!_sharedGameManager) {
            _sharedGameManager = [[self alloc] init];
        }
        return _sharedGameManager;
    }
    
    return nil;
}

+(id)alloc {
    @synchronized ([GameManager class]) {
        NSAssert(_sharedGameManager == nil, @"Attempted to allocate a second instance of the Game Manager singleton");
        _sharedGameManager = [super alloc];
        return _sharedGameManager;
    }
    
    return nil;
}

-(id)init {
    self = [super init];
    if (self) {
        CCLOG(@"Game Manager singleton->init");
        _isMusicOn = YES;
        _isSoundEffectsOn = YES;
        _currentScene = kSceneTypeNone;
        _hasAudioBeenInitialized = NO;
        _soundEngine = nil;
        _managerSoundState = kAudioManagerUninitialized;
        
        // individual dance moves practice
        _individualDanceMove = nil;
        _danceMoveIterationResults = nil;
        
        // networking
        _server = nil;
        
        // AVCamCaptureManager
        _captureManager = [[AVCamCaptureManager alloc] init];
        _captureManager.delegate = self;
    }
    
    return self;
}

-(void)preloadSoundEffects {
    // Wait to make sure soundEngine is initialized
    if ((self.managerSoundState != kAudioManagerReady) &&
        (self.managerSoundState != kAudioManagerFailed)) {
        
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((self.managerSoundState == kAudioManagerReady) ||
                (self.managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    if (self.managerSoundState == kAudioManagerReady) {
        if ([self.soundEngine isBackgroundMusicPlaying]) {
            [self.soundEngine stopBackgroundMusic];
        }
        [self.soundEngine preloadEffect:kStep1_SFX];
        [self.soundEngine preloadEffect:kStep2_SFX];
    }
}

-(void)playBackgroundTrack:(NSString*)trackFileName {
    // Wait to make sure soundEngine is initialized
    if ((self.managerSoundState != kAudioManagerReady) &&
        (self.managerSoundState != kAudioManagerFailed)) {
        
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((self.managerSoundState == kAudioManagerReady) ||
                (self.managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    if (self.managerSoundState == kAudioManagerReady) {
        if ([self.soundEngine isBackgroundMusicPlaying]) {
            [self.soundEngine stopBackgroundMusic];
        }
        [self.soundEngine preloadBackgroundMusic:trackFileName];
        [self.soundEngine playBackgroundMusic:trackFileName loop:YES];
    }
}

-(void)stopBackgroundTrack {
    if (self.managerSoundState == kAudioManagerReady) {
        [self.soundEngine stopBackgroundMusic];
    }
}

-(void)stopSoundEffect:(ALuint)soundEffectID {
    if (self.managerSoundState == kAudioManagerReady) {
        [self.soundEngine stopEffect:soundEffectID];
    }
}

-(void)playSoundEffect:(NSString*)sfxFileName {
    if (self.managerSoundState == kAudioManagerReady) {
        [self.soundEngine playEffect:sfxFileName];
    }
}

//-(ALuint)playSoundEffect:(NSString*)soundEffectKey {
//    ALuint soundID = 0;
//    if (self.managerSoundState == kAudioManagerReady) {
//        NSNumber *isSFXLoaded = [self.soundEffectsState objectForKey:soundEffectKey];
//        if ([isSFXLoaded boolValue] == SFX_LOADED) {
//            CCLOG(@"GameMgr: Playing SoundEffect: %@", soundEffectKey);
//            soundID = [self.soundEngine playEffect:[self.listOfSoundEffectFiles objectForKey:soundEffectKey]];
//        } else {
//            CCLOG(@"GameMgr: SoundEffect %@ is not loaded, cannot play.",soundEffectKey);
//        }
//    } else {
//        CCLOG(@"GameMgr: Sound Manager is not ready, cannot play %@", soundEffectKey);
//    }
//    
//    return soundID;
//}

- (NSString*)formatSceneTypeToString:(SceneTypes)sceneID {
    NSString *result = nil;
    switch(sceneID) {
        case kSceneTypeNone:
            result = @"kSceneTypeNone";
            break;
        case kSceneTypeMainMenu:
            result = @"kSceneTypeMainMenu";
            break;
        case kSceneTypeSearchingForDevice:
            result = @"kSceneTypeSearchingForDevice";
            break;
        case kSceneTypeConnectedToDevice:
            result = @"kSceneTypeConnectedToDevice";
            break;
        case kSceneTypeDanceMoveSelection:
            result = @"kSceneTypeDanceMoveSelection";
            break;
        case kSceneTypeDanceMoveInstructions:
            result = @"kSceneTypeDanceMoveInstructions";
            break;
        case kSceneTypeDanceMoveSeeInAction:
            result = @"kSceneTypeDanceMoveSeeInAction";
            break;
        case kSceneTypeDanceMoveDance:
            result = @"kSceneTypeDanceMoveDance";
            break;
        case kSceneTypeDanceMoveResults:
            result = @"kSceneTypeDanceMoveResults";
            break;
        case kSceneTypeMultiplayerWaitingRoom:
            result = @"MultiplayerWaitingRoomScene";
            break;
        default:
            [NSException raise:NSGenericException format:@"Unexpected SceneType."];
    }
    return result;
}

-(NSDictionary *)getSoundEffectsListForSceneWithID:(SceneTypes)sceneID {
    NSString *fullFileName = @"SoundEffects.plist";
    NSString *plistPath;
    
    // 1: Get the Path to the plist file
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES)
                          objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:fullFileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        plistPath = [[NSBundle mainBundle]
                     pathForResource:@"SoundEffects" ofType:@"plist"];
    }
    
    // 2: Read in the plist file
    NSDictionary *plistDictionary = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    
    // 3: If the plistDictionary was null, the file was not found.
    if (plistDictionary == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        return nil; // No Plist Dictionary or file found
    }
    
    // 4. If the list of soundEffectFiles is empty, load it
    if ((self.listOfSoundEffectFiles == nil) ||
        ([self.listOfSoundEffectFiles count] < 1)) {
//        CCLOG(@"Before");
        [self setListOfSoundEffectFiles:[[NSMutableDictionary alloc] init]];
//        CCLOG(@"after");
        for (NSString *sceneSoundDictionary in plistDictionary) {
            [self.listOfSoundEffectFiles addEntriesFromDictionary:[plistDictionary objectForKey:sceneSoundDictionary]];
        }
        CCLOG(@"Number of SFX filenames:%d", [self.listOfSoundEffectFiles count]);
    }
    
    // 5. Load the list of sound effects state, mark them as unloaded
    if ((self.soundEffectsState == nil) ||
        ([self.soundEffectsState count] < 1)) {
        [self setSoundEffectsState:[[NSMutableDictionary alloc] init]];
        for (NSString *SoundEffectKey in self.listOfSoundEffectFiles) {
            [self.soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:SoundEffectKey];
        }
    }
    
    // 6. Return just the mini SFX list for this scene
    NSString *sceneIDName = [self formatSceneTypeToString:sceneID];
    NSDictionary *soundEffectsList = [plistDictionary objectForKey:sceneIDName];
    
    return soundEffectsList;
}

-(void)loadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    SceneTypes sceneID = (SceneTypes) [sceneIDNumber intValue];
    
    if (self.managerSoundState == kAudioManagerInitializing) {
        int waitCycles = 0;
        while (waitCycles < AUDIO_MAX_WAITTIME) {
            [NSThread sleepForTimeInterval:0.1f];
            if ((self.managerSoundState == kAudioManagerReady) ||
                (self.managerSoundState == kAudioManagerFailed)) {
                break;
            }
            waitCycles = waitCycles + 1;
        }
    }
    
    if (self.managerSoundState == kAudioManagerFailed) {
        return; // Nothing to load, CocosDenshion not ready
    }
    
    NSDictionary *soundEffectsToLoad =
    [self getSoundEffectsListForSceneWithID:sceneID];
    if (soundEffectsToLoad == nil) { // 2
        CCLOG(@"Error reading SoundEffects.plist");
        return;
    }
    // Get all of the entries and PreLoad // 3
    for( NSString *keyString in soundEffectsToLoad )
    {
        CCLOG(@"\nLoading Audio Key:%@ File:%@",
              keyString,[soundEffectsToLoad objectForKey:keyString]);
        [self.soundEngine preloadEffect:
         [soundEffectsToLoad objectForKey:keyString]]; // 3
        // 4
        [self.soundEffectsState setObject:[NSNumber numberWithBool:SFX_LOADED] forKey:keyString];
        
    }
}

-(void)unloadAudioForSceneWithID:(NSNumber*)sceneIDNumber {
    SceneTypes sceneID = (SceneTypes)[sceneIDNumber intValue];
    if (sceneID == kSceneTypeNone) {
        return; // Nothing to unload
    }
    
    
    NSDictionary *soundEffectsToUnload =
    [self getSoundEffectsListForSceneWithID:sceneID];
    if (soundEffectsToUnload == nil) {
        CCLOG(@"Error reading SoundEffects.plist");
        return;
    }
    if (self.managerSoundState == kAudioManagerReady) {
        // Get all of the entries and unload
        for( NSString *keyString in soundEffectsToUnload )
        {
            [self.soundEffectsState setObject:[NSNumber numberWithBool:SFX_NOTLOADED] forKey:keyString];
            [self.soundEngine unloadEffect:keyString];
            CCLOG(@"\nUnloading Audio Key:%@ File:%@", keyString,[soundEffectsToUnload objectForKey:keyString]);
            
        }
    }
}


-(void)initAudioAsync {
    // Initializes the audio engine asynchronously
    self.managerSoundState = kAudioManagerInitializing;
    // Indicate that we are trying to start up the Audio Manager
    [CDSoundEngine setMixerSampleRate:CD_SAMPLE_RATE_MID];
    
    //Init audio manager asynchronously as it can take a few seconds
    //The FXPlusMusicIfNoOtherAudio mode will check if the user is
    // playing music and disable background music playback if
    // that is the case.
    [CDAudioManager initAsynchronously:kAMM_FxPlusMusicIfNoOtherAudio];
    
    //Wait for the audio manager to initialise
    while ([CDAudioManager sharedManagerState] != kAMStateInitialised)
    {
        [NSThread sleepForTimeInterval:0.1];
    }
    
    //At this point the CocosDenshion should be initialized
    // Grab the CDAudioManager and check the state
    CDAudioManager *audioManager = [CDAudioManager sharedManager];
    if (audioManager.soundEngine == nil ||
        audioManager.soundEngine.functioning == NO) {
        CCLOG(@"CocosDenshion failed to init, no audio will play.");
        self.managerSoundState = kAudioManagerFailed;
    } else {
        [audioManager setResignBehavior:kAMRBStopPlay autoHandle:YES];
        self.soundEngine = [SimpleAudioEngine sharedEngine];
        self.managerSoundState = kAudioManagerReady;
        CCLOG(@"CocosDenshion is Ready");
    }
}

-(void)setupAudioEngine {
    if (self.hasAudioBeenInitialized == YES) {
        return;
    } else {
        self.hasAudioBeenInitialized = YES;
        NSOperationQueue *queue = [NSOperationQueue new];
        NSInvocationOperation *asyncSetupOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(initAudioAsync) object:nil];
        [queue addOperation:asyncSetupOperation];
    }
}

-(void)runSceneWithID:(SceneTypes)sceneID {
    SceneTypes oldScene = self.currentScene;
    self.currentScene = sceneID;
    id sceneToRun = nil;
    switch (sceneID) {
        case kSceneTypeMainMenu:
            sceneToRun = [MainMenuScene node];
            break;
        case kSceneTypeSearchingForDevice:
            sceneToRun = [SearchingForDeviceScene node];
            break;
        case kSceneTypeConnectedToDevice:
            sceneToRun = [ConnectedToDeviceScene node];
            break;
        case kSceneTypeDanceMoveSelection:
            sceneToRun = [DanceMoveSelectionScene node];
            break;
        case kSceneTypeDanceMoveInstructions:
            sceneToRun = [DanceMoveInstructionsScene node];
            break;
        case kSceneTypeDanceMoveSeeInAction:
            sceneToRun = [DanceMoveSeeInActionScene node];
            break;
        case kSceneTypeDanceMoveDance:
            sceneToRun = [DanceMoveDanceScene node];
            break;
        case kSceneTypeDanceMoveResults:
            sceneToRun = [DanceMoveResultsScene node];
            break;
        case kSceneTypeMultiplayerWaitingRoom:
            sceneToRun = [MultiplayerWaitingRoomScene node];
            break;
        default:
            CCLOG(@"Unknown sceneID, cannot run scene");
            return;
            break;
    }
    
    if (sceneToRun == nil) {
        // Revert back -- no new scene was found
        self.currentScene = oldScene;
        return;
    }
    
    // load audio for new scene based on sceneID
//    [self performSelectorInBackground:@selector(loadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:self.currentScene]];
    
    if ([[CCDirector sharedDirector] runningScene] == nil) {
        [[CCDirector sharedDirector] pushScene:sceneToRun];
    } else {
        [[CCDirector sharedDirector] replaceScene:sceneToRun];
    }
    
//    [self performSelectorInBackground:@selector(unloadAudioForSceneWithID:) withObject:[NSNumber numberWithInt:oldScene]];
    
    self.currentScene = sceneID;
}

#pragma mark - Video Recording
-(void)setupVideoRecordingSession
{
    [self.captureManager setupSession];
    
    // Start the session. This is done asychronously since -startRunning doesn't return until the session is running.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[self captureManager] session] startRunning];
    });
}

-(void)startRecording;
{
    [self.captureManager startRecording];
}

-(void)stopRecording
{
    [self.captureManager stopRecording];
    [self.captureManager.session stopRunning];
}

@end
