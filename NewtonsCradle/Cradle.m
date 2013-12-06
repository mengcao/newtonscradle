//
//  Cradle.m
//  NewtonsCradle
//
//  Created by Meng Cao on 11/22/13.
//  Copyright (c) 2013 Meng Cao. All rights reserved.
//

#import "Cradle.h"

@interface Cradle()

@property (nonatomic) NSUInteger maxNumberOfPendulums;
@property (nonatomic) NSMutableArray *pendulumsPool;
@property (nonatomic) SCNNode *frontHorizontalPoleNode;
@property (nonatomic) SCNNode *backHorizontalPoleNode;
@property (nonatomic) SCNNode *leftFrontVerticalPoleNode;
@property (nonatomic) SCNNode *leftBackVerticalPoleNode;
@property (nonatomic) SCNNode *rightFrontVerticalPoleNode;
@property (nonatomic) SCNNode *rightBackVerticalPoleNode;
@property (nonatomic) SCNNode *baseNode;

@end

@implementation Cradle

- (id)initWithMaxNumberOfPendulums: (NSUInteger)maxNumberOfPendulums numberOfPendulums:(NSUInteger)numberOfPendulums pendulumBobRadius:(float)pendulumBobRadius pendulumLength:(float)pendulumLength pendulumStringTiltedAngle: (float) pendulumStringTiltedAngle {
    self = [super init];
    _maxNumberOfPendulums = maxNumberOfPendulums;
    _numberOfPendulums = numberOfPendulums;
    _pendulumBobRadius = pendulumBobRadius;
    _pendulumLength = pendulumLength;
    _pendulumStringTiltedAngle = pendulumStringTiltedAngle;
    
    _pendulumsPool = [NSMutableArray arrayWithCapacity:_maxNumberOfPendulums];
    
    
    for ( int i = 0; i < self.maxNumberOfPendulums; i++ ) {
        _pendulumsPool[i] = [[Pendulum alloc] initWithAngle:0.0 length:self.pendulumLength bobRadius: self.pendulumBobRadius stringTiltedAngle: self.pendulumStringTiltedAngle name:[NSString stringWithFormat:@"pendulum-%d", i]];
    }
    
    
    [_pendulumsPool enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj buildPendulum];
    }];
    _handleNode = [SCNNode node];
    _frontHorizontalPoleNode = [SCNNode node];
    _backHorizontalPoleNode = [SCNNode node];
    _leftFrontVerticalPoleNode = [SCNNode node];
    _leftBackVerticalPoleNode = [SCNNode node];
    _rightFrontVerticalPoleNode = [SCNNode node];
    _rightBackVerticalPoleNode = [SCNNode node];
    _baseNode = [SCNNode node];
    
    [_handleNode addChildNode:_frontHorizontalPoleNode];
    [_handleNode addChildNode:_backHorizontalPoleNode];
    [_handleNode addChildNode:_leftFrontVerticalPoleNode];
    [_handleNode addChildNode:_leftBackVerticalPoleNode];
    [_handleNode addChildNode:_rightFrontVerticalPoleNode];
    [_handleNode addChildNode:_rightBackVerticalPoleNode];
    [_handleNode addChildNode:_baseNode];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cradleAnimationDidStop:) name:@"cradleAnimationDidStopNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cradleAnimationDidStart:) name:@"cradleAnimationDidStartNotification" object:nil];
    
    _isAnimating = NO;
    return self;
}

- (void)buildCradle {
    _pendulums = [[NSMutableArray alloc] initWithCapacity:self.numberOfPendulums];
        
    for ( int i = 0; i < self.numberOfPendulums; i++ ) {
        _pendulums[i] = self.pendulumsPool[i];
    }
    
    [self addPendulumsToCradle];
    [self buildFrame];
    [self buildBase];
    
}

- (void)removePendulumsFromCradle {
    for ( Pendulum *pendulum in self.pendulums ) {
        [pendulum.handleNode removeFromParentNode];
    }
}

