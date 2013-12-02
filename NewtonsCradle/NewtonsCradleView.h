//
//  NewtonsCradleView.h
//  NewtonsCradle
//
//  Created by Meng Cao on 11/21/13.
//  Copyright (c) 2013 Meng Cao. All rights reserved.
//

#import <SceneKit/SceneKit.h>

@interface NewtonsCradleView : SCNView

- (void)setupScene;

- (void)addCradleAtPosition: (SCNVector3)position;

- (void)updateCradleWithNumberOfPendulums: (NSUInteger)numberOfPendulums;

- (void)stopCradle;

@end
