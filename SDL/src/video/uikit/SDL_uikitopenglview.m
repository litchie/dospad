/*
 SDL - Simple DirectMedia Layer
 Copyright (C) 1997-2009 Sam Lantinga
 
 This library is free software; you can redistribute it and/or
 modify it under the terms of the GNU Lesser General Public
 License as published by the Free Software Foundation; either
 version 2.1 of the License, or (at your option) any later version.
 
 This library is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 Lesser General Public License for more details.
 
 You should have received a copy of the GNU Lesser General Public
 License along with this library; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 
 Sam Lantinga
 slouken@libsdl.org
 */

#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>
#import "SDL_uikitopenglview.h"

@interface SDL_uikitopenglview (privateMethods)

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation SDL_uikitopenglview

@synthesize context;
#ifdef IPHONEOS
@synthesize delegate;
#endif


+ (Class)layerClass {
	return [CAEAGLLayer class];
}

#ifdef IPHONEOS
-(BOOL)createFramebuffer
{
    /* create the buffers */
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
        
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        return NO;
    }
    return YES;
}

- (id)initCore
{
    int rBits = 0;
    int gBits = 0;
    int bBits = 0;
    int aBits = 0;
    BOOL retained = NO;//_this->gl_config.retained_backing
    NSString *colorFormat=nil;
    
    if (rBits == 8 && gBits == 8 && bBits == 8) 
    {
        /* if user specifically requests rbg888 or some color format higher than 16bpp */
        colorFormat = kEAGLColorFormatRGBA8;
    }
    else 
    {
        /* default case (faster) */
        colorFormat = kEAGLColorFormatRGB565;
    }
    
    // Get the layer
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool: retained], kEAGLDrawablePropertyRetainedBacking, 
                                    kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat, nil];
    
    context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES1];
    
    if (!context || ![EAGLContext setCurrentContext:context]) 
    {
        return nil;
    }           
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) 
    {
        self = [self initCore];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self = [self initCore];
    }
    return self;
}

#endif

- (id)initWithFrame:(CGRect)frame \
	  retainBacking:(BOOL)retained \
	  rBits:(int)rBits \
	  gBits:(int)gBits \
	  bBits:(int)bBits \
	  aBits:(int)aBits \
	  depthBits:(int)depthBits \
{
	
	NSString *colorFormat=nil;
	GLuint depthBufferFormat;
	BOOL useDepthBuffer;
	
	if (rBits == 8 && gBits == 8 && bBits == 8) {
		/* if user specifically requests rbg888 or some color format higher than 16bpp */
		colorFormat = kEAGLColorFormatRGBA8;
	}
	else {
		/* default case (faster) */
		colorFormat = kEAGLColorFormatRGB565;
	}
	
	if (depthBits == 24) {
		useDepthBuffer = YES;
		depthBufferFormat = GL_DEPTH_COMPONENT24_OES;
	}
	else if (depthBits == 0) {
		useDepthBuffer = NO;
	}
	else {
		/* default case when depth buffer is not disabled */
		/* 
		   strange, even when we use this, we seem to get a 24 bit depth buffer on iPhone.
		   perhaps that's the only depth format iPhone actually supports
		*/
		useDepthBuffer = YES;
		depthBufferFormat = GL_DEPTH_COMPONENT16_OES;
	}
	
	if ((self = [super initWithFrame:frame])) {
		// Get the layer
		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool: retained], kEAGLDrawablePropertyRetainedBacking, colorFormat, kEAGLDrawablePropertyColorFormat, nil];
		
		context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES1];
		
		if (!context || ![EAGLContext setCurrentContext:context]) {
			return nil;
		}
		
		/* create the buffers */
		glGenFramebuffersOES(1, &viewFramebuffer);
		glGenRenderbuffersOES(1, &viewRenderbuffer);
		
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
		[context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
		glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
		
		glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
		glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
		
		if (useDepthBuffer) {
			glGenRenderbuffersOES(1, &depthRenderbuffer);
			glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
			glRenderbufferStorageOES(GL_RENDERBUFFER_OES, depthBufferFormat, backingWidth, backingHeight);
			glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
		}
			
		if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
			return NO;
		}
		/* end create buffers */
	}
	return self;
}

