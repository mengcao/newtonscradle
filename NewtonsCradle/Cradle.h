//
//  Cradle.h
//  NewtonsCradle
//
//  Created by Meng Cao on 11/22/13.
//  Copyright (c) 2013 Meng Cao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pendulum.h"

@interface Cradle : NSObject

@property (nonatomic) NSUInteger numberOfPendulums;
@property (nonatomic) NSMutableArray *pendulums;
@property (nonatomic) float pendulumBobRadius;
@property (nonatomic) float pendulumLength;
@property (nonatomic) float pendulumStringTiltedAngle;
@property (nonatomic) BOOL isAnimating;


@property (nonatomic) SCNNode *handleNode;

- (id)initWithMaxNumberOfPendulums: (NSUInteger)maxNumberOfPendulums numberOfPendulums: (NSUInteger)numberOfPendulums pendulumBobRadius: (float)pendulumBobRadius pendulumLength: (float)pendulumLength pendulumStringTiltedAngle: (float)pendulumStringTiltedAngle;

- (NSUInteger)indexOfPendulumWithPendulumName: (NSString *)pendulumName;

- (void)dragPendulumBobAtIndex: (NSUInteger)index withAngle: (float)angle;

- (void)animateWithDuration: (float)duration;

- (void)buildCradle;

- (void)updateWithNumberOfPendulums: (NSUInteger)numberOfPendulums;

- (void)stopAnimation;

- (SCNNode *)getLookAtNode;

@end
