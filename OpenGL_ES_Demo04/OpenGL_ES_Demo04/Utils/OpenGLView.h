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

@property (nonatomic, assign)GLuint vertexBuffer;
@property (nonatomic, assign)GLuint triangleBuffer;
@property (nonatomic, assign)GLuint lineBuffer;
@property (nonatomic, assign)int vertexSize;
@property (nonatomic, assign)int triangleSize;
@property (nonatomic, assign)int lineSize;

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