- (void)addPendulumsToCradle {
    [self.pendulums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(Pendulum *pendulum, NSUInteger idx, BOOL *stop) {
        pendulum.handleNode.position = SCNVector3Make( self.pendulumBobRadius + self.pendulumBobRadius * 2.0 * ( [self.pendulums indexOfObject:pendulum] - self.numberOfPendulums * 0.5 ) , 0.0, 0.0 );
    }];
    
    // use concurrence to add child node may cause problem
    [self.pendulums enumerateObjectsUsingBlock:^(Pendulum *pendulum, NSUInteger idx, BOOL *stop) {
        [self.handleNode addChildNode:pendulum.handleNode];
    }];
}

- (void)buildFrame {
    float frameLength = self.pendulumBobRadius * 2.0 * (self.numberOfPendulums + 2 );
    float frameWidth = 2.0 * self.pendulumLength * tan( self.pendulumStringTiltedAngle );
    float frameHeight = 1.5 * self.pendulumLength;
    SCNCapsule *horizontalPole = [SCNCapsule capsuleWithCapRadius:0.2 height:frameLength];
    horizontalPole.firstMaterial.diffuse.contents = [NSImage imageNamed:@"metal"];
    horizontalPole.firstMaterial.specular.contents = [NSColor whiteColor];
    
    self.frontHorizontalPoleNode.geometry = horizontalPole;
    self.frontHorizontalPoleNode.rotation = SCNVector4Make( 0.0, 0.0, 1.0, M_PI_2 );
    self.frontHorizontalPoleNode.position = SCNVector3Make( 0.0, 0.0, frameWidth * 0.5 );
    
    self.backHorizontalPoleNode.geometry = horizontalPole;
    self.backHorizontalPoleNode.rotation = SCNVector4Make( 0.0, 0.0, 1.0, M_PI_2 );
    self.backHorizontalPoleNode.position = SCNVector3Make( 0.0, 0.0, -frameWidth * 0.5 );
    
    SCNCapsule *verticalPole = [SCNCapsule capsuleWithCapRadius:0.2 height:frameHeight];
    verticalPole.firstMaterial.diffuse.contents = [NSImage imageNamed:@"metal"];
    verticalPole.firstMaterial.specular.contents = [NSColor whiteColor];
    
    self.leftFrontVerticalPoleNode.geometry = verticalPole;
    self.leftFrontVerticalPoleNode.position = SCNVector3Make( -frameLength * 0.5 + 0.2, -frameHeight * 0.5 + 0.2, frameWidth * 0.5);
    
    self.leftBackVerticalPoleNode.geometry = verticalPole;
    self.leftBackVerticalPoleNode.position = SCNVector3Make( -frameLength * 0.5 + 0.2, -frameHeight * 0.5 + 0.2, -frameWidth * 0.5);
    
    self.rightBackVerticalPoleNode.geometry = verticalPole;
    self.rightBackVerticalPoleNode.position = SCNVector3Make( frameLength * 0.5 - 0.2, -frameHeight * 0.5 + 0.2, -frameWidth * 0.5);
    
    self.rightFrontVerticalPoleNode.geometry = verticalPole;
    self.rightFrontVerticalPoleNode.position = SCNVector3Make( frameLength * 0.5 - 0.2, -frameHeight * 0.5 + 0.2, frameWidth * 0.5);
}

- (void)buildBase {
    float baseWidth = self.pendulumBobRadius * 2.0 * (self.numberOfPendulums + 4 );
    float baseLength = 3.0 * self.pendulumLength * tan( self.pendulumStringTiltedAngle );
    float baseHeight = 1.0;
    SCNBox *base = [SCNBox boxWithWidth:baseWidth height:baseHeight length:baseLength chamferRadius:1.0];
    base.firstMaterial.diffuse.contents = [NSImage imageNamed:@"wood.jpg"];
    base.firstMaterial.specular.contents = [NSColor whiteColor];
    self.baseNode.geometry = base;
    self.baseNode.position = SCNVector3Make( 0.0, -1.5 * self.pendulumLength, 0.0 );
}

- (void)updateWithNumberOfPendulums: (NSUInteger)numberOfPendulums {
    self.numberOfPendulums = numberOfPendulums;
    [self removePendulumsFromCradle];
    self.pendulums = [NSMutableArray arrayWithCapacity:numberOfPendulums];
    for ( NSUInteger i = 0; i < numberOfPendulums; i++ ) {
        self.pendulums[i] = self.pendulumsPool[i];
    }
    [self addPendulumsToCradle];
    [self buildFrame];
    [self buildBase];
}

