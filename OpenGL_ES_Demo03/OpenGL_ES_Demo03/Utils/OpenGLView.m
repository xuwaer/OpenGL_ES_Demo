//
//  OpenGLView.m
//  OpenGL_ES_Demo01
//
//  Created by Xukj on 4/11/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUnit.h"

@interface OpenGLView ()

// 设置绘制layer
-(void)setupLayer;
// 设置渲染版本，以及上下文
-(void)setupContext;
// 设置渲染缓冲
-(void)setupRenderBuffer;
// 设置幀缓冲
-(void)setupFrameBuffer;
// 销毁缓冲，释放内存
-(void)destoryRenderAndFrameBuffer;
-(void)drawTricone;
-(void)setupProgram;
// 设置投影
-(void)setupProjection;
// 设置刷新动作
-(void)displayLinkCallBack:(CADisplayLink *)displayLink;
@end

@implementation OpenGLView

@synthesize rotateShoulder = _rotateShoulder;
@synthesize rotateElbow = _rotateElbow;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(Class)layerClass
{
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}

#pragma mark - set up config

/**
 *	@brief	默认的 CALayer 是透明的，我们需要将它设置为 opaque 才能看到在它上面描绘的东西
 */
-(void)setupLayer
{
    _eaglLayer = (CAEAGLLayer *)self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    NSDictionary *drawbleProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking,
                                       kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    _eaglLayer.drawableProperties = drawbleProperties;
}

/**
 *	@brief	至此 layer 的配置已经就绪，下面我们来创建与设置与 OpenGL ES 相关的东西。首先，我们需要创建OpenGL ES 渲染上下文（在iOS中对应的实现为EAGLContext），这个 context 管理所有使用OpenGL ES 进行描绘的状态，命令以及资源信息。然后，需要将它设置为当前 context，因为我们要使用 OpenGL ES 进行渲染（描绘）。
 */
-(void)setupContext
{
    // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _eaglContext = [[EAGLContext alloc] initWithAPI:api];
    
    if (!_eaglContext) {
        NSLog(@"Do not support OpenGL ES 2.0!");
        exit(1);
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:_eaglContext]) {
        NSLog(@"Fail to set current context!");
        exit(1);
    }
}


/**
 *	@brief	有了上下文，openGL还需要在一块 buffer 上进行描绘，这块 buffer 就是 RenderBuffer（OpenGL ES 总共有三大不同用途的color buffer，depth buffer 和 stencil buffer，这里是最基本的 color buffer）。
 */
