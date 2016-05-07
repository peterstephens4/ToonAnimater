//
//  MyScene.m
//  ToonAnimater
//
//  Created by Peter Stephens on 12/27/13.
//  Copyright (c) 2013 Peter Stephens. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MyScene.h"

@implementation MyScene
{
    // define the characters
    SKSpriteNode *_RoadRunner;
    SKSpriteNode *_WileECoyote;
    
    // Define the animation frame arrays
    NSArray *_coyoteWalkingFrames;
    NSArray *_roadRunnerWalkingFrames;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        
        // Action to Scale a Node to Half
        SKAction *scaleNodeHalf = [SKAction scaleTo:0.5 duration:0];
        
        // Action to Scale a Node to Triple Size
        SKAction *scaleNodeTriple = [SKAction scaleTo:3.0 duration:0];
        
        /* Setup the scene here */
        
        // Add the background image
        SKSpriteNode *_desertBackground = [SKSpriteNode spriteNodeWithImageNamed:@"beep_beep"];
        _desertBackground.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:_desertBackground];
        [_desertBackground runAction: scaleNodeTriple];  // fill the screen with the background

        // Set the animation texture atlas
        NSMutableArray *walkFrames = [NSMutableArray array];
        NSMutableArray *walkFrames1 = [NSMutableArray array];
        SKTextureAtlas *toonAtlas = [SKTextureAtlas atlasNamed:@"ToonImages"];
        
        //  Create the Coyote Node
        int numImages = toonAtlas.textureNames.count;
        for (int i=1; i <= numImages/2; i++) {
            NSString *textureName = [NSString stringWithFormat:@"WileECoyote"];
            SKTexture *temp = [toonAtlas textureNamed:textureName];
            [walkFrames addObject:temp];
        }
        _coyoteWalkingFrames = walkFrames;
        
        //  Add the Coyote Node to the Scene
        SKTexture *temp = _coyoteWalkingFrames[0];
        _WileECoyote = [SKSpriteNode spriteNodeWithTexture:temp];
        _WileECoyote.position = CGPointMake(CGRectGetMidX(self.frame) - 200, CGRectGetMidY(self.frame) - 200);
        [self addChild:_WileECoyote];
        
        //  Create the Road Runner Node
        for (int i=1; i <= numImages/2; i++) {
            NSString *textureName1 = [NSString stringWithFormat:@"RoadRunner"];
            SKTexture *temp1 = [toonAtlas textureNamed:textureName1];
            [walkFrames1 addObject:temp1];
        }
        _roadRunnerWalkingFrames = walkFrames1;

        //  Add the Road Runner Node to the Scene
        SKTexture *temp2 = _roadRunnerWalkingFrames[0];
        _RoadRunner = [SKSpriteNode spriteNodeWithTexture:temp2];
        _RoadRunner.position = CGPointMake(CGRectGetMidX(self.frame) + 100, CGRectGetMidY(self.frame) - 100);
        [self addChild:_RoadRunner];
        
        //  Scale the Road Runner and Coyote by Half
        [_WileECoyote runAction: scaleNodeHalf];
        [_RoadRunner runAction: scaleNodeHalf];
        
    }
    return self;
}

-(void)walkingCoyote
{
    //This is our general runAction method to make our coyote walk.
    [_WileECoyote runAction:[SKAction repeatActionForever:
                             [SKAction animateWithTextures:_coyoteWalkingFrames
                                              timePerFrame:0.1f
                                                    resize:NO
                                                   restore:YES]] withKey:@"walkingInPlaceCoyote"];
    return;
}

-(void)walkingRoadRunner
{
    //This is our general runAction method to make our road runner walk.
    [_RoadRunner runAction:[SKAction repeatActionForever:
                             [SKAction animateWithTextures:_roadRunnerWalkingFrames
                                              timePerFrame:0.1f
                                                    resize:NO
                                                   restore:YES]] withKey:@"walkingInPlaceRoadRunner"];
    return;
}


-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInNode:self];
    CGFloat multiplierForDirection;
    CGFloat multiplierForDirectionRR;

    CGSize screenSize = self.frame.size;
    
    // Road Runner ***********************************
    float roadRunnerVelocity = screenSize.width / 2.0;
    CGPoint moveDifferenceRR = CGPointMake(location.x - _RoadRunner.position.x,  location.y - _RoadRunner.position.y);
    float distanceToMoveRR = sqrtf(moveDifferenceRR.x * moveDifferenceRR.x + moveDifferenceRR.y * moveDifferenceRR.y);
    float moveDurationRR   = distanceToMoveRR / roadRunnerVelocity;
    
    // Road Runner's action
    if (moveDifferenceRR.x < 0) {
        multiplierForDirectionRR = -1;
    } else {
        multiplierForDirectionRR = 1;
    }
    _RoadRunner.xScale = fabs(_RoadRunner.xScale) * multiplierForDirectionRR;
    
    if ([_RoadRunner actionForKey:@"roadRunnerMoving"]) {
        //stop just the moving to a new location, but leave the walking legs movement running
        [_RoadRunner removeActionForKey:@"roadRunnerMoving"];
    }
    
    if (![_RoadRunner actionForKey:@"walkingInPlaceRoadRunner"]) {
        //if legs are not moving go ahead and start them
        [self walkingRoadRunner];  //start the road runner walking
    }
    
    SKAction *moveActionRR = [SKAction moveTo:location duration:moveDurationRR];
    SKAction *doneActionRR = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Animation Completed");
        [self roadRunnerMoveEnded];
    }];
    
    SKAction *moveActionWithDoneRR = [SKAction sequence:@[moveActionRR,doneActionRR]];
    
    [_RoadRunner runAction:moveActionWithDoneRR withKey:@"roadRunnerMoving"];
    
    
    // Coyote ****************************************
    float coyoteVelocity     = screenSize.width / 8.0;
    CGPoint moveDifference   = CGPointMake(moveDifferenceRR.x - _WileECoyote.position.x, moveDifferenceRR.y - _WileECoyote.position.y);
    float distanceToMove = sqrtf(moveDifference.x * moveDifference.x + moveDifference.y * moveDifference.y);
    float moveDuration   = distanceToMove / coyoteVelocity;
    
    // Coyote's action
    if (moveDifferenceRR.x < 0) {
        multiplierForDirection = 1;
    } else {
        multiplierForDirection = -1;
    }
    _WileECoyote.xScale = fabs(_WileECoyote.xScale) * multiplierForDirection;
    
    if ([_WileECoyote actionForKey:@"coyoteMoving"]) {
        //stop just the moving to a new location, but leave the walking legs movement running
        [_WileECoyote removeActionForKey:@"coyoteMoving"];
    }
    
    if (![_WileECoyote actionForKey:@"walkingInPlaceCoyote"]) {
        //if legs are not moving go ahead and start them
        [self walkingCoyote];  //start the coyote walking
    }
    
    SKAction *moveAction = [SKAction moveTo:location duration:moveDuration];
    SKAction *doneAction = [SKAction runBlock:(dispatch_block_t)^() {
        NSLog(@"Animation Completed");
        [self coyoteMoveEnded];
    }];
    
    SKAction *moveActionWithDone = [SKAction sequence:@[moveAction,doneAction]];
    
    [_WileECoyote runAction:moveActionWithDone withKey:@"coyoteMoving"];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

//add this method
-(void)coyoteMoveEnded
{
    [_WileECoyote removeAllActions];
}

-(void)roadRunnerMoveEnded
{
    [_RoadRunner removeAllActions];
}


@end