- (NSUInteger)indexOfPendulumWithPendulumName: (NSString *)pendulumName {
    NSString *pendulumIndexString = [[pendulumName componentsSeparatedByString:@"-"] lastObject];
    NSUInteger pendulumIndex = [pendulumIndexString integerValue];
    return pendulumIndex;
}

- (void)dragPendulumBobAtIndex: (NSUInteger)index withAngle: (float)angle {
    
    SCNVector4 angleRotation = SCNVector4Make( 0.0, 0.0, 1.0, angle );
    SCNVector4 zeroRotation = SCNVector4Make( 0.0, 0.0, 1.0, 0.0 );
    if ( angle > 0 ) {
//        for ( Pendulum *pendulum in self.pendulums ) {
//            if ([self.pendulums indexOfObject:pendulum] >= index ) {
//                pendulum.angle = angle;
//                pendulum.handleNode.rotation = SCNVector4Make( 0.0, 0.0, 1.0, angle );
//            } else {
//                pendulum.angle = 0.0;
//                pendulum.handleNode.rotation = SCNVector4Make( 0.0, 0.0, 1.0, 0.0 );
//            }
//        }
        
        [self.pendulums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(Pendulum *pendulum, NSUInteger idx, BOOL *stop) {
            if ( idx >= index ) {
                pendulum.angle = angle;
                pendulum.handleNode.rotation = angleRotation;
            } else {
                pendulum.angle = 0.0;
                pendulum.handleNode.rotation = zeroRotation;
            }
        }];
    } else {
        [self.pendulums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(Pendulum *pendulum, NSUInteger idx, BOOL *stop) {
            if ( idx <= index ) {
                pendulum.angle = angle;
                pendulum.handleNode.rotation = angleRotation;
            } else {
                pendulum.angle = 0.0;
                pendulum.handleNode.rotation = zeroRotation;
            }
        }];
//        for ( Pendulum *pendulum in self.pendulums ) {
//            if ([self.pendulums indexOfObject:pendulum] <= index ) {
//                pendulum.angle = angle;
//                pendulum.handleNode.rotation = SCNVector4Make( 0.0, 0.0, 1.0, angle );
//            } else {
//                pendulum.angle = 0.0;
//                pendulum.handleNode.rotation = SCNVector4Make( 0.0, 0.0, 1.0, 0.0 );
//            }
//        }
    }
}

- (NSArray *)animationValuesInDuration:(float)duration {
    NSMutableArray *animationValues = [[NSMutableArray alloc] initWithCapacity:self.numberOfPendulums];
    for ( NSUInteger i = 0; i < self.numberOfPendulums; i++ ) {
        animationValues[i] = [[NSMutableArray alloc] init];
    }
    float t = 0.0;
    float dt = 0.01;
    const float g = 98.1;
    while ( t < duration ) {
        for ( Pendulum *pendulum in self.pendulums ) {
            float oldAngle = pendulum.angle;
            NSUInteger index = [self.pendulums indexOfObject:pendulum];
            [animationValues[index] addObject:[NSValue valueWithSCNVector4:SCNVector4Make(0.0, 0.0, 1.0, pendulum.angle)]];
            pendulum.angularVelocity += - g / pendulum.length * sin( pendulum.angle ) * dt;
            pendulum.angle += pendulum.angularVelocity * dt;
            
            // stop pendulum when it is about to collide
            if ( oldAngle != 0.0 && pendulum.angle / oldAngle < 0.0 ) {
                pendulum.angle = 0.0;
            }
        }
        NSInteger collisionIndex = [self findCollisionWithinInterval:dt];
        if ( collisionIndex != -1 ) {
            [self resolveCollisionsCausedByPendulumAtIndex:collisionIndex];
        }
        t += dt;
    }
    return [NSArray arrayWithArray: animationValues];
}

