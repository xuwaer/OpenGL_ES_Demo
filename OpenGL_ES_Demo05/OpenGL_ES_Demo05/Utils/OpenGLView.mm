//
//  OpenGLView.m
//  OpenGL_ES_Demo01
//
//  Created by Xukj on 4/11/13.
//  Copyright (c) 2013 tosc-its. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUnit.h"
#import "ParametricEquations.h"
#import "Quaternion.h"

@implementation DrawableVBO

@synthesize vertexBuffer, triangleBuffer, lineBuffer;
@synthesize vertexSize, triangleSize, lineSize;

-(void)cleanup
{
    /*
     释放顶点缓存
     void glDeleteBuffers (GLsizei n, const GLuint* buffers);
     
        参数与 glGenBuffers 类似，就不再累述，该函数用于删除顶点缓存对象，释放顶点缓存。
     */
    if (vertexBuffer != 0) {
        glDeleteBuffers(1, &vertexBuffer);
        vertexBuffer = 0;
    }
    
    if (triangleBuffer != 0) {
        glDeleteBuffers(1, &triangleBuffer);
        triangleBuffer = 0;
    }
    
    if (lineBuffer) {
        glDeleteBuffers(1, &lineBuffer);
        lineBuffer = 0;
    }
}

@end

@interface OpenGLView ()
{
    NSMutableArray *_vboArray;
    // 当前VBO
    DrawableVBO *_currentVBO;
    
    ivec2 _fingerStart;
    Quaternion _orientation;
    Quaternion _previousOrientation;
    KSMatrix4 _rotationMatrix;
}
// 设置绘制layer
-(void)setupLayer;
// 设置渲染版本，以及上下文
-(void)setupContext;
// 设置渲染缓冲
-(void)setupRenderBuffer;
// 设置幀缓冲
-(void)setupFrameBuffer;
// 销毁缓冲，释放内存
-(void)destroyRenderAndFrameBuffer;

// ?
-(void)setupProgram;
// 设置投影
-(void)setupProjection;

// 创建缓存VBO
-(DrawableVBO *)createVBO:(int)surfaceType;
// 使用已有的索引来使用VBO缓存
-(DrawableVBO *)createCube;
// 设置缓存VBO
-(void)setupVBO;
// 销毁缓存
-(void)destroyVBO;

// 曲面图形生成
-(ISurface *)createSurface:(int)surfaceType;
-(vec3) mapToSphere:(ivec2) touchpoint;
-(void)updateSurfaceTransform;
-(void)resetRotation;
// 绘制曲面图形
-(void)drawSurface;
@end

@implementation OpenGLView

@synthesize lightPosition = _lightPosition;
@synthesize ambient = _ambient;
@synthesize diffuse = _diffuse;
@synthesize specular = _specular;
@synthesize shininess = _shininess;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupLayer];
        [self setupContext];
        [self setupProgram];
        [self setupProjection];
        [self resetRotation];
        
        _vboArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)layoutSubviews
{
    [self destroyRenderAndFrameBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    
    [self setupVBO];
    [self render];
}

+(Class)layerClass
{
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}

//////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - context config

//////////////////////////////////////////////////////////////////////////////////////////

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
-(void)destroyRenderAndFrameBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}

//////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - shader config

//////////////////////////////////////////////////////////////////////////////////////////


