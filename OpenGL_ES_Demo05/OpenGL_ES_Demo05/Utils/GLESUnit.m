//
//  GLESUnit.m
//  OpenGL_ES_Demo01
//
//  Created by Xukj on 4/12/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import "GLESUnit.h"

@implementation GLESUnit

+(GLuint)loadShader:(GLenum)type withString:(NSString *)shaderString
{
    //  Create the shader object
    //  函数 glCreateShader 用来创建 shader，参数 GLenum type 表示我们要处理的 shader 类型，它可以是 GL_VERTEX_SHADER 或 GL_FRAGMENT_SHADER，分别表示顶点 shader 或 片元 shader。它返回一个句柄指向创建好的 shader 对象。
    GLuint shader = glCreateShader(type);
    if (shader == 0) {
        NSLog(@"Fail to create shader.");
        return 0;
    }
    
    // Load the shader source
    //  函数 glShaderSource 用来给指定 shader 提供 shader 源码。
    //  1.第一个参数是 shader 对象的句柄；
    //  2.第二个参数表示 shader 源码字符串的个数；
    //  3.第三个参数是 shader 源码字符串数组；
    //  4.第四个参数一个 int 数组，表示每个源码字符串应该取用的长度，如果该参数为 NULL，表示假定源码字符串是 \0 结尾的，读取该字符串的内容指定 \0 为止作为源码，如果该参数不是 NULL，则读取每个源码字符串中前 length（与每个字符串对应的 length）长度个字符作为源码。
    const char *shaderStringUTF8 = [shaderString UTF8String];
    glShaderSource(shader, 1, &shaderStringUTF8, NULL);
    
    // Compile the shader
    //  函数 glCompileShader 用来编译指定的 shader 对象，这将编译存储在 shader 对象中的源码。我们可以通过函数 glGetShaderiv 来查询 shader 对象的信息，如本例中查询编译情况，此外还可以查询 GL_DELETE_STATUS，GL_INFO_LOG_STATUS，GL_SHADER_SOURCE_LENGTH 和 GL_SHADER_TYPE。在这里我们查询编译情况，如果返回 0，表示编译出错了，错误信息会写入 info 日志中，我们可以查询该 info 日志，从而获得错误信息。
    glCompileShader(shader);
    
    // Check the compile status
    GLint complited = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &complited);
    
    if (!complited) {
        
        GLint infoLen = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
            NSLog(@"Fail to compile shader : %s", infoLog);
            free(infoLog);
        }
        
        //  函数 glDeleteShader 用来销毁 shader，参数为 glCreateShader 返回的 shader 对象句柄
        glDeleteShader(shader);
        return 0;
    }
    
    return shader;
}

+(GLuint)loadShader:(GLenum)type withFilePath:(NSString *)filePath
{
    NSError *error;
    NSString *shaderString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Fail to load shader from file : %@\n%@", filePath, error.localizedDescription);
        return 0;
    }
    
    return [self loadShader:type withString:shaderString];
}

+(GLuint)loadProgram:(NSString *)vertexShaderFilePath fragmentFilePath:(NSString *)fragmentFilePath
{
    // Load shaders    
    GLuint vertexShader = [GLESUnit loadShader:GL_VERTEX_SHADER withFilePath:vertexShaderFilePath];
    GLuint fragmentShader = [GLESUnit loadShader:GL_FRAGMENT_SHADER withFilePath:fragmentFilePath];
    
    if (vertexShader == 0) {
        return 0;
    }
    
    if (fragmentShader == 0) {
        glDeleteShader(vertexShader);
        return 0;
    }
    
    // Create program, attach shaders.
    GLuint programHandle = glCreateProgram();
    if (programHandle == 0) {
        NSLog(@"Fail to create program");
        return 0;
    }
    
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    
    // Link program
    glLinkProgram(programHandle);
    
    // Check the link status
    GLint linked;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linked);
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(programHandle, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(programHandle, infoLen, NULL, infoLog);
            NSLog(@"Fail to create Program : %s", infoLog);
            
            free(infoLog);
        }
        
        glDeleteProgram(programHandle);
        return 0;
    }
    
    // Free up no longer needed shader resources
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    return programHandle;
}

@end
