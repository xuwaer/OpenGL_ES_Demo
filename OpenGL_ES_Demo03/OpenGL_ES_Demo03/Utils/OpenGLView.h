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
    GLuint _colorSlot;
    
    // 旋转量
    float _rotateShoulder, _rotateElbow;
    
    // 投影矩阵
    ksMatrix4 _projectionMatrix;
    // 变换矩阵
    ksMatrix4 _modelViewMatrix;
    ksMatrix4 _shouldModelViewMatrix;
    ksMatrix4 _elbowModelViewMatrix;
    
    float _rotateColorCube;
    
    
    // 应用程序与屏幕的刷新率保持同步
    CADisplayLink *_displayLink;
}

@property (nonatomic, assign)float rotateShoulder;
@property (nonatomic, assign)float rotateElbow;

// 渲染
-(void)render;
-(void)drawColorCube;
-(void)drawCube:(ksColor)color;

// 设置默认transform
-(void)resetTransform;
-(void)updateShoulderTransform;
-(void)updateElbowTransform;
-(void)updateRectangleTransform;
-(void)updateColorCubeTransform;

-(void)cleanup;

-(void)toggleDisplayLink;

@end
