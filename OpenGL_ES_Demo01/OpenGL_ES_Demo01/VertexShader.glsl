/**

Vertex shaders

在你的场景中，每个顶点都需要调用的程序，称为“顶点着色器”。假如你在渲染一个简单的场景：一个长方形，每个角只有一个顶点。
于是vertex shader 会被调用四次。它负责执行：诸如灯光、几何变换等等的计算。得出最终的顶点位置后，为下面的片段着色器提供必须的数据。

**/

// “attribute”声明了这个shader会接受一个传入变量，这个变量名为“vPosition”。在后面的代码中，你会用它来传入顶点的位置数据。这个变量的类型是“vec4”,表示这是一个由4部分组成的矢量。

attribute vec4 vPosition;

void main(void){
    // gl_Position 是一个内建的传出变量。这是一个在 vertex shader中必须设置的变量。这里我们直接把gl_Position = Position; 没有做任何逻辑运算。
    gl_Position = vPosition;
}