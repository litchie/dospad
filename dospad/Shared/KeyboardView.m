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

extern int SDL_SendKeyboardKey(int index, Uint8 state, SDL_scancode scancode);

KeyDesc combo_f[12] = {
    {"F1", SDL_SCANCODE_F1},
    {"F2", SDL_SCANCODE_F2},
    {"F3", SDL_SCANCODE_F3},
    {"F4", SDL_SCANCODE_F4},
    {"F5", SDL_SCANCODE_F5},
    {"F6", SDL_SCANCODE_F6},
    {"F7", SDL_SCANCODE_F7},
    {"F8", SDL_SCANCODE_F8},
    {"F9", SDL_SCANCODE_F9},
    {"F10", SDL_SCANCODE_F10},
    {"F11", SDL_SCANCODE_F11},
    {"F12", SDL_SCANCODE_F12}
};

KeyDesc combo_1[] = {
    {"`~", SDL_SCANCODE_GRAVE},
    {"1!", SDL_SCANCODE_1},
    {"2@", SDL_SCANCODE_2},
    {"3#", SDL_SCANCODE_3},
    {"4$", SDL_SCANCODE_4},
    {"5%", SDL_SCANCODE_5},
    {"6^", SDL_SCANCODE_6},
    {"7&", SDL_SCANCODE_7},
    {"8*", SDL_SCANCODE_8},
    {"9(", SDL_SCANCODE_9},
    {"0)", SDL_SCANCODE_0},
    {"-_", SDL_SCANCODE_MINUS},
    {"=+", SDL_SCANCODE_EQUALS}
};

KeyDesc combo_2[] = {
    {"Q", SDL_SCANCODE_Q},
    {"W", SDL_SCANCODE_W},
    {"E", SDL_SCANCODE_E},
    {"R", SDL_SCANCODE_R},
    {"T", SDL_SCANCODE_T},
    {"Y", SDL_SCANCODE_Y},
    {"U", SDL_SCANCODE_U},
    {"I", SDL_SCANCODE_I},
    {"O", SDL_SCANCODE_O},
    {"P", SDL_SCANCODE_P},
    {"[{", SDL_SCANCODE_LEFTBRACKET},
    {"]}", SDL_SCANCODE_RIGHTBRACKET},
    {"\\|", SDL_SCANCODE_BACKSLASH}
};

KeyDesc combo_3[] = {
    {"A", SDL_SCANCODE_A},
    {"S", SDL_SCANCODE_S},
    {"D", SDL_SCANCODE_D},
    {"F", SDL_SCANCODE_F},
    {"G", SDL_SCANCODE_G},
    {"H", SDL_SCANCODE_H},
    {"J", SDL_SCANCODE_J},
    {"K", SDL_SCANCODE_K},
    {"L", SDL_SCANCODE_L},
    {";:", SDL_SCANCODE_SEMICOLON},
    {"\'\"", SDL_SCANCODE_APOSTROPHE}
};

KeyDesc combo_4[] = {
    {"Z", SDL_SCANCODE_Z},
    {"X", SDL_SCANCODE_X},
    {"C", SDL_SCANCODE_C},
    {"V", SDL_SCANCODE_V},
    {"B", SDL_SCANCODE_B},
    {"N", SDL_SCANCODE_N},
    {"M", SDL_SCANCODE_M},
    {",<", SDL_SCANCODE_COMMA},
    {".>", SDL_SCANCODE_PERIOD},
    {"/?", SDL_SCANCODE_SLASH}
};


#define LOCK_SIZE 5

@implementation KeyboardView
@synthesize externKeyDelegate;
@synthesize backgroundImage;
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
    btn.padding = keyPadding;
    
    if (transparentKeys)
    {
        btn.bkgColor = [UIColor clearColor];
        btn.edgeColor = [UIColor clearColor];
    }

    if (btn.code == SDL_SCANCODE_LEFT ||
        btn.code == SDL_SCANCODE_RIGHT ||
        btn.code == SDL_SCANCODE_UP ||
        btn.code == SDL_SCANCODE_DOWN)
    {
        btn.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    }
    
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

