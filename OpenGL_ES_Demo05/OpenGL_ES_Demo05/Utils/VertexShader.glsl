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

/*
 * attribute 表示一些顶点的数据，如：顶点坐标，法线，纹理坐标，顶点颜色等。
 * vec4 表示4部分组成的矢量
 * attribute变量是只能在vertex shader中使用的变量。
 */
attribute vec4 vPosition;
attribute vec4 vSourceColor;
varying vec4 vDestinationColor;

/*
 * varying变量是vertex和fragment shader之间做数据传递用的。
 * 一般vertex shader修改varying变量的值，然后fragment shader使用该varying变量的值。
 * 因此varying变量在vertex和fragment shader二者之间的声明必须是一致的。
 */

void main(void){

    // gl_Position 是一个内建的传出变量。这是一个在 vertex shader中必须设置的变量。这里我们直接把gl_Position = Position; 没有做任何逻辑运算。
    //
    gl_Position = projection * modelView * vPosition;
    vDestinationColor = vSourceColor;
}