-(void)setupProgram
{
    // Load shaders
    NSString *vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader" ofType:@"glsl"];
    NSString *fregmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FregmentShader" ofType:@"glsl"];
    
    
    _programHandle = [GLESUnit loadProgram:vertexShaderPath fragmentFilePath:fregmentShaderPath];
    if (_programHandle == 0)
        return;
    
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

//////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - VBO config

//////////////////////////////////////////////////////////////////////////////////////////

-(DrawableVBO *)createVBO:(int)surfaceType
{
    ISurface *surface = [self createSurface:surfaceType];
    // Get vertice from surface.
    //
    int vertexSize = surface->GetVertexSize();
    int vBufferSize = surface->GetVertexCount() * vertexSize;
    GLfloat *vertexBuf = new GLfloat[vBufferSize];
    surface->GenerateVertices(vertexBuf);
    
    // Get triangle indice from surface
    //
    int triangleIndexCount = surface->GetTriangleIndexCount();
    unsigned short *triangleBuf = new unsigned short[triangleIndexCount];
    surface->GenerateTriangleIndices(triangleBuf);
    
    // Get line indice from surface
    //
    int lineIndexCount = surface->GetLineIndexCount();
    unsigned short *lineBuf = new unsigned short[lineIndexCount];
    surface->GenerateLineIndices(lineBuf);
    
    /*
     创建顶点缓存对象
     void glGenBuffers (GLsizei n, GLuint* buffers);
     
        参数 n ： 表示需要创建顶点缓存对象的个数；
        参数 buffers ：用于存储创建好的顶点缓存对象句柄；
     */
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    
    /*
     将顶点缓存对象设置为（或曰绑定到）当前数组缓存对象或元素缓存对象
     void glBindBuffer (GLenum target, GLuint buffer);
     
        参数 target ：指定绑定的目标，取值为 GL_ARRAY_BUFFER（用于顶点数据） 或 GL_ELEMENT_ARRAY_BUFFER（用于索引数据）；
        参数 buffer ：顶点缓存对象句柄；
     */
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    /*
     1.为顶点缓存对象分配空间
     void glBufferData (GLenum target, GLsizeiptr size, const GLvoid* data, GLenum usage);
    
        参数 target：与 glBindBuffer 中的参数 target 相同；
        参数 size ：指定顶点缓存区的大小，以字节为单位计数；
        data ：用于初始化顶点缓存区的数据，可以为 NULL，表示只分配空间，之后再由 glBufferSubData 进行初始化；
        usage ：表示该缓存区域将会被如何使用，它的主要目的是用于提示OpenGL该对该缓存区域做何种程度的优化。其参数为以下三个之一：
        GL_STATIC_DRAW：表示该缓存区不会被修改；
        GL_DyNAMIC_DRAW：表示该缓存区会被周期性更改；
        GL_STREAM_DRAW：表示该缓存区会被频繁更改；
    
        如果顶点数据一经初始化就不会被修改，那么就应该尽量使用 GL_STATIC_DRAW，这样能获得更好的性能。
     
     2.更新顶点缓冲区数据
     void glBufferSubData (GLenum target, GLintptr offset, GLsizeiptr size, const GLvoid* data);
     
        参数 ：offset 表示需要更新的数据的起始偏移量；
        参数 ：size 表示需要更新的数据的个数，也是以字节为计数单位；
        data ：用于更新的数据；
     */
    glBufferData(GL_ARRAY_BUFFER, vBufferSize * sizeof(GLfloat), vertexBuf, GL_STATIC_DRAW);
    
    GLuint lineIndexBuffer;
    glGenBuffers(1, &lineIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, lineIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, lineIndexCount * sizeof(GLfloat), lineBuf, GL_STATIC_DRAW);
    
    GLuint triangleIndexBuffer;
    glGenBuffers(1, &triangleIndexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, triangleIndexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, triangleIndexCount * sizeof(GLfloat), triangleBuf, GL_STATIC_DRAW);
    
    // 释放内存
    delete [] vertexBuf;
    delete [] lineBuf;
    delete [] triangleBuf;
    delete surface;
    
    // 封装渲染信息
    DrawableVBO *vbo = [[DrawableVBO alloc] init];
    vbo.vertexBuffer = vertexBuffer;
    vbo.triangleBuffer = triangleIndexBuffer;
    vbo.lineBuffer = lineIndexBuffer;
    vbo.vertexSize = vertexSize;
    vbo.triangleSize = triangleIndexCount;
    vbo.lineSize = lineIndexCount;
    
    return vbo;
}

/**
 *  用已有顶点数据和索引数据来使用 VBO
 */
-(DrawableVBO *)createCube
{
    // Cube 顶点数据以及索引数据
    
    GLfloat vertices[] = {
        -1.5f, -1.5f, 1.5f, -0.577350, -0.577350, 0.577350,
        -1.5f, 1.5f, 1.5f, -0.577350, 0.577350, 0.577350,
        1.5f, 1.5f, 1.5f, 0.577350, 0.577350, 0.577350,
        1.5f, -1.5f, 1.5f, 0.577350, -0.577350, 0.577350,
        
        1.5f, -1.5f, -1.5f, 0.577350, -0.577350, -0.577350,
        1.5f, 1.5f, -1.5f, 0.577350, 0.577350, -0.577350,
        -1.5f, 1.5f, -1.5f, -0.577350, 0.577350, -0.577350,
        -1.5f, -1.5f, -1.5f, -0.577350, -0.577350, -0.577350
    };
    
    GLushort indices[] = {
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
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), &vertices, GL_STATIC_DRAW);
    
    GLuint lineBuffer;
    glGenBuffers(1, &lineBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, lineBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), &indices, GL_STATIC_DRAW);
    
    GLuint triangleBuffer;
    glGenBuffers(1, &triangleBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, triangleBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), &indices, GL_STATIC_DRAW);
    
    // 封装渲染信息
    DrawableVBO *vbo = [[DrawableVBO alloc] init];
    vbo.vertexBuffer = vertexBuffer;
    vbo.vertexSize = 6;
    vbo.lineBuffer = lineBuffer;
    vbo.lineSize = sizeof(indices) / sizeof(GLushort);
    vbo.triangleBuffer = triangleBuffer;
    vbo.triangleSize = sizeof(indices) / sizeof(GLushort);
    
    return vbo;
}

