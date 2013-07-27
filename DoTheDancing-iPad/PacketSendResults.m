//
//  PacketReceiveResults.m
//  DoTheDancing-iPad
//
//  Created by Michael Gao on 7/27/13.
//
//

#import "PacketSendResults.h"

@implementation PacketSendResults

+ (id)packetWithData:(NSData *)data
{
    size_t offset = PACKET_HEADER_SIZE;
    
    int numIterations = [data rw_int8AtOffset:offset];
    offset += 1;
    
    int numSteps = [data rw_int8AtOffset:offset];
    offset += 1;
 
    NSMutableArray *danceMoveResults = [[NSMutableArray alloc] initWithCapacity:numIterations];
    NSMutableArray *danceStepResults;
    
    for (int i=0; i<numIterations; i++) {
        danceStepResults = [[NSMutableArray alloc] initWithCapacity:numSteps];
        
        for (int j=0; j<numSteps; j++) {
            BOOL result = [data rw_int8AtOffset:offset];
            if (result > 0) {
                danceStepResults[j] = @(YES);
            } else {
                danceStepResults[j] = @(NO);
            }
            
            offset += 1;
        }
        
        danceMoveResults[i] = danceStepResults;
    }
    
	return [[self class] packetWithDanceMoveResults:[danceMoveResults copy]];
}

+(id)packetWithDanceMoveResults:(NSArray*)danceMoveResults {
    return [[[self class] alloc] initWithDanceMoveResults:danceMoveResults];
}

-(id)initWithDanceMoveResults:(NSArray*)danceMoveResults {
    self = [super initWithType:PacketTypeSendResults];
    if (self != nil) {
        self.danceMoveResults = danceMoveResults;
    }
    
    return self;
}

@end
