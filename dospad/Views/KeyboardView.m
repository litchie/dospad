/*
 *  Copyright (C) 2010  Chaoji Li
 *
 *  DOSPAD is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#import "KeyboardView.h"
#import "KeyView.h"
#import "Common.h"
#include "SDL.h"
#import "ColorTheme.h"
#import "DPKeyBinding.h"
#import "DPThumbView.h"

extern int SDL_SendKeyboardKey(int index, Uint8 state, SDL_scancode scancode);


#define LOCK_SIZE 5

@interface KeyboardView () <DPThumbViewDelegate>
{
	NSString *_layoutFilename;
	DPThumbView *_thumbView;
	CGFloat _prevAlpha;
}

@end

@implementation KeyboardView
@synthesize externKeyDelegate;
@synthesize keys;
@synthesize capsLock, numLock;

const CGFloat kIPhoneLandscapeKeyboardWidth = 480.0;//1024 : 288
const CGFloat kIPhoneLandscapeKeyboardHeight = 200.0;// : 288

-(KeyView*)createKey:(NSString*)title code:(int)scancode x:(int)x y:(int)y width:(int)w height:(int)h
{

    KeyView *btn = [[KeyView alloc] initWithFrame:CGRectMake(x, y,w,h)];
    btn.code = scancode;
    btn.title = title;
    btn.delegate = self;
    [self addSubview:btn];
    self.keys = [self.keys arrayByAddingObject:btn];
    return btn;
}

- (void)removeKeys
{
    for (int i = 0; i < [keys count]; i++) 
    {
        KeyView *btn = [keys objectAtIndex:i];
        [btn removeFromSuperview];
    }    
    self.keys = nil;
}

- (void)createKeysFromConfigFile:(NSString*)kbdFile
{
	NSLog(@"kbdFile: %@", kbdFile);
	NSError *err = nil;
	NSArray *infoList = [NSJSONSerialization
					  JSONObjectWithData:[NSData dataWithContentsOfFile:kbdFile]
					  options:0
					  error:&err];
	if (!infoList) {
		NSLog(@"keyboard layout file error: %@", err);
		return;
	}
    [self removeKeys];
    self.keys = [NSArray array];
	
	_thumbView = nil;
	CGSize size = self.frame.size;
	if (infoList != nil && [infoList isKindOfClass:[NSArray class]]) {
		for (NSDictionary *info in infoList) {
			float x = [[info objectForKey:@"x"] floatValue];
			float y = [[info objectForKey:@"y"] floatValue];
			float w = [[info objectForKey:@"width"] floatValue];
			float h = [[info objectForKey:@"height"] floatValue];
			x *= size.width;
			y *= size.height;
			w *= size.width;
			h *= size.height;
			
			NSString *label = [info objectForKey:@"label"];
			NSString *scancode = [info objectForKey:@"scancode"];
		
			if ([scancode isEqualToString:@"key-thumb"]) {
				_thumbView = [[DPThumbView alloc] initWithFrame:CGRectMake(x, y, w, h)];
				_thumbView.delegate = self;
				_thumbView.text = info[@"label"];
				_thumbView.textColor = [[ColorTheme defaultTheme] colorByName:@"key-text-color"];
				[self addSubview:_thumbView];
				continue;
			}
			int code = [DPKeyBinding keyIndexFromName:scancode];
			KeyView *key = [self createKey:label code:code
				x:(int)x y:(int)y width:(int)w height:(int)(h)];
			key.altTitle = [info objectForKey:@"alt"];
			key.textColor      = [[ColorTheme defaultTheme] colorByName:@"key-text-color"];
			key.bkgColor       = [[ColorTheme defaultTheme] colorByName:@"key-color"];
			key.highlightColor = [[ColorTheme defaultTheme] colorByName:@"key-highlight-color"];
			key.bottomColor    = [[ColorTheme defaultTheme] colorByName:@"key-bottom-color"];
			if (code == SDL_SCANCODE_CAPSLOCK) {
				[key addSubview:self.capsLock];
			} else if (code == SDL_SCANCODE_NUMLOCKCLEAR) {
				[key addSubview:self.numLock];
			}
		}
	}
	[self updateKeyLock];
}

- (void)createKeys
{
	NSString *configFile = nil;
	
	if (_layoutFilename)
	{
		configFile = _layoutFilename;
	}
	else
	{
		int row = 5;
		int col = 11;
		if (self.bounds.size.height > 240) {
			row = 6;
		}
		configFile = [NSString stringWithFormat:@"kbd%dx%d", col, row];
	}
	
	configFile = [NSString stringWithFormat:@"configs/%@%@.json", configFile, fnSwitch?@"_fn":@""];
	NSString *kbdFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:configFile];
	[self createKeysFromConfigFile:kbdFile];
}

-(id)initWithFrame:(CGRect)frame layout:(NSString*)layoutConfig
{
	self = [self initWithFrame:frame];
	self.backgroundColor = [UIColor clearColor];
	self.numLock =[[KeyLockIndicator alloc] initWithFrame:CGRectMake(8,8,LOCK_SIZE,LOCK_SIZE)];
	self.capsLock =[[KeyLockIndicator alloc] initWithFrame:CGRectMake(8,8,LOCK_SIZE,LOCK_SIZE)];
	_layoutFilename = layoutConfig;
	[self createKeys];
	return self;
}

- (void)updateKeyLock
{
    SDLMod keystate = SDL_GetModState();
	if(keystate & KMOD_NUM) 
    {
        numLock.locked = YES;
    } 
    else 
    {
        numLock.locked = NO;
    }
	
	if (keystate & KMOD_CAPS) 
    {
        capsLock.locked=YES;
    } 
    else 
    {
        capsLock.locked=NO;
    }
}

- (void)onKeyDown:(KeyView*)k
{
	[self becomeOpaque];
    if (k.code == FN_KEY) 
    {
        fnSwitch = !fnSwitch;
        [self createKeys];
        if ( externKeyDelegate && [externKeyDelegate respondsToSelector:@selector(onKeyFunction:)]) {
            [externKeyDelegate onKeyFunction:k];
        }
    } 
    else if (externKeyDelegate) 
    {
        [externKeyDelegate onKeyDown:k];
    } 
    else 
    {
        if (k.code >= 0)
        {
            SDL_SendKeyboardKey( 0, SDL_PRESSED, k.code);
        }
    }
}

- (void)onKeyUp:(KeyView*)k
{
    if (externKeyDelegate)
    {
        [externKeyDelegate onKeyUp:k];
    } 
    else 
    {
        if (k.code >= 0) 
        {
            SDL_SendKeyboardKey( 0, SDL_RELEASED, k.code);
        }
        if (k.code==SDL_SCANCODE_CAPSLOCK ||
            k.code==SDL_SCANCODE_NUMLOCKCLEAR) 
        {
            [self updateKeyLock];
        }
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	if (_thumbView && _thumbView.showThumbOnly) {
		return CGRectContainsPoint(_thumbView.frame, point);
	} else {
		return [super pointInside:point withEvent:event];
	}
}

- (void)becomeTransparent
{
	if (_prevAlpha > 0) {
		[UIView animateWithDuration:0.1 animations:^{
            self.alpha = self->_prevAlpha;
			//self.backgroundColor = [UIColor clearColor];
            self->_prevAlpha = 0;
		}];
	}
}

- (void)becomeOpaque
{
	if (self.alpha != 1) {
		[UIView animateWithDuration:0.1 animations:^{
            self->_prevAlpha = self.alpha;
			self.alpha = 1;
			//self.backgroundColor = [UIColor blackColor];
		}];
	}
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(becomeTransparent) object:nil];
	[self performSelector:@selector(becomeTransparent) withObject:nil afterDelay:5];
}

// MARK: DPThumbViewDelegate

- (void)thumbViewDidMove:(DPThumbView*)thumbView
{
	if (_prevAlpha == 0) {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(becomeTransparent) object:nil];
		_prevAlpha = self.alpha;
		self.alpha = 1;
	}
}

- (void)thumbViewDidStop:(DPThumbView*)thumbView
{
	[self performSelector:@selector(becomeTransparent) withObject:nil afterDelay:5];
}


@end
