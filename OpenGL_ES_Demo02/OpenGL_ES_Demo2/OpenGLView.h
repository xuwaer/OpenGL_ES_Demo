//
//  OpenGLView.h
//  OpenGL_ES_Demo01
//
//  Created by Xukj on 4/11/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "ksMatrix.h"
#import "ksVector.h"

@interface OpenGLView : UIView
{
    @private
    CAEAGLLayer *_eaglLayer;
    EAGLContext *_eaglContext;
    GLuint _colorRenderBuffer;
    GLuint _frameBuffer;
    
    GLuint _programHandle;
    GLuint _positionSlot;
    GLuint _modelViewSlot;
    GLuint _projectionSlot;
    
    // 平移偏移量
    float _posX;
    float _posY;
    float _posZ;
    // 旋转
    float _rotateX;
    // 缩放
    float _scaleZ;
    
    // 投影矩阵
    ksMatrix4 _projectionMatrix;
    // 变换矩阵
    ksMatrix4 _modelViewMatrix;
    
    // 应用程序与屏幕的刷新率保持同步
    CADisplayLink *_displayLink;
}

@property (nonatomic, assign)float posX;
@property (nonatomic, assign)float posY;
@property (nonatomic, assign)float posZ;

@property (nonatomic, assign)float rotateX;
@property (nonatomic, assign)float scaleZ;

// 渲染
-(void)render;

// 设置默认transform
-(void)resetTransform;

-(void)cleanup;

-(void)toggleDisplayLink;

@end