- (void)setCurrentContext {
	[EAGLContext setCurrentContext:context];
}


- (void)swapBuffers {
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

#ifdef IPHONEOS


-(UIImage *) drawableToCGImage {
	CGRect myRect = self.bounds;
	NSInteger myDataLength = myRect.size.width * myRect.size.height * 4;
	void *buffer = (GLubyte *) malloc(myDataLength);
    
	glFinish();
	glPixelStorei(GL_PACK_ALIGNMENT, 4);
	
	glReadPixels(myRect.origin.x, myRect.origin.y, myRect.size.width, myRect.size.height, GL_RGB, GL_UNSIGNED_BYTE, buffer);
    
	NSData* myImageData = [NSData dataWithBytesNoCopy:(unsigned char const **)&buffer length:myDataLength freeWhenDone:YES];
	
	UIImage *myImage = [UIImage imageWithData:myImageData];
	if( myImage != nil) { NSLog(@"Save EAGLImage failed to bind data to a IUImage"); }
	//	free(myGLData); not needed - NSData:dataWithBytesNoCopy: The returned object takes ownership of the bytes pointer and frees it on deallocation. Therefore, bytes must point to a memory block allocated with malloc.
	
	return myImage;
}


- (UIImage*)capture
{
    return [self drawableToCGImage];
#if 0
    UIGraphicsBeginImageContext(self.bounds.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return viewImage;
#endif
}

- (void)resizeMain
{
    if (delegate) {
        [delegate onResize:newSize];
    }
}


- (BOOL)resize:(CGSize)sizeNew
{
    NSAssert([NSThread isMainThread], @"Resize must happen in main thread");
    if (self.bounds.size.width == sizeNew.width && 
        self.bounds.size.height == sizeNew.height )
    {
        return NO;
    }
    
    if (sizeNew.width > 1024 || sizeNew.height > 1024) {
        return NO;
    }
    
    newSize = sizeNew;
    [self resizeMain];
    return YES;
}

// Erases the screen
- (void) erase
{
	[EAGLContext setCurrentContext:context];
	
	//Clear the buffer
	glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
	glClearColor(0.0, 0.0, 0.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
	//Display the buffer
	glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
	[context presentRenderbuffer:GL_RENDERBUFFER_OES];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([touches count]==1 && [[touches anyObject] tapCount]==2) {
        UITouch *touch = [touches anyObject];
        CGPoint pt = [touch locationInView: self];
        if ([delegate onDoubleTap:pt]) {
            return;
        }
    }
    [super touchesBegan:touches withEvent:event];
}

#endif

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    CGRect brect = self.bounds;
    if (backingWidth == brect.size.width &&
        backingHeight == brect.size.height) {
        return;
    }

    [self destroyFramebuffer];
	[self createFramebuffer];
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glViewport(0, 0, brect.size.width, brect.size.height);
    glOrthof(0.0, (GLfloat) brect.size.width, (GLfloat) brect.size.height, 0.0,
                   0.0, 1.0);
    
    [self erase];
}

- (void)destroyFramebuffer {
	
	glDeleteFramebuffersOES(1, &viewFramebuffer);
	viewFramebuffer = 0;
	glDeleteRenderbuffersOES(1, &viewRenderbuffer);
	viewRenderbuffer = 0;
	
	if (depthRenderbuffer) {
		glDeleteRenderbuffersOES(1, &depthRenderbuffer);
		depthRenderbuffer = 0;
	}
}


- (void)dealloc {
		
	[self destroyFramebuffer];
	if ([EAGLContext currentContext] == context) {
		[EAGLContext setCurrentContext:nil];
	}
	
}

@end
