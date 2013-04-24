//
//  OpenGLView.h
//  OpenGL_ES_Demo01
//
//  Created by Xukj on 4/11/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "GLESMath.h"

@interface DrawableVBO : NSObject

@property (nonatomic, assign)GLuint vertexBuffer;       //顶点缓存buffer
@property (nonatomic, assign)GLuint triangleBuffer;     //需要绘制的三角形缓存buffer
@property (nonatomic, assign)GLuint lineBuffer;         //需要绘制的线条缓存buffer
@property (nonatomic, assign)int vertexSize;            //一个顶点所占的size
@property (nonatomic, assign)int triangleSize;          //所有三角形size
@property (nonatomic, assign)int lineSize;              //所有线条size

-(void)cleanup;

@end

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
    
    // 投影矩阵
    KSMatrix4 _projectionMatrix;
    // 变换矩阵
    KSMatrix4 _modelViewMatrix;    
}

// 渲染
-(void)render;
-(void)cleanup;
-(void)setCurrentSurface:(int)index;

@end
