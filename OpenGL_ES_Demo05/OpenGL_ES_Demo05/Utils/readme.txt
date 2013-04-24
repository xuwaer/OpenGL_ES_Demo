GLSL中内置的顶点属性包括以下几个：

1.顶点属性

attribute vec4 gl_Color;              // 顶点颜色

attribute vec4 gl_SecondaryColor;     // 辅助顶点颜色

attribute vec3 gl_Normal;             // 顶点法线

attribute vec4 gl_Vertex;             // 顶点物体空间坐标（未变换）

attribute vec4 gl_MultiTexCoord[0-N]; // 顶点纹理坐标（N = gl_MaxTextureCoords）

attribute float gl_FogCoord;          // 顶点雾坐标


2.矩阵状态

uniform mat4 gl_ModelViewMatrix;                // 模型视图变换矩阵

uniform mat4 gl_ProjectMatrix;                  // 投影矩阵

uniform mat4 gl_ModelViewProjectMatrix;         // 模型视图投影变换矩阵（ftransform()）

uniform mat3 gl_NormalMatrix;                   // 法向量变换到视空间矩阵

uniform mat4 gl_TextureMatrix[gl_MatTextureCoords];     // 各纹理变换矩阵


3.普通缩放因子

uniform float gl_NormalScale;


4.窗口坐标深度范围

struct gl_DepthRangeParameters

{

    float near;

     float far;

    float diff; // far-near

};
uniform gl_DepthRangeParameters gl_DepthRange;


5.裁剪平面

uniform vec4 gl_ClipPlane[gl_MaxClipPlanes];


6.点属性

struct gl_PointParameters

{

    float size;

     float sizeMin;

    float sizeMax;

    float fadeThresholdSize;

     float distanceConstantAttenuation;

    float distanceLinearAttenuation;

    float distanceQuadraticAttenuation;

};
uniform gl_PointParameters gl_Point;


7.材质

struct gl_MaterialParameters

{

    vec4 emission;       // 自身光照Ecm

    vec4 ambient;        // 环境光吸收系数Acm

    vec4 diffuse;        // 漫反射吸收系数Dcm

    vec4 specular;       // 镜面反射吸收系数Scm

    float shininess;     // Srm

};
uniform gl_MaterialParameters gl_FrontMaterial;       // 正面材质
uniform gl_MaterialParameters gl_BackMaterial;        // 反面材质


8.光源性质，参数性质就不解释了，和OpenGL的三种光源性质是一样的

struct gl_LightSourceParameters

{

    vec4 ambient;                // Acii

    vec4 diffuse;                // Dcii

     vec4 specular;               // Scii

     vec4 position;               // Ppii

    vec4 halfVector;             // Hi

    vec3 spotDirection;          // Sdli

    float spotExponent;          // Srli

    float spotCutoff;            // Crli

     float spotCosCutoff;         // cos(Crli)

    float constantAttenuation;   // K0

    float linearAttenuation;     // K1

     float quadraticAttenuation; // K2

};
uniform gl_LightSourceParameters gl_LightSource[gl_MaxLights];

struct gl_LightModelParameters

{

    vec4 ambient;    // Acs

};
uniform gl_LightModelParameters gl_LightModel;


9.光照和材质的派生状态

struct gl_LightModelProducts

{

    vec4 sceneColor;       // Ecm+Acm*Acs

};
uniform gl_LightModelProducts gl_FrontLightModelProduct;
uniform gl_LightModelProducts gl_BackLightModelProduct;

struct gl_LightProducts

{

    vec4 ambient;      // Acm *　Acli

    vec4 diffuse;      // Dcm * Dcli

    vec4 specular;     // Scm * Scli

};
uniform gl_LightProducts gl_FrontLightProduct[gl_MaxLights];
uniform gl_LightProducts gl_BackLightProduct[gl_MaxLights];


10.纹理环境和生成

unifrom vec4 gl_TextureEnvColor[gl_MaxTextureImageUnits];

unifrom vec4 gl_EyePlaneS[gl_MaxTextureCoords];　

unifrom vec4 gl_EyePlaneT[gl_MaxTextureCoords];

unifrom vec4 gl_EyePlaneR[gl_MaxTextureCoords];

unifrom vec4 gl_EyePlaneQ[gl_MaxTextureCoords];

unifrom vec4 gl_ObjectPlaneS[gl_MaxTextureCoords];

unifrom vec4 gl_ObjectPlaneT[gl_MaxTextureCoords];

unifrom vec4 gl_ObjectPlaneR[gl_MaxTextureCoords];

unifrom vec4 gl_ObjectPlaneQ[gl_MaxTextureCoords];


11.雾参数

struct gl_FogParameters

{

    vec4 color;

    float density;

    float start;

    float end;

    float scale; // 1/(end-start)

};
uniform gl_FogParameters gl_Fog;


12.易变变量只能在顶点shader和片元shader间传递，这期间实际上经过了一个光栅化的过程。内置的易变变量比较少，如下：

varying vec4 gl_Color;

varying vec4 gl_SecondaryColor;

varying vec4 gl_TexCoord[gl_MaxTextureCoords];

varying float gl_FogFragCoord;

熟悉图形管线的话可以自己描绘出这些易变变量是如何在顶点和片元程序间进行传递的。