- (void)animateWithDuration: (float)duration {
    NSArray *animationValues = [self animationValuesInDuration:duration];
//    for ( Pendulum *pendulum in self.pendulums ) {
//        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"rotation"];
//        animation.duration = duration;
//        animation.values = [animationValues objectAtIndex:[self.pendulums indexOfObject:pendulum]];
//        animation.delegate = self;
//        [pendulum.handleNode addAnimation:animation forKey:@"animation"];
//        
//    }
    [self.pendulums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(Pendulum *pendulum, NSUInteger idx, BOOL *stop) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"rotation"];
        animation.duration = duration;
        animation.values = [animationValues objectAtIndex:idx];
        animation.delegate = self;
        [pendulum.handleNode addAnimation:animation forKey:@"animation"];
    }];
}

- (void)stopAnimation {
//    for ( Pendulum *pendulum in self.pendulums ) {
//        pendulum.angle = 0.0;
//        pendulum.angularVelocity = 0.0;
//        pendulum.handleNode.rotation = SCNVector4Make( 0.0, 0.0, 1.0, 0.0 );
//        [pendulum.handleNode removeAllAnimations];
//    }
    SCNVector4 zeroRotation = SCNVector4Make( 0.0, 0.0, 1.0, 0.0 );
    [self.pendulums enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(Pendulum *pendulum, NSUInteger idx, BOOL *stop) {
        pendulum.angle = 0.0;
        pendulum.angularVelocity = 0.0;
        pendulum.handleNode.rotation = zeroRotation;
        [pendulum.handleNode removeAllAnimations];
    }];
}

- (NSInteger)findCollisionWithinInterval: (float)dt {
    NSInteger collisionIndex = -1;
    for ( NSUInteger i = 0; i < self.numberOfPendulums - 1; i++ ) {
        Pendulum *pendulum = [self.pendulums objectAtIndex:i];
        Pendulum *nextPendulum = [self.pendulums objectAtIndex:i+1];
        if ( [pendulum willCollideWithAnotherPendulum:nextPendulum inInterval:dt] ) {
            if ( pendulum.angularVelocity != 0.0 ) {
                collisionIndex = i;
            } else {
                collisionIndex = i + 1;
            }
            break;
        }
    }
    return collisionIndex;
}

- (void)resolveCollisionsCausedByPendulumAtIndex: (NSInteger)index {
    Pendulum *pendulum = [self.pendulums objectAtIndex:index];
    if ( pendulum.angularVelocity > 0.0 ) {
        for ( NSInteger i = index; i >= 0; i-- ) {
            NSInteger currentIndex = i;
            while ( currentIndex < self.numberOfPendulums - 1 ) {
                pendulum = [self.pendulums objectAtIndex:currentIndex];
                Pendulum *nextPendulum = [self.pendulums objectAtIndex:currentIndex + 1];
                [pendulum collideWithAnotherPendulum:nextPendulum];
                currentIndex++;
            }
        }
    } else {
        for ( NSInteger i = index; i < self.numberOfPendulums; i++ ) {
            NSInteger currentIndex = i;
            while ( currentIndex > 0 ) {
                pendulum = [self.pendulums objectAtIndex:currentIndex];
                Pendulum *previousPendulum = [self.pendulums objectAtIndex:currentIndex-1];
                [pendulum collideWithAnotherPendulum:previousPendulum];
                currentIndex--;
            }
        }
    }
}

- (void)cradleAnimationDidStop: (NSNotification *)notification {
    self.isAnimating = NO;
    [self stopAnimation];
    
}

- (void)cradleAnimationDidStart: (NSNotification *)notification {
    self.isAnimating = YES;
    
}

- (SCNNode *)getLookAtNode {
    if ( [self.pendulums count] >=1 ) {
        Pendulum *middlePendulum = [self.pendulums objectAtIndex:[self.pendulums count] / 2];
        SCNNode *lookAtNode = [middlePendulum.handleNode childNodeWithName:@"bob" recursively:YES];
        return lookAtNode;
    } else {
        return nil;
    }
}

// delegate methods of animations
- (void)animationDidStart:(CAAnimation *)anim {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cradleAnimationDidStartNotification" object:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"cradleAnimationDidStopNotification" object:nil];
    [self stopAnimation];
}
@end
