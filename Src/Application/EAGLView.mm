//
//  EAGLView.m
//  OpenGLES_iPhone
//
//  Created by Max Reshetey on xx/xx/11.
//  Copyright 2011 Max Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "EAGLView.h"

//#import "UIMyButton.h"

#include "constants.h"


@implementation EAGLView

@synthesize layerWidth=_width, layerHeight=_height;

// You must implement this method
+ (Class)layerClass { return [CAEAGLLayer class]; }

- (id)initWithFrame:(CGRect)frame highRes:(GLbyte)highRes
{
	if ((self = [super initWithFrame:frame])) // Double parenthesies not by accident
	{
		CAEAGLLayer * eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = TRUE;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE],
										kEAGLDrawablePropertyRetainedBacking,
                                        (kBitsPerPixel==32)?kEAGLColorFormatRGBA8:kEAGLColorFormatRGB565,
										kEAGLDrawablePropertyColorFormat, nil];

		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		if (context == nil) return nil;

		if (![self createSurface]) { [self release]; return nil; }

		// Init internal variables
		_deviceHighRes = highRes;
		_depthBufferBits = (kDepthBufferEnabled)?GL_DEPTH_COMPONENT24_OES:0; // Or GL_DEPTH_COMPONENT16;
		_AAMaxSamples = kFullScreenAntiAliasing;
		_isAASupported = 0;
		_enableFramebufferDiscard = 0;

		[self setMultipleTouchEnabled:YES]; // Enable multitouch
	}

	return self;
}

- (BOOL)createSurface
{
	CAEAGLLayer * eaglLayer = (CAEAGLLayer *)[self layer];

	if (![EAGLContext setCurrentContext:context])
	{
		return NO;
	}

	// UIView class reference
	// In general, you should not need to modify the value in this property.
	// However, if your application draws using OpenGL ES, you may want to change
	// the scale factor to support higher-resolution drawing on screens that support it.
	// For more information on how to adjust your OpenGL ES rendering environment, see
	// “Supporting High-Resolution Screens” in iOS Application Programming Guide
	// TODO: Setting this to 2.0 on iPhone 4 makes scene look significantly better.
	// You need to multiply to this factor when init'ing e.g. depth buffer further down.
	// Note: So in fact this is an app's internal resolution (value of 1.0 means 320x480 on iPhone 4!)
	// Note: This doesn't seem to impact perfomance (at least if <= 2.0)
	if (_deviceHighRes)
		[self setContentScaleFactor:2.0f];

	// Setup render and frame buffers
	glGenRenderbuffers(1, &_colorRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
	if(![context renderbufferStorage:GL_RENDERBUFFER fromDrawable:eaglLayer])
	{
		glDeleteRenderbuffers(1, &_colorRenderbuffer);
//		glBindRenderbuffer(GL_RENDERBUFFER_BINDING, oldRenderbuffer);
		return NO;
	}

	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_width);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_height);

	glGenFramebuffers(1, &_framebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);

	if (_depthBufferBits)
	{
		glGenRenderbuffers(1, &_depthRenderbuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderbuffer);
		glRenderbufferStorage(GL_RENDERBUFFER, _depthBufferBits, _width, _height);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderbuffer);
	}

	if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
    {
        NSLog(@"ERROR: Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

	// Setup full-screen antialiasing
	// Further in the code, check for kFullScreenAntiAliasing and mIsAASupported for using AA
#if kFullScreenAntiAliasing
	// Check if relevant extensions are supported (they are on iPhone3GS/4, iPad)
	const GLubyte * extensions = glGetString(GL_EXTENSIONS);
	_isAASupported = (strstr((const char *)extensions, "GL_APPLE_framebuffer_multisample") != NULL);
	_enableFramebufferDiscard = (strstr((const char *)extensions, "GL_EXT_discard_framebuffer") != NULL);
	if (_isAASupported)
	{
		GLint maxSamplesAllowed, samplesToUse;
		glGetIntegerv(GL_MAX_SAMPLES_APPLE, &maxSamplesAllowed);
		samplesToUse = _AAMaxSamples < maxSamplesAllowed ? _AAMaxSamples : maxSamplesAllowed;
		if (samplesToUse)
		{
			glGenFramebuffers(1, &_aaFrameBuffer);
			glBindFramebuffer(GL_FRAMEBUFFER, _aaFrameBuffer);
			glGenRenderbuffers(1, &_aaColorBuffer);
			glBindRenderbuffer(GL_RENDERBUFFER, _aaColorBuffer);
			glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, samplesToUse, GL_RGBA8_OES, _width, _height);
			glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _aaColorBuffer);
			if (_depthBufferBits)
			{
				glGenRenderbuffers(1, &_aaDepthBuffer);
				glBindRenderbuffer(GL_RENDERBUFFER, _aaDepthBuffer);
				glRenderbufferStorageMultisampleAPPLE(GL_RENDERBUFFER, samplesToUse, _depthBufferBits, _width, _height);
				glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _aaDepthBuffer);
			}
			if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
			{
				NSLog(@"ERROR: Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
				return NO;
			}
		}
	}
