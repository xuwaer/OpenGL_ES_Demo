/**

Vertex shaders

在你的场景中，每个顶点都需要调用的程序，称为“顶点着色器”。假如你在渲染一个简单的场景：一个长方形，每个角只有一个顶点。
于是vertex shader 会被调用四次。它负责执行：诸如灯光、几何变换等等的计算。得出最终的顶点位置后，为下面的片段着色器提供必须的数据。

**/


/*
 * uniform变量一般用来表示：变换矩阵，材质，光照参数和颜色等信息。
 * mat4 表示一个4x4矩阵
 */
uniform mat4 projection;
uniform mat4 modelView;

uniform mat3 normalMatrix;              //法线变换矩阵
uniform vec3 vLightPosition;            
uniform vec4 vAmbientMaterial;
uniform vec4 vSpecularMaterial;
uniform float shininess;

/*
 * attribute 表示一些顶点的数据，如：顶点坐标，法线，纹理坐标，顶点颜色等。
 * vec4 表示4部分组成的矢量
 * attribute变量是只能在vertex shader中使用的变量。
 */
attribute vec4 vPosition;
attribute vec4 vSourceColor;

attribute vec3 vNormal;
attribute vec4 vDiffuseMaterial;

/*
 * varying变量是vertex和fragment shader之间做数据传递用的。
 * 一般vertex shader修改varying变量的值，然后fragment shader使用该varying变量的值。
 * 因此varying变量在vertex和fragment shader二者之间的声明必须是一致的。
 */
varying vec4 vDestinationColor;


void main(void){

    // gl_Position 是一个内建的传出变量。这是一个在 vertex shader中必须设置的变量。这里我们直接把gl_Position = Position; 没有做任何逻辑运算。
    //
    gl_Position = projection * modelView * vPosition;
    
    
    vec3 N = normalMatrx * vNormal;                 //顶点法向量
    vec3 L = normalize(vLightPosition);             //光照向量
    vec3 E = vec3(0, 0, 1);                         //视线向量
    vec3 H = normalize(L + E);                      //视线向量与光照向量的半向量

    float df = max(0.0, dot(N, L));                 //漫反射因子
    float sf = max(0.0, dot(N, H));                 //
    sf = pow(sf, shininess);                        //镜面反射因子

    // 光照颜色 = 发射颜色 + 全局环境颜色 + (环境颜色 + 漫反射颜色 + 镜面反射颜色) × 聚光灯效果 × 衰减因子
    // 这里没有发色颜色、全局环境颜色、聚光灯效果和衰减因子。
    vDestinationColor = vAmbientMaterial + df * vDiffuseMaterial + sf * vSpecularMaterial;
}