//
//  ViewController.h
//  OpenGL_ES_Demo05
//
//  Created by Xukj on 4/24/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenGLView;
@interface ViewController : UIViewController

@property (nonatomic, strong)IBOutlet OpenGLView *glView;

@property (nonatomic, strong)IBOutlet UISlider *ambientRSlider;
@property (nonatomic, strong)IBOutlet UISlider *ambientGSlider;
@property (nonatomic, strong)IBOutlet UISlider *ambientBSlider;

@property (nonatomic, strong)IBOutlet UISlider *diffuseRSlider;
@property (nonatomic, strong)IBOutlet UISlider *diffuseGSlider;
@property (nonatomic, strong)IBOutlet UISlider *diffuseBSlider;

@property (nonatomic, strong)IBOutlet UISlider *specularRSlider;
@property (nonatomic, strong)IBOutlet UISlider *specularGSlider;
@property (nonatomic, strong)IBOutlet UISlider *specularBSlider;

@property (nonatomic, strong)IBOutlet UISlider *lightXSlider;
@property (nonatomic, strong)IBOutlet UISlider *lightYSlider;
@property (nonatomic, strong)IBOutlet UISlider *lightZSlider;

@property (nonatomic, strong)IBOutlet UISlider *shininessSlider;

@property (nonatomic, strong)IBOutlet UISegmentedControl *modelSegmentControl;

-(IBAction)onAmbientRValueChanged:(id)sender;
-(IBAction)onAmbientGValueChanged:(id)sender;
-(IBAction)onAmbientBValueChanged:(id)sender;

-(IBAction)onDiffuseRValueChanged:(id)sender;
-(IBAction)onDiffuseGValueChanged:(id)sender;
-(IBAction)onDiffuseBValueChanged:(id)sender;

-(IBAction)onSpecularRValueChanged:(id)sender;
-(IBAction)onSpecularGValueChanged:(id)sender;
-(IBAction)onSpecularBValueChanged:(id)sender;

-(IBAction)onLightXValueChanged:(id)sender;
-(IBAction)onLightYValueChanged:(id)sender;
-(IBAction)onLightZValueChanged:(id)sender;

-(IBAction)onShininessValueChanged:(id)sender;

-(IBAction)onModelValueChanged:(id)sender;

@end
