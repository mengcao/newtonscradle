//
//  Pendulum.m
//  NewtonsCradle
//
//  Created by Meng Cao on 11/21/13.
//  Copyright (c) 2013 Meng Cao. All rights reserved.
//

#import "Pendulum.h"
#define TILTED_ANGLE 20.0 / 180.0 * M_PI

@implementation Pendulum

- (id)initWithAngle:(float)angle length:(float)length bobRadius: (float)bobRadius stringTiltedAngle: (float)stringTiltedAngle name:(NSString *)name {
    self = [super init];
    _angle = angle;
    _length = length;
    _bobRadius = bobRadius;
    _angularVelocity = 0.0;
    _name = name;
    _handleNode = [SCNNode node];
    _stringTiltedAngle = stringTiltedAngle;
    return self;
}

- (void)buildPendulum {
    SCNCylinder *backString = [SCNCylinder cylinderWithRadius:0.01 height:self.length / cos( TILTED_ANGLE )];
    backString.firstMaterial.diffuse.contents = [NSColor blackColor];
    SCNNode *backStringNode = [SCNNode node];
    backStringNode.geometry = backString;
    backStringNode.position = SCNVector3Make( 0.0, -self.length * 0.5, -self.length * tan( TILTED_ANGLE ) * 0.5 );
    backStringNode.rotation = SCNVector4Make( 1.0, 0.0, 0.0, -self.stringTiltedAngle );
    
    SCNCylinder *frontString = [SCNCylinder cylinderWithRadius:0.01 height:self.length / cos( TILTED_ANGLE )];
    frontString.firstMaterial.diffuse.contents = [NSColor blackColor];
    SCNNode *frontStringNode = [SCNNode node];
    frontStringNode.geometry = frontString;
    frontStringNode.position = SCNVector3Make( 0.0, -self.length * 0.5, self.length * tan( TILTED_ANGLE ) * 0.5 );
    frontStringNode.rotation = SCNVector4Make( 1.0, 0.0, 0.0, TILTED_ANGLE );
    
    SCNSphere *bob = [SCNSphere sphereWithRadius:self.bobRadius];
    bob.firstMaterial.diffuse.contents = [NSImage imageNamed:@"metal"];
    bob.firstMaterial.specular.contents = [NSColor whiteColor];
    SCNNode *bobNode = [SCNNode node];
    bobNode.geometry = bob;
    bobNode.position = SCNVector3Make( 0.0, -self.length, 0.0 );
    bobNode.name = @"bob";
    
    [self.handleNode addChildNode:backStringNode];
    [self.handleNode addChildNode:frontStringNode];
    [self.handleNode addChildNode:bobNode];
    self.handleNode.name = self.name;
}

- (BOOL)willCollideWithAnotherPendulum:(Pendulum *)anotherPendulum inInterval:(float)dt {
    return ( self.angle == 0.0 && anotherPendulum.angle == 0.0 && ( self.angularVelocity - anotherPendulum.angularVelocity != 0.0 ) );
}

- (void)collideWithAnotherPendulum: (Pendulum *)anotherPendulum {
    float tempAngularVelocity = self.angularVelocity;
    self.angularVelocity = anotherPendulum.angularVelocity;
    anotherPendulum.angularVelocity = tempAngularVelocity;
}

@end
