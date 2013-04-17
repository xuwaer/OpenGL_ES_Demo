//
//  ViewController.m
//  OpenGL_ES_Demo2
//
//  Created by Xukj on 4/15/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

NSUInteger const AUTO_TAG = 1;
NSUInteger const STOP_TAG = 0;

@interface ViewController ()

-(void)resetControls;

@end

@implementation ViewController

@synthesize controlView;
@synthesize glView;

@synthesize xSlider;
@synthesize ySlider;
@synthesize zSlider;
@synthesize rSlider;
@synthesize sSlider;

@synthesize autoButton;
@synthesize resetButton;

#pragma mark - life circle

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
    
    self.glView = nil;
    self.controlView = nil;
    self.xSlider = nil;
    self.ySlider = nil;
    self.zSlider = nil;
    self.rSlider = nil;
    self.sSlider = nil;
    self.autoButton = nil;
    self.resetButton = nil;
}

-(void)resetControls
{
    [self.xSlider setValue:self.glView.posX];
    [self.ySlider setValue:self.glView.posY];
    [self.zSlider setValue:self.glView.posZ];
    [self.rSlider setValue:self.glView.rotateX];
    [self.sSlider setValue:self.glView.scaleZ];
}

#pragma mark - UISlider delegate

-(void)xSliderValueChange:(id)sender
{
    float currentValue = [(UISlider *)sender value];
    self.glView.posX = currentValue;
}

-(void)ySliderValueChange:(id)sender
{
    float currentValue = [(UISlider *)sender value];
    self.glView.posY = currentValue;
}

-(void)zSliderValueChange:(id)sender
{
    float currentValue = [(UISlider *)sender value];
    self.glView.posZ = currentValue;
}

-(void)rSliderValueChange:(id)sender
{
    float currentValue = [(UISlider *)sender value];
    self.glView.rotateX = currentValue;
}

-(void)sSliderValueChange:(id)sender
{
    float currentValue = [(UISlider *)sender value];
    self.glView.scaleZ = currentValue;
}

#pragma mark - UIButton delegate

-(void)autoButtonClicked:(id)sender
{
    [self.glView toggleDisplayLink];
    
    if ([sender tag] == AUTO_TAG) {
        [sender setTag:STOP_TAG];
        [(UIButton *)sender setTitle:@"AUTO" forState:UIControlStateNormal];
    }
    else {
        [sender setTag:AUTO_TAG];
        [(UIButton *)sender setTitle:@"STOP" forState:UIControlStateNormal];
    }
}

-(void)resetButtonClicked:(id)sender
{
    [self.glView resetTransform];
    [self.glView render];
    [self resetControls];
}

@end