- (void)createIPadPortraitKeys
{
    [self removeKeys];
    KeyView *key;
    BOOL fullKeys = FALSE;
    int mainKeysWidth = fullKeys?780:740;
    self.keys = [NSArray array];
    float x0 = 15;
    float marginy = 3.5;
    float kw = 42.5;
    float kh = 44;
    float marginx = (mainKeysWidth-x0-x0-14.5*kw)/13;
    float x = x0;
    float y = 15;
    float maxwidth = x0 + kw * 1.5 + 13 * (kw + marginx);
    float rowY[6];
   
    [self createKey:@"ESC" code:SDL_SCANCODE_ESCAPE x:x y:y width:kw height:kh];
    
    x = maxwidth - 12 * kw - 11 * marginx;
    rowY[0]=y;
    for (int i = 0; i < ARRAY_SIZE(combo_f); i++) {
        [self createKey:@(combo_f[i].title) code:combo_f[i].code x:x y:y width:kw height:kh];
        x += kw+marginx;
    }
    
    // 1 2 3 4 5 ...
    y += kh + marginy*3;
    if (fullKeys) y+=0.2*kh;
    rowY[1]=y;
    x = x0;
    for (int i = 0; i < ARRAY_SIZE(combo_1); i++) {
        [self createKey:@(combo_1[i].title) code:combo_1[i].code x:x y:y width:kw height:kh];
        x += kw+marginx;
    }
    [self createKey:@" BS " code:SDL_SCANCODE_BACKSPACE x:x y:y width:maxwidth-x height:kh];
    
    // TAB Q W E R T Y ...
    y += kh + marginy;
    x = x0;
    rowY[2]=y;

    [self createKey:@"TAB" code:SDL_SCANCODE_TAB x:x y:y width:kw*1.5 height:kh];

    x+=kw*1.5+marginx;
    
    for (int i = 0; i < ARRAY_SIZE(combo_2); i++) {
        [self createKey:@(combo_2[i].title) code:combo_2[i].code x:x y:y width:kw height:kh];
        x += kw+marginx;
    }
    
    // CAPSLOCK A S D F ....
    y += kh + marginy;
    x = x0;
    rowY[3]=y;

    key=[self createKey:@"CAPSLOCK" code:SDL_SCANCODE_CAPSLOCK x:x y:y width:kw*2 height:kh];
    self.capsLock=[[KeyLockIndicator alloc] initWithFrame:CGRectMake(8,8,LOCK_SIZE,LOCK_SIZE)];
    [key addSubview:self.capsLock];
    
    x+=kw*2+marginx;
    
    for (int i = 0; i < ARRAY_SIZE(combo_3); i++) {
        [self createKey:@(combo_3[i].title) code:combo_3[i].code x:x y:y width:kw height:kh];
        x += kw+marginx;
    }
    [self createKey:@"RETURN" code:SDL_SCANCODE_RETURN x:x y:y width:maxwidth-x height:kh];

    // SHIFT Z X C ...
    y += kh + marginy;
    x = x0;
    rowY[4]=y;

    [self createKey:@"SHIFT" code:SDL_SCANCODE_LSHIFT x:x y:y width:kw*2.5 height:kh];
    x+=kw*2.5+marginx;
    for (int i = 0; i < ARRAY_SIZE(combo_4); i++) {
        [self createKey:@(combo_4[i].title) code:combo_4[i].code x:x y:y width:kw height:kh];
        x += kw+marginx;
    }
    [self createKey:@"SHIFT" code:SDL_SCANCODE_RSHIFT x:x y:y width:maxwidth-x height:kh];

    // CTRL, ALT, WHITESPACE, ...
    y+= kh + marginy;
    rowY[5]=y;

    x = x0;
    if (!fullKeys) {
        kh = 1.2 * kh;
    }
    [self createKey:@"CTRL" code:SDL_SCANCODE_LCTRL x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    [self createKey:@"ALT" code:SDL_SCANCODE_LALT x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    
    float spaceWidth;
    if (fullKeys) {
        spaceWidth = (maxwidth-3*kw-2*marginx-x);
    } else {
        spaceWidth = 5.5*kw;
    }
    
    [self createKey:@" " code:SDL_SCANCODE_SPACE x:x y:y width:spaceWidth height:kh];
    x += spaceWidth + marginx;
    [self createKey:@"ALT" code:SDL_SCANCODE_RALT x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    [self createKey:@"CTRL" code:SDL_SCANCODE_RCTRL x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    
    if (!fullKeys) {
        float tmp_marginy = 5;
        x += 20;
        if (transparentKeys) {
            [self createKey:@"    " code:SDL_SCANCODE_LEFT x:x y:y+kw+tmp_marginy width:kw height:kw];
            x += kw + marginx;
            [self createKey:@"    " code:SDL_SCANCODE_DOWN x:x y:y+kw+tmp_marginy width:kw height:kw];
            [self createKey:@"    " code:SDL_SCANCODE_UP x:x y:y+tmp_marginy width:kw height:kw];
            x += kw + marginx;
            [self createKey:@"    " code:SDL_SCANCODE_RIGHT x:x y:y+kw+tmp_marginy width:kw height:kw];
        } else {
            [self createKey:@"LEFT" code:SDL_SCANCODE_LEFT x:x y:y+kw+tmp_marginy width:kw height:kw];
            x += kw + marginx;
            [self createKey:@"DOWN" code:SDL_SCANCODE_DOWN x:x y:y+kw+tmp_marginy width:kw height:kw];
            [self createKey:@" UP " code:SDL_SCANCODE_UP x:x y:y+tmp_marginy width:kw height:kw];
            x += kw + marginx;
            [self createKey:@"RIGHT" code:SDL_SCANCODE_RIGHT x:x y:y+kw+tmp_marginy width:kw height:kw];
        }
    } else {
        x0 = maxwidth+(self.bounds.size.width-maxwidth-3*kw-2*marginx)/2;
        y = rowY[1];
        x = x0;
        [self createKey:@"INS" code:SDL_SCANCODE_INSERT x:x y:y width:kw height:kh];
        x += kw+marginx;
        [self createKey:@"HOME" code:SDL_SCANCODE_HOME x:x y:y width:kw height:kh];
        x += kw+marginx;
        [self createKey:@"PGUP" code:SDL_SCANCODE_PAGEUP x:x y:y width:kw height:kh];
        ////////////////////
        y = rowY[2];
        x = x0;
        [self createKey:@"DEL" code:SDL_SCANCODE_DELETE x:x y:y width:kw height:kh];
        x += kw+marginx;
        [self createKey:@"END" code:SDL_SCANCODE_END x:x y:y width:kw height:kh];
        x += kw+marginx;
        [self createKey:@"PGDN" code:SDL_SCANCODE_PAGEDOWN x:x y:y width:kw height:kh];
        ////////////////////
        y = rowY[4];
        x = x0+kw+marginx;
        [self createKey:@" UP " code:SDL_SCANCODE_UP x:x y:y width:kw height:kh];
        x += kw+marginx;
        ////////////////////
        y = rowY[5];
        x = x0;
        [self createKey:@"LEFT" code:SDL_SCANCODE_LEFT x:x y:y width:kw height:kh];
        x += kw+marginx;
        [self createKey:@"DOWN" code:SDL_SCANCODE_DOWN x:x y:y width:kw height:kh];
        x += kw+marginx;
        [self createKey:@"RIGHT" code:SDL_SCANCODE_RIGHT x:x y:y width:kw height:kh];
    }
    
    // On iPad, we will recreate keyboard
    // after rotation. So we need to refresh
    // Lock states.
    [self updateKeyLock];
}


-(void)createNumPadKeys
{
	NSString *configFile = [NSString stringWithFormat:@"configs/kpad4x5.json"];
	NSString *kbdFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:configFile];
	[self createKeysFromConfigFile:kbdFile];
}

-(void)createIPadLandscapeKeys
{
	NSString *configFile = [NSString stringWithFormat:@"configs/kbd18x5%@.json",fnSwitch?@"_fn":@""];
	NSString *kbdFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:configFile];
	[self createKeysFromConfigFile:kbdFile];
}

- (void)createKeysFromConfigFile:(NSString*)kbdFile
{

	NSLog(@"kbdFile: %@", kbdFile);
	
	NSArray *infoList = [NSJSONSerialization
					  JSONObjectWithData:[NSData dataWithContentsOfFile:kbdFile]
					  options:0
					  error:nil];
    [self removeKeys];
    self.keys = [NSArray array];
	
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
			int code = [DPKeyBinding keyIndexFromName:scancode];

			KeyView *key = [self createKey:label code:code
				x:(int)x y:(int)y width:(int)w height:(int)(h)];
			key.altTitle = [info objectForKey:@"alt"];
			key.textColor      = [[ColorTheme defaultTheme] colorByName:@"key-text-color"];
			key.bkgColor       = [[ColorTheme defaultTheme] colorByName:@"key-color"];
			key.highlightColor = [[ColorTheme defaultTheme] colorByName:@"key-highlight-color"];
			key.bottomColor    = [[ColorTheme defaultTheme] colorByName:@"key-bottom-color"];
			key.newStyle = YES;
			if (code == SDL_SCANCODE_CAPSLOCK) {
				[key addSubview:self.capsLock];
			} else if (code == SDL_SCANCODE_NUMLOCKCLEAR) {
				[key addSubview:self.numLock];
			}
		}
	}
	[self updateKeyLock];
}

