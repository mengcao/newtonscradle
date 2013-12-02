//
//  NewtonsCradleView.m
//  NewtonsCradle
//
//  Created by Meng Cao on 11/21/13.
//  Copyright (c) 2013 Meng Cao. All rights reserved.
//

#import "NewtonsCradleView.h"
#import "Cradle.h"

@interface NewtonsCradleView()

@property ( nonatomic ) Cradle *cradle;
@property ( nonatomic ) BOOL draggingPendulumBob;
@property ( nonatomic ) NSPoint dragStartLocation;
@property ( nonatomic ) float dragStartAngle;
@property ( nonatomic ) NSUInteger draggedPendulumIndex;


@end

@implementation NewtonsCradleView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _draggingPendulumBob = NO;
    }
    return self;
}

- (void)setupScene {
    [self addCamera];
    [self addFloor];
    [self addLights];
    [self addCradleAtPosition:SCNVector3Make(0.0, 15.0, 0.0)];
    
    self.allowsCameraControl = YES;
    self.jitteringEnabled = YES;
    self.backgroundColor = [NSColor clearColor];
}


- (void)addFloor {
    SCNFloor *floor = [SCNFloor floor];
    floor.reflectionFalloffEnd = 100.0;
    floor.firstMaterial.diffuse.contents = [NSImage imageNamed:@"floor.jpg"];
    floor.firstMaterial.diffuse.contentsTransform = CATransform3DMakeScale(10.0, 10.0, 10.0);
    floor.firstMaterial.diffuse.mipFilter = SCNLinearFiltering;
    
    
    SCNNode *floorNode = [SCNNode node];
    floorNode.geometry = floor;
    floorNode.name = @"floor";
    floorNode.position = SCNVector3Make(0.0, 0.0, 0.0);
    [self.scene.rootNode addChildNode:floorNode];
    
}

- (void)addCamera {
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    cameraNode.position = SCNVector3Make( 0.0, 10.0, 30.0 );
    cameraNode.camera.xFov = 70.0;
    cameraNode.camera.yFov = 70.0;
    cameraNode.name = @"camera";
    [self.scene.rootNode addChildNode:cameraNode];
}

- (void)addLights {
    SCNNode *diffuseLightNode = [SCNNode node];
    diffuseLightNode.light = [SCNLight light];
    diffuseLightNode.light.type = SCNLightTypeOmni;
    diffuseLightNode.position = SCNVector3Make( 0.0, 40.0, 40.0 );
    diffuseLightNode.light.color = [NSColor whiteColor];
    [self.scene.rootNode addChildNode:diffuseLightNode];
    
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [NSColor colorWithDeviceWhite:0.1 alpha:1.0];
    [self.scene.rootNode addChildNode:ambientLightNode];
}

- (void)addCradleAtPosition: (SCNVector3)position {
    _cradle = [[Cradle alloc] initWithMaxNumberOfPendulums:10 numberOfPendulums:5 pendulumBobRadius:1.0 pendulumLength:10.0 pendulumStringTiltedAngle:20.0/180.0*M_PI];
    [self.cradle buildCradle];
    self.cradle.handleNode.position = position;
    
    [self.scene.rootNode addChildNode:self.cradle.handleNode];
    
}

- (void)updateCradleWithNumberOfPendulums:(NSUInteger)numberOfPendulums {
    [self.cradle updateWithNumberOfPendulums:numberOfPendulums];
}

- (void)stopCradle {
    [self.cradle stopAnimation];
}


- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint mouseLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSArray *hits = [self hitTest:mouseLocation options:nil];
    
    if ([hits count] > 0 && !self.cradle.isAnimating) {
        SCNHitTestResult *hit = hits[0];
        if ( [hit.node.geometry isKindOfClass:[SCNSphere class]] ) {
            self.draggingPendulumBob = YES;
            self.dragStartLocation = mouseLocation;
            self.dragStartAngle = hit.node.parentNode.rotation.w;
            self.draggedPendulumIndex = [self.cradle indexOfPendulumWithPendulumName:hit.node.parentNode.name];
        }
    }
    [super mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if ( !self.draggingPendulumBob ) {
        [super mouseDragged:theEvent];
    } else {
        NSPoint draggingLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        float draggedAngle = ( draggingLocation.x - self.dragStartLocation.x ) * 0.01;
        
        // never let user drag the pendulum more than 180 degrees
        float newAngle = self.dragStartAngle + draggedAngle;
        if ( fabs(newAngle) > (M_PI/2.0-0.1) ) {
            newAngle = fabs(newAngle)/newAngle * (M_PI/2.0-0.1);
        }
        [self.cradle dragPendulumBobAtIndex: self.draggedPendulumIndex withAngle:newAngle];
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    if ( self.draggingPendulumBob ) {
        self.draggingPendulumBob = NO;
        [self.cradle animateWithDuration:20.0];
    }
    
    [super mouseUp:theEvent];
}


@end
