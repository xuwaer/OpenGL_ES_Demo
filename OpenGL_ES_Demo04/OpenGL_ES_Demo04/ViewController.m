//
//  ViewController.m
//  OpenGL_ES_Demo04
//
//  Created by Xukj on 4/17/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import "ViewController.h"
#import "OpenGLView.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize glView;
@synthesize segment;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)onSegmentValueChanged:(id)sender
{
    UISegmentedControl * segmentControl = (UISegmentedControl *)sender;
    int index = [segmentControl selectedSegmentIndex];
    
    [self.glView setCurrentSurface:index];
}

@end
