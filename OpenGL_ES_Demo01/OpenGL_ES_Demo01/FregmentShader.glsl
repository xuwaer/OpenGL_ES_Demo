/**

Fragment shaders

在你的场景中，大概每个像素都会调用的程序，称为“片段着色器”。
在一个简单的场景，长方形。这个长方形所覆盖到的每一个像素，都会调用一次fragment shader。
片段着色器的责任是计算灯光，以及更重要的是计算出每个像素的最终颜色。

**/

precision mediump float;

void main() {
    // 正如你在vertex shader中必须设置gl_Position, 在fragment shader中必须设置gl_FragColor.
    gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
}