-(void)setupRenderBuffer
{
    //  它是为 renderbuffer 申请一个 id（或曰名字）。参数 n 表示申请生成 renderbuffer 的个数，而 renderbuffers 返回分配给 renderbuffer 的 id，注意：返回的 id 不会为0，id 0 是OpenGL ES 保留的，我们也不能使用 id 为0的 renderbuffer。
    glGenBuffers(1, &_colorRenderBuffer);
    
    //  这个函数将指定 id 的 renderbuffer 设置为当前 renderbuffer。参数 target 必须为 GL_RENDERBUFFER，参数 renderbuffer 是就是使用 glGenRenderbuffers 生成的 id。
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    
    // 为 color renderbuffer 分配存储空间
    [_eaglContext renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    /*
     - (BOOL)renderbufferStorage:(NSUInteger)target fromDrawable:(id<EAGLDrawable>)drawable;
     
     在内部使用 drawable（在这里是 EAGLLayer）的相关信息（还记得在 setupLayer 时设置了drawableProperties的一些属性信息么？）作为参数调用了glRenderbufferStorage(GLenum target, GLenum internalformat, GLsizei width, GLsizei height);
     后者 glRenderbufferStorage 指定存储在 renderbuffer 中图像的宽高以及颜色格式，并按照此规格为之分配存储空间。在这里，将使用我们在前面设置 eaglLayer 的颜色格式 RGBA8， 以及 eaglLayer 的宽高作为参数调用 glRenderbufferStorage。
     */
}

/**
 *	@brief	创建 framebuffer object
 *
 *  framebuffer object 通常也被称之为 FBO，它相当于 buffer(color, depth, stencil)的管理者，三大buffer 可以附加到一个 FBO 上。我们是用 FBO 来在 off-screen buffer上进行渲染。
 */
-(void)setupFrameBuffer
{
    //  由 glGenFramebuffers分配的 id也不可能是 0，id 为 0 的 framebuffer 是OpenGL ES 保留的，它指向窗口系统提供的 framebuffer，我们同样不能使用 id 为 0 的framebuffer，否则系统会出错。
    glGenFramebuffers(1, &_frameBuffer);
    
    //  设置为当前 framebuffer
    //  该函数是将相关 buffer（三大buffer之一）attach到framebuffer上（如果 renderbuffer不为 0，知道前面为什么说glGenRenderbuffers 返回的id 不会为 0 吧）或从 framebuffer上detach（如果 renderbuffer为 0）。参数 attachment 是指定 renderbuffer 被装配到那个装配点上，其值是GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT中的一个，分别对应 color，depth和 stencil三大buffer。
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

/**
 *	@brief	当 UIView 在进行布局变化之后，由于 layer 的宽高变化，导致原来创建的 renderbuffer不再相符，我们需要销毁既有 renderbuffer 和 framebuffer。
 */
-(void)destoryRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}

- (void)cleanup
{
    if (_displayLink) {
        [_displayLink invalidate];
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink = nil;
    }
    
    [self destoryRenderAndFrameBuffer];
    
    if (_programHandle != 0) {
        glDeleteProgram(_programHandle);
        _programHandle = 0;
    }
    
    if (_eaglContext && [EAGLContext currentContext] == _eaglContext)
        [EAGLContext setCurrentContext:nil];
    
    _eaglContext = nil;
}

-(void)setupProgram
{
    // Load shaders
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"glsl"];
    NSString *fregmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FregmentShader" ofType:@"glsl"];
    
    GLuint vertexShader = [GLESUnit loadShader:GL_VERTEX_SHADER withFilePath:vertexShaderPath];
    GLuint fregmentShader = [GLESUnit loadShader:GL_FRAGMENT_SHADER withFilePath:fregmentShaderPath];
    
    // Create program, attach shaders.
    _programHandle = glCreateProgram();
    if (!_programHandle) {
        NSLog(@"Fail to create program");
    }
    
    glAttachShader(_programHandle, vertexShader);
    glAttachShader(_programHandle, fregmentShader);
    
    // Link program
    glLinkProgram(_programHandle);
    
    // Check the link status
    GLint linked;
    glGetProgramiv(_programHandle, GL_LINK_STATUS, &linked);
    if (!linked) {
        GLint infoLen = 0;
        glGetProgramiv(_programHandle, GL_INFO_LOG_LENGTH, &infoLen);
        
        if (infoLen > 1) {
            char *infoLog = malloc(sizeof(char) * infoLen);
            glGetProgramInfoLog(_programHandle, infoLen, NULL, infoLog);
            NSLog(@"Fail to create Program : %s", infoLog);
            
            free(infoLog);
        }
        
        glDeleteProgram(_programHandle);
        _programHandle = 0;
        return;
    }
    
    glUseProgram(_programHandle);
    // Get the attribute position slot from program
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    
    // Get the uniform model-view matrix slot from program
    _modelViewSlot = glGetUniformLocation(_programHandle, "modelView");
    
    // Get the uniform projection matrix slot from program
    _projectionSlot = glGetUniformLocation(_programHandle, "projection");
    
    _colorSlot = glGetAttribLocation(_programHandle, "vSourceColor");
}

-(void)setupProjection
{
    // Generate a perspective matrix with a 60 degree FOV
    //
    float aspect = self.frame.size.width / self.frame.size.height;
    
    // ksMatrixLoadIdentity 是 GLESMath 中的一个数学函数，用来将指定矩阵重置为单位矩阵
    ksMatrixLoadIdentity(&_projectionMatrix);
    
    // 透视投影
    // 与gluPerspective(fovy, aspect, zNear, zFar); 作用一致
    // fovy 定义了 camera 在 y 方向上的视线角度（介于 0 ~ 180 之间），aspect 定义了近裁剪面的宽高比 aspect = w/h，而 zNear 和 zFar 定义了从 Camera/Viewer 到远近两个裁剪面的距离（注意这两个距离都是正值）。这四个参数同样也定义了一个视锥体。
    
    // 在这里，我们设置视锥体的近裁剪面到观察者的距离为 1， 远裁剪面到观察者的距离为 20，视角为 60度，然后装载投影矩阵。
    // 默认的观察者位置在原点，视线朝向 -Z 方向，因此近裁剪面其实就在 z = -1 这地方，远裁剪面在 z = -20 这地方，z 值不在(-1, -20) 之间的物体是看不到的。
    ksPerspective(&_projectionMatrix, 60.0, aspect, 1.0, 20.0);
    
    // Load projection matrix
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
}

