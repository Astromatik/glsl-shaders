/*
   GBC Color Correction Shader
   A shader that replicates the LCD dynamics from a Game Boy Color
   Color values are derived from Gambatte's color correction implementation, with some tweaks.

   Based on Color Mangler
   Author: hunterk
   License: Public domain
*/

// Compatibility #ifdefs needed for parameters
#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

#pragma parameter darken_screen "Darken Screen" 0.0 -0.25 2.0 0.05
#ifdef PARAMETER_UNIFORM
// All parameter floats need to have COMPAT_PRECISION in front of them
uniform COMPAT_PRECISION float darken_screen;
#else
#define darken_screen 0.0
#endif

#define target_gamma 2.2
#define display_gamma 2.2
#define blr 0.0
#define blg 0.0
#define blb 0.0
#define r 0.78824
#define g 0.72941
#define b 0.82
#define rg 0.025
#define rb 0.12039
#define gr 0.12157
#define gb 0.12157
#define br 0.0
#define bg 0.275000

#if defined(VERTEX)

#if __VERSION__ >= 130
#define COMPAT_VARYING out
#define COMPAT_ATTRIBUTE in
#define COMPAT_TEXTURE texture
#else
#define COMPAT_VARYING varying 
#define COMPAT_ATTRIBUTE attribute 
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

COMPAT_ATTRIBUTE vec4 VertexCoord;
COMPAT_ATTRIBUTE vec4 COLOR;
COMPAT_ATTRIBUTE vec4 TexCoord;
COMPAT_VARYING vec4 COL0;
COMPAT_VARYING vec4 TEX0;

uniform mat4 MVPMatrix;
uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;

void main()
{
    gl_Position = MVPMatrix * VertexCoord;
    COL0 = COLOR;
    TEX0.xy = TexCoord.xy;
}

#elif defined(FRAGMENT)

#if __VERSION__ >= 130
#define COMPAT_VARYING in
#define COMPAT_TEXTURE texture
out vec4 FragColor;
#else
#define COMPAT_VARYING varying
#define FragColor gl_FragColor
#define COMPAT_TEXTURE texture2D
#endif

#ifdef GL_ES
#ifdef GL_FRAGMENT_PRECISION_HIGH
precision highp float;
#else
precision mediump float;
#endif
#define COMPAT_PRECISION mediump
#else
#define COMPAT_PRECISION
#endif

uniform COMPAT_PRECISION int FrameDirection;
uniform COMPAT_PRECISION int FrameCount;
uniform COMPAT_PRECISION vec2 OutputSize;
uniform COMPAT_PRECISION vec2 TextureSize;
uniform COMPAT_PRECISION vec2 InputSize;
uniform sampler2D Texture;
COMPAT_VARYING vec4 TEX0;

// compatibility #defines
#define Source Texture
#define vTexCoord TEX0.xy

#define SourceSize vec4(TextureSize, 1.0 / TextureSize) //either TextureSize or InputSize
#define outsize vec4(OutputSize, 1.0 / OutputSize)

void main()
{
   vec4 screen = pow(COMPAT_TEXTURE(Source, vTexCoord), vec4(target_gamma + darken_screen)).rgba;

   //                red   green  blue  alpha ; alpha does nothing for our purposes
   mat4 color = mat4(r,    rg,    rb,   0.0,    //red
                     gr,   g,     gb,   0.0,    //green
                     br,   bg,    b,    0.0,    //blue
                     blr,  blg,   blb,  0.0);   //black

   screen = color * screen;
   FragColor = pow(screen, vec4(1.0 / display_gamma));
} 
#endif
