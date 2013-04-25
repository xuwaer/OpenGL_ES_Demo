//
//  ViewController.m
//  OpenGL_ES_Demo05
//
//  Created by Xukj on 4/24/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize glView;
@synthesize ambientRSlider, ambientGSlider, ambientBSlider;
@synthesize diffuseRSlider, diffuseGSlider, diffuseBSlider;
@synthesize specularRSlider, specularGSlider, specularBSlider;
@synthesize shininessSlider;
@synthesize modelSegmentControl;

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

///////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - UI action method

///////////////////////////////////////////////////////////////////////////////////////////////

/*
 *  Change Ambient
 */
-(void)onAmbientRValueChanged:(id)sender
{

}

-(void)onAmbientGValueChanged:(id)sender
{

}

-(void)onAmbientBValueChanged:(id)sender
{

}

/*
 *  Change Diffuse
 */
-(void)onDiffuseRValueChanged:(id)sender
{

}

-(void)onDiffuseGValueChanged:(id)sender
{

}

-(void)onDiffuseBValueChanged:(id)sender
{

}

/*
 *  Change Specular
 */
-(void)onSpecularRValueChanged:(id)sender
{

}

-(void)onSpecularGValueChanged:(id)sender
{

}

-(void)onSpecularBValueChanged:(id)sender
{

}

/*
 *  Change Light
 */
-(void)onLightXValueChanged:(id)sender
{

}

-(void)onLightYValueChanged:(id)sender
{

}

-(void)onLightZValueChanged:(id)sender
{

}

/*
 *  Change Shininess
 */
-(void)onShininessValueChanged:(id)sender
{

}

/*
 *  Model Change
 */
-(void)onModelValueChanged:(id)sender
{

}

@end