-(void)createIphoneKeys
{
	int row = 5;
	int col = 11;
	if (self.bounds.size.height > 240) {
		row = 6;
	}

	NSString *configFile = [NSString stringWithFormat:@"configs/kbd%dx%d%@.json", col,row,fnSwitch?@"_fn":@""];
	NSString *kbdFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:configFile];
	[self createKeysFromConfigFile:kbdFile];
}

- (id)initWithType:(KeyboardType)type frame:(CGRect)frame
{
    if (self = [self initWithFrame:frame])
    {
        transparentKeys = YES;
		
        self.backgroundColor = [UIColor clearColor];
    	self.numLock =[[KeyLockIndicator alloc] initWithFrame:CGRectMake(8,8,LOCK_SIZE,LOCK_SIZE)];
    	self.capsLock =[[KeyLockIndicator alloc] initWithFrame:CGRectMake(8,8,LOCK_SIZE,LOCK_SIZE)];
		
        if (ISIPAD())
        {
            switch (type)
            {
                case KeyboardTypeLandscape:  
                {
                    [self createIPadLandscapeKeys];
                    break;
                }
                    
                case KeyboardTypePortrait:
                {
                    keyPadding = UIEdgeInsetsMake(2,  /* top */
                                                  5,  /* left */
                                                  7,  /* bottom */
                                                  6); /* right */
                    [self createIPadPortraitKeys];
                    break;
                }
                    
                default:
                    break;
            }
        }
        else
        {
            switch (type)
            {
                case KeyboardTypeNumPad:   
                    [self createNumPadKeys];
                    break;
                case KeyboardTypeLandscape: 
                case KeyboardTypePortrait:
                    [self createIphoneKeys];
                    break;
                default:
                    break;
            }     
        }
    }
    return self;
}


- (void)drawRect:(CGRect)rect 
{
    if (backgroundImage)
    {
        [backgroundImage drawInRect:rect];
    }
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
    if (k.code == FN_KEY) 
    {
        fnSwitch = !fnSwitch;
        if (ISIPAD()) 
        {
            [self createIPadLandscapeKeys];
        } 
        else 
        {
        	[self createIphoneKeys];
        }
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


@end