-(void)toggleDisplayLink
{
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallBack:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else {
        [_displayLink invalidate];
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink = nil;
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)layoutSubviews
{
    [self setupLayer];
    [self setupContext];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self setupProgram];
    [self setupProjection];
    
    [self resetTransform];
    [self render];
}

-(void)displayLinkCallBack:(CADisplayLink *)displayLink
{
    _rotateColorCube += displayLink.duration * 90;
    [self render];
}


-(void)resetTransform
{
}

#pragma mark - getter/setter

-(void)setRotateShoulder:(float)inRotateShoulder
{
    _rotateShoulder = inRotateShoulder;
    [self updateShoulderTransform];
    [self render];
}

-(float)rotateShoulder
{
    return _rotateShoulder;
}

-(void)setRotateElbow:(float)inRotateElbow
{
    _rotateElbow = inRotateElbow;
    [self updateElbowTransform];
    [self render];
}

-(float)rotateElbow
{
    return _rotateElbow;
}

#pragma makr - matrix change

-(void)updateShoulderTransform
{
    // 更新胳膊的模型视图变换
    // 旋转胳膊
    ksMatrixLoadIdentity(&_shouldModelViewMatrix);
    ksMatrixTranslate(&_shouldModelViewMatrix, 0.0, 0.0, -5.5);
    ksMatrixRotate(&_shouldModelViewMatrix, self.rotateShoulder, 0.0, 0.0, 1.0);
    ksMatrixCopy(&_modelViewMatrix, &_shouldModelViewMatrix);
    ksMatrixScale(&_modelViewMatrix, 1.5, 0.6, 0.6);
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
}

-(void)updateElbowTransform
{
    // 更新手臂的模型变换
    // 旋转手臂
    // 更新手臂的模型视图矩阵时，我们是在胳膊的模型视图矩阵基础上进行的，也就是说对胳膊的模型变换（在本列中是旋转）也会对手臂产生影响
    ksMatrixCopy(&_elbowModelViewMatrix, &_shouldModelViewMatrix);
    ksMatrixTranslate(&_elbowModelViewMatrix, 1.5, 0.0, 0.0);
    ksMatrixRotate(&_elbowModelViewMatrix, self.rotateElbow, 0.0, 0.0, 1.0);
    ksMatrixCopy(&_modelViewMatrix, &_elbowModelViewMatrix);
    ksMatrixScale(&_modelViewMatrix, 1.0, 0.4, 0.4);
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
}

-(void)updateColorCubeTransform
{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    ksMatrixTranslate(&_modelViewMatrix, 0.0, -2.0, -5.5);
    ksMatrixRotate(&_modelViewMatrix, _rotateColorCube, 0.0, 1.0, 0.0);
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat *)&_modelViewMatrix.m[0][0]);
}

#pragma mark - draw

-(void)render
{
    ksColor red = {1.0, 0.0, 0.0, 1.0};
    ksColor white = {1.0, 1.0, 1.0, 1.0};
    
    //  glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampfalpha) 用来设置清屏颜色，默认为黑色；
    glClearColor(1.0, 0.7, 0.7, 1.0);
    //  glClear (GLbitfieldmask)用来指定要用清屏颜色来清除由mask指定的buffer，mask 可以是 GL_COLOR_BUFFER_BIT，GL_DEPTH_BUFFER_BIT和GL_STENCIL_BUFFER_BIT的自由组合。
    //  在这里我们只使用到 color buffer，所以清除的就是 color buffer。
    glClear(GL_COLOR_BUFFER_BIT);
    // 去掉被遮挡部分的渲染
    glEnable(GL_CULL_FACE);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    [self updateShoulderTransform];
    [self drawCube:red];
    
    [self updateElbowTransform];
    [self drawCube:white];
    
    [self updateColorCubeTransform];
    [self drawColorCube];
    
    //  将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。在前面设置 drawable 属性时，我们设置 kEAGLDrawablePropertyRetainedBacking 为FALSE，表示不想保持呈现的内容，因此在下一次呈现时，应用程序必须完全重绘一次。将该设置为 TRUE 对性能和资源影像较大，因此只有当renderbuffer需要保持其内容不变时，我们才设置 kEAGLDrawablePropertyRetainedBacking  为 TRUE。
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}