-(void)setupVBO
{
    for (int i = 0; i < SurfaceMaxCount; i++) {
        DrawableVBO *vbo = [self createVBO:i];
        [_vboArray addObject:vbo];
        vbo = nil;
    }
    
    // 创建自定义的立方体。该立方体使用已有的顶点数组和数组索引生成
    DrawableVBO *cubeVBO = [self createCube];
    [_vboArray addObject:cubeVBO];
    cubeVBO = nil;
    
    [self setCurrentSurface:0];
}

-(void)destroyVBO
{
    for (DrawableVBO * vbo in _vboArray) {
        [vbo cleanup];
    }
    _vboArray = nil;
    
    _currentVBO = nil;
}

//////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Surface config

//////////////////////////////////////////////////////////////////////////////////////////

/**
 *  定义需要绘制的形状
 **/
 
// 球体
const int SurfaceSphere = 0;
// 圆锥体
const int SurfaceCone = 1;
// 环形
const int SurfaceTorus = 2;
// 三叶结
const int SurfaceTrefoilKnot = 3;
// 克莱因瓶
const int SurfaceKleinBottle = 4;

const int SurfaceMobiusStrip = 5;
// 立方体，该立方体不使用Surface绘制，故surfacemaxcount依旧为6
const int SurfaceCube = 6;

// 需要绘制的图形总数量
const int SurfaceMaxCount = 6;

-(ISurface *)createSurface:(int)surfaceType
{
    ISurface *surface = NULL;
    
    switch (surfaceType) {
        case SurfaceSphere:
            surface = new Sphere(2.0);
            break;
        case SurfaceCone:
            surface = new Cone(4.0, 1.0);
            break;
        case SurfaceTorus:
            surface = new Torus(2.0, 3.0);
            break;
        case SurfaceTrefoilKnot:
            surface = new TrefoilKnot(2.4);
            break;
        case SurfaceKleinBottle:
            surface = new KleinBottle(0.25);
            break;
        case SurfaceMobiusStrip:
            surface = new MobiusStrip(1.4);
            break;
        default:
            break;
    }
    
    return surface;
}

-(void)setCurrentSurface:(int)index
{
    index = index % [_vboArray count];
    _currentVBO = [_vboArray objectAtIndex:index];
    
    [self resetRotation];
    [self render];
}

- (vec3) mapToSphere:(ivec2) touchpoint
{
    ivec2 centerPoint = ivec2(self.frame.size.width/2, self.frame.size.height/2);
    float radius = self.frame.size.width/3;
    float safeRadius = radius - 1;
    
    vec2 p = touchpoint - centerPoint;
    
    // Flip the Y axis because pixel coords increase towards the bottom.
    p.y = -p.y;
    
    if (p.Length() > safeRadius) {
        float theta = atan2(p.y, p.x);
        p.x = safeRadius * cos(theta);
        p.y = safeRadius * sin(theta);
    }
    
    float z = sqrt(radius * radius - p.LengthSquared());
    vec3 mapped = vec3(p.x, p.y, z);
    return mapped / radius;
}

-(void)updateSurfaceTransform
{
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    // 模型，向z轴负方向平移7个单位
    ksTranslate(&_modelViewMatrix, 0.0, 0.0, -7);
    // 模型旋转。旋转角度由rotationMatrix矩阵确定
    ksMatrixMultiply(&_modelViewMatrix, &_rotationMatrix, &_modelViewMatrix);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}

-(void)resetRotation
{
    ksMatrixLoadIdentity(&_rotationMatrix);
    _previousOrientation.ToIdentity();
    _orientation.ToIdentity();
}

