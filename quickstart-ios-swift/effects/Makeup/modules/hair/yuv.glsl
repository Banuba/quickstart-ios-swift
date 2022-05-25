vec3 rgb2yuv(vec3 rgb)
{
    vec3 yuv;
    yuv.x = rgb.r * 0.299 + rgb.g * 0.587 + rgb.b * 0.114;
    yuv.y = rgb.r * -0.169 + rgb.g * -0.331 + rgb.b * 0.5 + 0.5;
    yuv.z = rgb.r * 0.5 + rgb.g * -0.419 + rgb.b * -0.081 + 0.5;
    return yuv;
}

vec3 yuv2rgb(vec3 yuv)
{
    float Y = yuv.x;
    vec2 UV = yuv.yz - 0.5;
    return vec3(Y + 1.4 * UV.y, Y - 0.343 * UV.x - 0.711 * UV.y, Y + 1.765 * UV.x);
}