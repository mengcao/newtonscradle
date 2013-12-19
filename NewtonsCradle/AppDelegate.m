//
//  AppDelegate.m
//  NewtonsCradle
//
//  Created by Meng Cao on 11/21/13.
//  Copyright (c) 2013 Meng Cao. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate()

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSSlider *numberOfPendulumsSlider;
@property (weak) IBOutlet NSTextField *numberOfPendulumsTextField;
@property (weak) IBOutlet NewtonsCradleView *sceneView;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}

- (void)awakeFromNib {
    self.sceneView.scene = [SCNScene scene];
    [self.sceneView setupScene];
    
}

- (IBAction)toggleStats:(NSButton *)sender {
    if ( self.sceneView.showsStatistics ) {
        self.sceneView.showsStatistics = NO;
    } else {
        self.sceneView.showsStatistics = YES;
    }
}

- (IBAction)pauseScene:(NSButton *)sender {
    [self.sceneView stopCradle];
}

- (IBAction)pendulumCountSlider:(NSSlider *)sender {
    NSUInteger numberOfPendulums = [sender integerValue];
    self.numberOfPendulumsTextField.stringValue = [NSString stringWithFormat:@"Number of Pendulums: %lu", numberOfPendulums];
    [self.sceneView stopCradle];
    [self.sceneView updateCradleWithNumberOfPendulums:numberOfPendulums];
}

@end