#endif

	return YES;
}

- (void)destroySurface
{
	// If, by some reason, stored context is not current, use stored one to release
	// all associated (with this stored context) buffers.
	EAGLContext * oldContext = [EAGLContext currentContext];
	if (oldContext != context)
		[EAGLContext setCurrentContext:context];

	if(_depthBufferBits && _depthRenderbuffer)
	{
		glDeleteRenderbuffers(1, &_depthRenderbuffer);
		_depthRenderbuffer = 0;
	}

	if (_colorRenderbuffer)
    {
        glDeleteRenderbuffers(1, &_colorRenderbuffer);
        _colorRenderbuffer = 0;
    }

    if (_framebuffer)
    {
        glDeleteFramebuffers(1, &_framebuffer);
        _framebuffer = 0;
    }

#if kFullScreenAntiAliasing
	if (_isAASupported)
	{
		if(_depthBufferBits && _aaDepthBuffer)
		{
			glDeleteRenderbuffers(1, &_aaDepthBuffer);
			_aaDepthBuffer = 0;
		}

		if (_aaColorBuffer)
		{
			glDeleteRenderbuffers(1, &_aaColorBuffer);
			_aaColorBuffer = 0;
		}

		if (_aaFrameBuffer)
		{
			glDeleteFramebuffers(1, &_aaFrameBuffer);
			_aaFrameBuffer = 0;
		}
	}
#endif

	// Buffers released, now store the proper current context (in case stored one is not current)
	if (oldContext != context)
		[EAGLContext setCurrentContext:oldContext];
}

- (void)layoutSubviews
{
	[self destroySurface];
	[self createSurface];

	// Widen viewport setup for both orientations (though portret is rather unlikely)
	if (_width > _height)
		glViewport(0, (_height-_width)*0.5f, _width, _width);
	else
		glViewport((_width-_height)*0.5f, 0, _height, _height);

	NSLog(@"EAGLView: Layout called, w: %d, h: %d", _width, _height);
}

- (void)dealloc
{
	[self destroySurface];

    // Tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];

    [context release];

    [super dealloc];
}

- (void)setFramebuffer
{
#if kFullScreenAntiAliasing
//	if (mIsAASupported) // Let's think its always supported, cos we're not running old devices (e.g. iPhone3G)
//	{
	glBindFramebuffer(GL_FRAMEBUFFER, _aaFrameBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, _aaColorBuffer);
//	}
#else
	glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
#endif
}

- (void)presentFramebuffer
{
#if kFullScreenAntiAliasing
//	if (mIsAASupported)
//	{
		glDisable(GL_SCISSOR_TEST);
		glBindFramebuffer(GL_READ_FRAMEBUFFER_APPLE, _aaFrameBuffer);
		glBindFramebuffer(GL_DRAW_FRAMEBUFFER_APPLE, _framebuffer);
		glResolveMultisampleFramebufferAPPLE();
		if (_enableFramebufferDiscard)
		{
			GLenum attachments[] = { GL_COLOR_ATTACHMENT0, GL_DEPTH_ATTACHMENT, GL_STENCIL_ATTACHMENT };
			glDiscardFramebufferEXT(GL_READ_FRAMEBUFFER_APPLE, 3, attachments);
		}
//	}
#endif
	glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER];
}

@end
