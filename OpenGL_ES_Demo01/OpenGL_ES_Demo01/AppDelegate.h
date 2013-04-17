//
//  AppDelegate.h
//  OpenGL_ES_Demo01
//
//  Created by Xukj on 4/11/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OpenGLView;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    OpenGLView *glView;
}

@property (strong, nonatomic)IBOutlet UIWindow *window;

@end
