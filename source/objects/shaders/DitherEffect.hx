package objects.shaders;

import flixel.system.FlxAssets.FlxShader;

/**
 * Dithering class because I like Baldi's Basics.
 * @author MTM101, ERIZUR and T5MPLER
 */

class DitherEffect
{
    public var shader(default,null):DitherShader = new DitherShader();
    public function new():Void {}
}

class DitherShader extends FlxShader
{
    // couldn't find a shadertoy link srry http://devlog-martinsh.blogspot.com/2011/03/glsl-8x8-bayer-matrix-dithering.html
    @:glFragmentSource('
        #pragma header
        #extension GL_ARB_arrays_of_arrays : require
        // Ordered dithering aka Bayer matrix dithering

        float Scale = 1.0;

        float find_closest(int x, int y, float c0)
        {

        int dither[8][8] = {
        { 0, 32, 8, 40, 2, 34, 10, 42}, /* 8x8 Bayer ordered dithering */
        {48, 16, 56, 24, 50, 18, 58, 26}, /* pattern. Each input pixel */
        {12, 44, 4, 36, 14, 46, 6, 38}, /* is scaled to the 0..63 range */
        {60, 28, 52, 20, 62, 30, 54, 22}, /* before looking in this table */
        { 3, 35, 11, 43, 1, 33, 9, 41}, /* to determine the action. */
        {51, 19, 59, 27, 49, 17, 57, 25},
        {15, 47, 7, 39, 13, 45, 5, 37},
        {63, 31, 55, 23, 61, 29, 53, 21} };

        float limit = 0.0;
        if(x < 8)
        {
            limit = (dither[x][y]+1)/64.0;
        }


        if(c0 < limit)
            return 0.0;
            return 1.0;
        }

        void main(void)
        {
            vec4 lum = vec4(0.299, 0.587, 0.114, 0);
            float grayscale = dot(texture2D(bitmap, openfl_TextureCoordv), lum);
            vec4 rgba = texture2D(bitmap, openfl_TextureCoordv).rgba;

            vec2 xy = gl_FragCoord.xy * Scale;
            int x = int(mod(xy.x, 8.0));
            int y = int(mod(xy.y, 8.0));

            vec4 finalRGB;
            finalRGB.r = find_closest(x, y, rgba.r);
            finalRGB.g = find_closest(x, y, rgba.g);
            finalRGB.b = find_closest(x, y, rgba.b);
            finalRGB.a = find_closest(x, y, rgba.a);

            float final = find_closest(x, y, grayscale);
            gl_FragColor = finalRGB;
        }
    ')

    public function new()
    {
        super();
    }
}