-(void)drawSurface
{
    if (_currentVBO == nil)
        return;
    
    glBindBuffer(GL_ARRAY_BUFFER, [_currentVBO vertexBuffer]);
    
    /*
     当使用顶点数组(GL_ARRAY_BUFFER)进行渲染时，需要使用的渲染函数
     void glVertexAttribPointer (GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const GLvoid* ptr);
     
        参数 index ：为顶点数据（如顶点，颜色，法线，纹理或点精灵大小）在着色器程序中的槽位；
        参数 size ：指定每一种数据的组成大小，比如顶点由 x, y, z 3个组成部分，纹理由 u, v 2个组成部分；
        参数 type ：表示每一个组成部分的数据格式；
        参数 normalized ： 表示当数据为法线数据时，是否需要将法线规范化为单位长度，对于其他顶点数据设置为 GL_FALSE 即可。如果法线向量已经为单位长度设置为 GL_FALSE 即可，这样可免去不必要的计算，提升效率；
        参数 stride ： 表示上一个数据到下一个数据之间的间隔（同样是以字节为单位），OpenGL ES根据该间隔来从由多个顶点数据混合而成的数据块中跳跃地读取相应的顶点数据；
        参数 ptr ：值得注意，这个参数是个多面手。如果没有使用 VBO，它指向 CPU 内存中的顶点数据数组；如果使用 VBO 绑定到 GL_ARRAY_BUFFER，那么它表示该种类型顶点数据在顶点缓存中的起始偏移量。
     */
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, [_currentVBO vertexSize] * sizeof(GLfloat), 0);
    glEnableVertexAttribArray(_positionSlot);
    
    glVertexAttrib4f(_colorSlot, 1.0, 0.0, 0.0, 1.0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, [_currentVBO triangleBuffer]);
        
    /*
     当使用索引数据(GL_ELELMENT_ARRAY_BUFFER)进行渲染时，需要调用的渲染函数
     void glDrawElements (GLenum mode, GLsizei count, GLenum type, const GLvoid* indices);
         
        参数 mode ：表示描绘的图元类型，如：GL_TRIANGLES，GL_LINES，GL_POINTS；
        参数 count ： 表示索引数据的个数；
        参数 type ： 表示索引数据的格式，必须是无符号整形值；
        indices ：这个参数也是个多面手，如果没有使用 VBO，它指向 CPU 内存中的索引数据数组；如果使用 VBO 绑定到 GL_ELEMENT_ARRAY_BUFFER，那么它表示索引数据在 VBO 中的偏移量。
    */
    glDrawElements(GL_TRIANGLES, [_currentVBO triangleSize], GL_UNSIGNED_SHORT, 0);
    
    glVertexAttrib4f(_colorSlot, 0.0, 0.0, 0.0, 1.0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, [_currentVBO lineBuffer]);
    glDrawElements(GL_LINES, [_currentVBO lineSize], GL_UNSIGNED_SHORT, 0);
    glDisableVertexAttribArray(_positionSlot);
}


//////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - Getter/Setter

//////////////////////////////////////////////////////////////////////////////////////////

-(void)setAmbient:(KSColor)inAmbient
{
    _ambient = inAmbient;
    [self render];
}

-(void)setDiffuse:(KSColor)inDiffuse
{
    _diffuse = inDiffuse;
    [self render];
}

-(void)setSpecular:(KSColor)inSpecular
{
    _specular = inSpecular;
    [self render];
}

-(void)setShininess:(GLfloat)inShininess
{
    _shininess = inShininess;
    [self render];
}

-(void)setLightPosition:(KSVec3)inLightPosition
{
    _lightPosition = inLightPosition;
    [self render];
}

//////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - public method

//////////////////////////////////////////////////////////////////////////////////////////

