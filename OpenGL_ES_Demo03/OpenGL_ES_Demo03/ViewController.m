//
//  ViewController.m
//  OpenGL_ES_Demo03
//
//  Created by Xukj on 4/15/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize glView;
@synthesize controlView;

@synthesize shoulderSlider;
@synthesize elbowSlider;
@synthesize rotateButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [self.glView cleanup];
}

#pragma mark - UI delegate

-(void)onShoulderValueChanged:(id)sender
{
    float currentValue = [(UISlider *)sender value];
    [self.glView setRotateShoulder:currentValue];
}

-(void)onElbowValueChanged:(id)sender
{
    float currentValue = [(UISlider *)sender value];
    [self.glView setRotateElbow:currentValue];
}

-(void)onRotateClicked:(id)sender
{
    if ([sender tag] == 0) {
        [sender setTitle:@"Stop" forState:UIControlStateNormal];
        [self.glView toggleDisplayLink];
        [sender setTag:1];
    }
    else {
        [sender setTitle:@"Auto" forState:UIControlStateNormal];
        [self.glView toggleDisplayLink];
        [sender setTag:0];
    }
}

@end
