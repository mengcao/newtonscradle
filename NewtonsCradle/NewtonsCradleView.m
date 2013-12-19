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
@property ( nonatomic ) BOOL isDraggingPendulumBob;
@property ( nonatomic ) NSPoint dragStartLocation;
@property ( nonatomic ) float dragStartAngle;
@property ( nonatomic ) NSUInteger draggedPendulumIndex;
@property ( nonatomic ) CATransform3D oldCameraTransform;
@property ( nonatomic ) SCNNode *ambientLightNode;
@property ( nonatomic ) SCNNode *diffuseLightNode;
@property ( nonatomic ) SCNNode *spotLightNode;


@end

@implementation NewtonsCradleView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _isDraggingPendulumBob = NO;
    }
    return self;
}

- (void)setupScene {
    [self addCradleAtPosition:SCNVector3Make(0.0, 15.0, 0.0)];
    [self addCamera];
    [self addFloor];
    [self addLights];
    
    self.allowsCameraControl = YES;
    self.jitteringEnabled = YES;
    self.backgroundColor = [NSColor clearColor];
    self.showsStatistics = NO;
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
    _oldCameraTransform = cameraNode.transform;
    [self.scene.rootNode addChildNode:cameraNode];
}

- (void)addLights {
    _diffuseLightNode = [SCNNode node];
    _diffuseLightNode.light = [SCNLight light];
    _diffuseLightNode.light.type = SCNLightTypeOmni;
    _diffuseLightNode.position = SCNVector3Make( 0.0, 40.0, 40.0 );
    _diffuseLightNode.rotation = SCNVector4Make( 1.0, 0.0, 0.0, -M_PI_2);
    _diffuseLightNode.light.color = [NSColor whiteColor];
    [self.scene.rootNode addChildNode:_diffuseLightNode];
    
    _ambientLightNode = [SCNNode node];
    _ambientLightNode.light = [SCNLight light];
    _ambientLightNode.light.type = SCNLightTypeAmbient;
    _ambientLightNode.light.color = [NSColor colorWithDeviceWhite:0.1 alpha:1.0];
    [self.scene.rootNode addChildNode:_ambientLightNode];
    
    _spotLightNode = [SCNNode node];
    _spotLightNode.light = [SCNLight light];
    _spotLightNode.light.type = SCNLightTypeSpot;
    _spotLightNode.position = SCNVector3Make( 0.0, 40.0, 4.0 );
    _spotLightNode.rotation = SCNVector4Make( 1.0, 0.0, 0.0, -M_PI_2 );
    _spotLightNode.light.color = [NSColor whiteColor];
    _spotLightNode.light.castsShadow = YES;
    _spotLightNode.light.shadowColor = [NSColor blackColor];
    _spotLightNode.light.shadowRadius = 1.0;
    [self setSpotLightLookConstraint];
    [self.scene.rootNode addChildNode:_spotLightNode];
}

- (void) setSpotLightLookConstraint {
    SCNNode *lookAtNode = [self.cradle getLookAtNode];
    SCNLookAtConstraint *lookAtFirstPendulumConstraint = [SCNLookAtConstraint lookAtConstraintWithTarget:lookAtNode];
    [self.spotLightNode setConstraints:[NSArray arrayWithObject:lookAtFirstPendulumConstraint]];
}

- (void)addCradleAtPosition: (SCNVector3)position {
    _cradle = [[Cradle alloc] initWithMaxNumberOfPendulums:10 numberOfPendulums:5 pendulumBobRadius:1.0 pendulumLength:10.0 pendulumStringTiltedAngle:20.0/180.0*M_PI];
    [self.cradle buildCradle];
    self.cradle.handleNode.position = position;
    
    [self.scene.rootNode addChildNode:self.cradle.handleNode];
    
}

- (void)updateCradleWithNumberOfPendulums:(NSUInteger)numberOfPendulums {
    [self.cradle updateWithNumberOfPendulums:numberOfPendulums];
    [self setSpotLightLookConstraint];
}

- (void)stopCradle {
    [self.cradle stopAnimation];
}


- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint mouseLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    if ( !self.cradle.isAnimating ) {
        NSArray *hits = [self hitTest:mouseLocation options:nil];
        if ( [hits count] > 0 ) {
            SCNHitTestResult *hit = hits[0];
            if ( [hit.node.geometry isKindOfClass:[SCNSphere class]] ) {
                self.isDraggingPendulumBob = YES;
                self.dragStartLocation = mouseLocation;
                self.dragStartAngle = hit.node.parentNode.rotation.w;
                self.draggedPendulumIndex = [self.cradle indexOfPendulumWithPendulumName:hit.node.parentNode.name];
            }
        }
    }    
    
    [super mouseDown:theEvent];
}

- (void)mouseDragged:(NSEvent *)theEvent {
    if ( !self.isDraggingPendulumBob ) {
        [super mouseDragged:theEvent];
        
        [self forbidCameraGoingUnderFloor];
    } else {
        NSPoint draggingLocation = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        float draggedAngle = ( draggingLocation.x - self.dragStartLocation.x ) * 0.01;
        
        // never let user drag the pendulum more than 90 degrees
        float newAngle = self.dragStartAngle + draggedAngle;
        if ( fabs(newAngle) > (M_PI/2.0-0.1) ) {
            newAngle = fabs(newAngle)/newAngle * (M_PI/2.0-0.1);
        }
        // flip the sign of angle if camera is on the back of the cradle
        newAngle = newAngle * fabs( self.pointOfView.position.z ) / ( self.pointOfView.position.z );
        
        [self.cradle dragPendulumBobAtIndex: self.draggedPendulumIndex withAngle:newAngle];
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    if ( self.isDraggingPendulumBob ) {
        self.isDraggingPendulumBob = NO;
        [self.cradle animateWithDuration:20.0];
    }
    
    [super mouseUp:theEvent];
//    CATransform3D invert = self.pointOfView.camera.projectionTransform;
//    
//    NSLog( @"%f, %f, %f, %f\n %f, %f, %f, %f\n %f, %f, %f, %f\n %f, %f, %f, %f\n", invert.m11, invert.m12, invert.m13, invert.m14,
//        invert.m21, invert.m22, invert.m23, invert.m24,
//        invert.m31, invert.m32, invert.m33, invert.m34,
//        invert.m41, invert.m42, invert.m43, invert.m44 );
}

- (void)scrollWheel:(NSEvent *)theEvent {
    [super scrollWheel:theEvent];
    [self forbidCameraGoingUnderFloor];
}

- (void)forbidCameraGoingUnderFloor {
    if ( self.pointOfView.position.y < 5.0 ) {
        self.pointOfView.transform = self.oldCameraTransform;
    }
    self.oldCameraTransform = self.pointOfView.transform;
}


@end
