//
//  ViewController.h
//  OpenGL_ES_Demo2
//
//  Created by Xukj on 4/15/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenGLView;

@interface ViewController : UIViewController

@property (nonatomic, strong)IBOutlet UIView *controlView;
@property (nonatomic, strong)IBOutlet OpenGLView *glView;

@property (nonatomic, strong)IBOutlet UISlider *xSlider;
@property (nonatomic, strong)IBOutlet UISlider *ySlider;
@property (nonatomic, strong)IBOutlet UISlider *zSlider;
@property (nonatomic, strong)IBOutlet UISlider *rSlider;
@property (nonatomic, strong)IBOutlet UISlider *sSlider;

@property (nonatomic, strong)IBOutlet UIButton *autoButton;
@property (nonatomic, strong)IBOutlet UIButton *resetButton;

-(IBAction)xSliderValueChange:(id)sender;
-(IBAction)ySliderValueChange:(id)sender;
-(IBAction)zSliderValueChange:(id)sender;
-(IBAction)rSliderValueChange:(id)sender;
-(IBAction)sSliderValueChange:(id)sender;

-(IBAction)autoButtonClicked:(id)sender;
-(IBAction)resetButtonClicked:(id)sender;

@end
