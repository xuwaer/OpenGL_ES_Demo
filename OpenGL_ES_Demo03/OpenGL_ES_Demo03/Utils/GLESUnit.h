//
//  GLESUnit.h
//  OpenGL_ES_Demo01
//
//  Created by Xukj on 4/12/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>

@interface GLESUnit : NSObject

+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString;

+(GLuint)loadShader:(GLenum)type withFilePath:(NSString *)filePath;

@end