-(void)drawCube:(ksColor)color
{
    // 这里的示例，使用的都是从CPU主存中传递顶点数据到GPU中去进行运算与渲染。
    
    // vertices 和 indices 都是在主存中分配的内存空间
    // Cube 顶点数据以及索引数据
    
    const GLfloat vertices[] = {
        -1.5f, -1.5f, 1.5f,
        -1.5f, 1.5f, 1.5f,
        1.5f, 1.5f, 1.5f,
        1.5f, -1.5f, 1.5f,
        
        1.5f, -1.5f, -1.5f,
        1.5f, 1.5f, -1.5f,
        -1.5f, 1.5f, -1.5f,
        -1.5f, -1.5f, -1.5f
    };
    
    const GLushort indices[] = {
        // Front face
        3, 2, 1, 3, 1, 0,
        
        // Back face
        7, 5, 4, 7, 6, 5,
        
        // Left face
        0, 1, 7, 7, 1, 6,
        
        // Right face
        3, 4, 5, 3, 5, 2,
        
        // Up face
        1, 2, 5, 1, 5, 6,
        
        // Down face
        0, 7, 3, 3, 7, 4
    };
    
    // 当需要进行渲染时，这些数据便通过 glDrawElements 或 glDrawArrays 从 CPU 主存中拷贝到 GPU 中去进行运算与渲染。
    // 这种做法需要频繁地在 CPU 与 GPU 之间传递数据，效率低下
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(_positionSlot);
    
    glDrawElements(GL_LINES, sizeof(indices) / sizeof(GLushort), GL_UNSIGNED_SHORT, indices);
    
    glDisableVertexAttribArray(_positionSlot);
    
}

-(void)drawColorCube
{
    GLfloat vertices[] = {
        -0.5f, -0.5f, 0.5f, 1.0, 0.0, 0.0, 1.0,     // red
        -0.5f, 0.5f, 0.5f, 1.0, 1.0, 0.0, 1.0,      // yellow
        0.5f, 0.5f, 0.5f, 0.0, 0.0, 1.0, 1.0,       // blue
        0.5f, -0.5f, 0.5f, 1.0, 1.0, 1.0, 1.0,      // white
        
        0.5f, -0.5f, -0.5f, 1.0, 1.0, 0.0, 1.0,     // yellow
        0.5f, 0.5f, -0.5f, 1.0, 0.0, 0.0, 1.0,      // red
        -0.5f, 0.5f, -0.5f, 1.0, 1.0, 1.0, 1.0,     // white
        -0.5f, -0.5f, -0.5f, 0.0, 0.0, 1.0, 1.0,    // blue
    };
    
    GLubyte indices[] = {
        // Front face
        0, 3, 2, 0, 2, 1,
        
        // Back face
        7, 5, 4, 7, 6, 5,
        
        // Left face
        0, 1, 6, 0, 6, 7,
        
        // Right face
        3, 4, 5, 3, 5, 2,
        
        // Up face
        1, 2, 5, 1, 5, 6,
        
        // Down face
        0, 7, 4, 0, 4, 3
    };
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, 7 * sizeof(float), vertices + 3);
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glDrawElements(GL_TRIANGLES, sizeof(indices) / sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
    glDisableVertexAttribArray(_positionSlot);
    glDisableVertexAttribArray(_colorSlot);
}

-(void)drawTricone
{
    GLfloat vertices[] = {
        0.7f, 0.7f, 0.0f,
        0.7f, -0.7f, 0.0f,
        -0.7f, -0.7f, 0.0f,
        -0.7f, 0.7f, 0.0f,
        0.0f, 0.0f, -1.0f,
    };
    
    GLubyte indices[] = {
        0, 1, 1, 2, 2, 3, 3, 0,
        4, 0, 4, 1, 4, 2, 4, 3
    };
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    glEnableVertexAttribArray(_positionSlot);
    
    // 获得当前设置的线宽度
    GLfloat lineWidthRange[2];
    glGetFloatv(GL_ALIASED_LINE_WIDTH_RANGE, lineWidthRange);
    // Draw lines
    //
    glDrawElements(GL_LINES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
}


@end
