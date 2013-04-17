//
//  ViewController.h
//  OpenGL_ES_Demo03
//
//  Created by Xukj on 4/15/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenGLView;

@interface ViewController : UIViewController

@property (nonatomic, strong)IBOutlet OpenGLView *glView;
@property (nonatomic, strong)IBOutlet UIView *controlView;

@property (nonatomic, strong)IBOutlet UISlider *shoulderSlider;
@property (nonatomic, strong)IBOutlet UISlider *elbowSlider;
@property (nonatomic, strong)IBOutlet UIButton *rotateButton;

-(IBAction)onShoulderValueChanged:(id)sender;
-(IBAction)onElbowValueChanged:(id)sender;
-(IBAction)onRotateClicked:(id)sender;

@end