- (void)cleanup
{
    [self destroyVBO];
    
    [self destroyRenderAndFrameBuffer];
    
    if (_programHandle != 0) {
        glDeleteProgram(_programHandle);
        _programHandle = 0;
    }
    
    if (_eaglContext && [EAGLContext currentContext] == _eaglContext)
        [EAGLContext setCurrentContext:nil];
    
    _eaglContext = nil;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

#pragma mark - draw

-(void)render
{
    //  glClearColor (GLclampf red, GLclampf green, GLclampf blue, GLclampfalpha) 用来设置清屏颜色，默认为黑色；
    glClearColor(0.7, 0.7, 0.7, 1.0);
    //  glClear (GLbitfieldmask)用来指定要用清屏颜色来清除由mask指定的buffer，mask 可以是 GL_COLOR_BUFFER_BIT，GL_DEPTH_BUFFER_BIT和GL_STENCIL_BUFFER_BIT的自由组合。
    //  在这里我们只使用到 color buffer，所以清除的就是 color buffer。
    glClear(GL_COLOR_BUFFER_BIT);
    // 去掉被遮挡部分的渲染
    glEnable(GL_CULL_FACE);
    // 设置视口
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    [self updateSurfaceTransform];
    [self drawSurface];
    
    //  将指定 renderbuffer 呈现在屏幕上，在这里我们指定的是前面已经绑定为当前 renderbuffer 的那个，在 renderbuffer 可以被呈现之前，必须调用renderbufferStorage:fromDrawable: 为之分配存储空间。在前面设置 drawable 属性时，我们设置 kEAGLDrawablePropertyRetainedBacking 为FALSE，表示不想保持呈现的内容，因此在下一次呈现时，应用程序必须完全重绘一次。将该设置为 TRUE 对性能和资源影像较大，因此只有当renderbuffer需要保持其内容不变时，我们才设置 kEAGLDrawablePropertyRetainedBacking  为 TRUE。
    [_eaglContext presentRenderbuffer:GL_RENDERBUFFER];
}

//-(void)drawCube:(KSColor)color
//{
//    // 这里的示例，使用的都是从CPU主存中传递顶点数据到GPU中去进行运算与渲染。
//    
//    // vertices 和 indices 都是在主存中分配的内存空间
//    GLfloat vertices[] = {
//        0.0f, -0.5f, 0.5f,
//        0.0f, 0.5f, 0.5f,
//        1.0f, 0.5f, 0.5f,
//        1.0f, -0.5f, 0.5f,
//        
//        1.0f, -0.5f, -0.5f,
//        1.0f, 0.5f, -0.5f,
//        0.0f, 0.5f, -0.5f,
//        0.0f, -0.5f, -0.5f,
//    };
//    
//    GLubyte indeices[] = {
//        0, 1, 1, 2, 2, 3, 3, 0,
//        4, 5, 5, 6, 6, 7, 7, 4,
//        0, 7, 1, 6, 2, 5, 3, 4
//    };
//    
//    // 当需要进行渲染时，这些数据便通过 glDrawElements 或 glDrawArrays 从 CPU 主存中拷贝到 GPU 中去进行运算与渲染。
//    // 这种做法需要频繁地在 CPU 与 GPU 之间传递数据，效率低下
//    glVertexAttrib4f(_colorSlot, color.r, color.g, color.b, color.a);
//    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices);
//    glEnableVertexAttribArray(_positionSlot);
//    
//    glDrawElements(GL_LINES, sizeof(indeices) / sizeof(GLubyte), GL_UNSIGNED_BYTE, indeices);
//    
//    glDisableVertexAttribArray(_positionSlot);
//    
//}
//
//-(void)drawTricone
//{
//    GLfloat vertices[] = {
//        0.7f, 0.7f, 0.0f,
//        0.7f, -0.7f, 0.0f,
//        -0.7f, -0.7f, 0.0f,
//        -0.7f, 0.7f, 0.0f,
//        0.0f, 0.0f, -1.0f,
//    };
//    
//    GLubyte indices[] = {
//        0, 1, 1, 2, 2, 3, 3, 0,
//        4, 0, 4, 1, 4, 2, 4, 3
//    };
//    
//    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
//    glEnableVertexAttribArray(_positionSlot);
//    
//    // 获得当前设置的线宽度
//    GLfloat lineWidthRange[2];
//    glGetFloatv(GL_ALIASED_LINE_WIDTH_RANGE, lineWidthRange);
//    // Draw lines
//    //
//    glDrawElements(GL_LINES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
//}

#pragma mark - Touch events

- (void) touchesBegan: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint location  = [touch locationInView: self];
    
    _fingerStart = ivec2(location.x, location.y);
    _previousOrientation = _orientation;
}

- (void) touchesEnded: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint location  = [touch locationInView: self];
    ivec2 touchPoint = ivec2(location.x, location.y);
    
    vec3 start = [self mapToSphere:_fingerStart];
    vec3 end = [self mapToSphere:touchPoint];
    Quaternion delta = Quaternion::CreateFromVectors(start, end);
    _orientation = delta.Rotated(_previousOrientation);
    _orientation.ToMatrix4(&_rotationMatrix);
    
    [self render];
}

- (void) touchesMoved: (NSSet*) touches withEvent: (UIEvent*) event
{
    UITouch* touch = [touches anyObject];
    CGPoint location  = [touch locationInView: self];
    ivec2 touchPoint = ivec2(location.x, location.y);
    
    vec3 start = [self mapToSphere:_fingerStart];
    vec3 end = [self mapToSphere:touchPoint];
    Quaternion delta = Quaternion::CreateFromVectors(start, end);
    _orientation = delta.Rotated(_previousOrientation);
    _orientation.ToMatrix4(&_rotationMatrix);
    
    [self render];
}

@end
