//
//  EAGLView.h
//  OpenGLES_iPhone
//
//  Created by mmalc Crawford on 11/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EAGLContext;

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{
@private
    EAGLContext * context; // The only one OpenGL context

	GLint _width, _height; // // The pixel dimensions of the CAEAGLLayer.

	// The OpenGL ES names for the framebuffer and renderbuffer used to render to this view
	GLuint _framebuffer, _colorRenderbuffer, _depthRenderbuffer;
	GLuint _aaFrameBuffer, _aaColorBuffer, _aaDepthBuffer; // Used for AA mode only

	GLuint _depthBufferBits; // Depthbuffer depth
	BOOL _deviceHighRes; // Whether device has high-resolution screens (iPhone4)
	GLint _AAMaxSamples; // Corresponds to kFullScreenAntiAliasing
	GLint _isAASupported; // Set by checking relevant GL ext
	GLint _enableFramebufferDiscard; // For use with AA
}

// You can think of a property declaration as being equivalent to declaring two
// accessor methods.
@property (readonly) GLint layerWidth;
@property (readonly) GLint layerHeight;

- (id)initWithFrame:(CGRect)frame highRes:(GLbyte)highRes;
- (BOOL)createSurface;
- (void)destroySurface;
- (void)setFramebuffer; // Should be called prior to frame draw
- (void)presentFramebuffer; // Call in the end of frame draw

@end
