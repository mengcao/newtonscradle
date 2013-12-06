//
//  Pendulum.h
//  NewtonsCradle
//
//  Created by Meng Cao on 11/21/13.
//  Copyright (c) 2013 Meng Cao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface Pendulum : NSObject

@property (nonatomic) float angle;
@property (nonatomic) float length;
@property (nonatomic) NSString *name;
@property (nonatomic) float bobRadius;
@property (nonatomic) float stringTiltedAngle;
@property (nonatomic) float angularVelocity;
@property (nonatomic) SCNNode *handleNode;

- (id) initWithAngle: (float)angle length: (float)lenght bobRadius: (float)bobRadius stringTiltedAngle: (float)stringTiltedAngle name: (NSString *)name;
- (void) buildPendulum;
- (BOOL)willCollideWithAnotherPendulum: (Pendulum *)anotherPendulum inInterval: (float)dt;
- (void)collideWithAnotherPendulum: (Pendulum *)anotherPendulum;

@end
