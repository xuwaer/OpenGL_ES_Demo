//
//  ViewController.h
//  OpenGL_ES_Demo04
//
//  Created by Xukj on 4/17/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenGLView;

@interface ViewController : UIViewController

@property (nonatomic, strong)IBOutlet OpenGLView *glView;
@property (nonatomic, strong)IBOutlet UISegmentedControl *segment;

-(IBAction)onSegmentValueChanged:(id)sender;

@end
