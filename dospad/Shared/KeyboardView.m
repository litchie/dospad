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

struct {
	const char *name;
	int code;
} keytable[] = {
	{"key-0",                         SDL_SCANCODE_0},
	{"key-1",                         SDL_SCANCODE_1},
	{"key-2",                         SDL_SCANCODE_2},
	{"key-3",                         SDL_SCANCODE_3},
	{"key-4",                         SDL_SCANCODE_4},
	{"key-5",                         SDL_SCANCODE_5},
	{"key-6",                         SDL_SCANCODE_6},
	{"key-7",                         SDL_SCANCODE_7},
	{"key-8",                         SDL_SCANCODE_8},
	{"key-9",                         SDL_SCANCODE_9},
	{"key-a",                         SDL_SCANCODE_A},
	{"key-b",                         SDL_SCANCODE_B},
	{"key-backslash",                 SDL_SCANCODE_BACKSLASH},
	{"key-backspace",                 SDL_SCANCODE_BACKSPACE},
	{"key-break",                     SDL_SCANCODE_PAUSE},
	{"key-c",                         SDL_SCANCODE_C},
	{"key-caps-lock",                 SDL_SCANCODE_CAPSLOCK},
	{"key-comma",                     SDL_SCANCODE_COMMA},

	{"key-d",                         SDL_SCANCODE_D},
	{"key-delete",                    SDL_SCANCODE_DELETE},
	{"key-down",                      SDL_SCANCODE_DOWN},
	{"key-e",                         SDL_SCANCODE_E},
	{"key-end",                       SDL_SCANCODE_END},
	{"key-enter",                     SDL_SCANCODE_RETURN},
	{"key-equals",                    SDL_SCANCODE_EQUALS},
	{"key-esc",                       SDL_SCANCODE_ESCAPE},
	{"key-f",                         SDL_SCANCODE_F},
	{"key-f1",                        SDL_SCANCODE_F1},
	{"key-f10",                       SDL_SCANCODE_F10},
	{"key-f11",                       SDL_SCANCODE_F11},
	{"key-f12",                       SDL_SCANCODE_F12},
	{"key-f2",                        SDL_SCANCODE_F2},
	{"key-f3",                        SDL_SCANCODE_F3},
	{"key-f4",                        SDL_SCANCODE_F4},
	{"key-f5",                        SDL_SCANCODE_F5},
	{"key-f6",                        SDL_SCANCODE_F6},
	{"key-f7",                        SDL_SCANCODE_F7},
	{"key-f8",                        SDL_SCANCODE_F8},
	{"key-f9",                        SDL_SCANCODE_F9},
	{"key-g",                         SDL_SCANCODE_G},
	{"key-grave",                     SDL_SCANCODE_GRAVE},
	{"key-h",                         SDL_SCANCODE_H},
	{"key-home",                      SDL_SCANCODE_HOME},
	{"key-i",                         SDL_SCANCODE_I},
	{"key-insert",                    SDL_SCANCODE_INSERT},
	{"key-j",                         SDL_SCANCODE_J},
	{"key-k",                         SDL_SCANCODE_K},
	{"key-kp-5",                      SDL_SCANCODE_KP_5},
	{"key-kp-add",                    SDL_SCANCODE_KP_PLUS},
	{"key-kp-delete",                 SDL_SCANCODE_KP_BACKSPACE},
	{"key-kp-divide",                 SDL_SCANCODE_KP_DIVIDE},
	{"key-kp-down",                   SDL_SCANCODE_KP_2},
	{"key-kp-end",                    SDL_SCANCODE_KP_1},
	{"key-kp-enter",                  SDL_SCANCODE_KP_ENTER},
	{"key-kp-home",                   SDL_SCANCODE_KP_7},
	{"key-kp-insert",                 SDL_SCANCODE_KP_0},
	{"key-kp-left",                   SDL_SCANCODE_KP_4},
	{"key-kp-multiply",               SDL_SCANCODE_KP_MULTIPLY},
	{"key-kp-page-down",              SDL_SCANCODE_KP_3},
	{"key-kp-page-up",                SDL_SCANCODE_KP_9},
	{"key-kp-right",                  SDL_SCANCODE_KP_6},
	{"key-kp-subtract",               SDL_SCANCODE_KP_MINUS},
	{"key-kp-up",                     SDL_SCANCODE_KP_8},
	{"key-l",                         SDL_SCANCODE_L},
	{"key-lalt",                      SDL_SCANCODE_LALT},
	{"key-lctrl",                     SDL_SCANCODE_LCTRL},
	{"key-left",                      SDL_SCANCODE_LEFT},
//	{"key-left-backslash",            SDL_SCANCODE_},
	{"key-left-bracket",              SDL_SCANCODE_LEFTBRACKET},
	{"key-lshift",                    SDL_SCANCODE_LSHIFT},
	{"key-m",                         SDL_SCANCODE_M},
	{"key-minus",                     SDL_SCANCODE_MINUS},
	{"key-n",                         SDL_SCANCODE_N},
	{"key-num-lock",                  SDL_SCANCODE_NUMLOCKCLEAR},
	{"key-o",                         SDL_SCANCODE_O},
	{"key-p",                         SDL_SCANCODE_P},
	{"key-page-down",                 SDL_SCANCODE_PAGEDOWN},
	{"key-page-up",                   SDL_SCANCODE_PAGEUP},
	{"key-pause",                     SDL_SCANCODE_PAUSE},
	{"key-period",                    SDL_SCANCODE_PERIOD},
	{"key-print",                     SDL_SCANCODE_PRINTSCREEN},
	{"key-q",                         SDL_SCANCODE_Q},
	{"key-quote",                     SDL_SCANCODE_APOSTROPHE},
	{"key-r",                         SDL_SCANCODE_R},
	{"key-ralt",                      SDL_SCANCODE_RALT},
	{"key-rctrl",                     SDL_SCANCODE_RCTRL},
	{"key-right",                     SDL_SCANCODE_RIGHT},
	{"key-right-bracket",             SDL_SCANCODE_RIGHTBRACKET},
	{"key-rshift",                    SDL_SCANCODE_RSHIFT},
	{"key-s",                         SDL_SCANCODE_S},
	{"key-scrl-lock",                 SDL_SCANCODE_SCROLLLOCK},
	{"key-semicolon",                 SDL_SCANCODE_SEMICOLON},
	{"key-slash",                     SDL_SCANCODE_SLASH},
	{"key-space",                     SDL_SCANCODE_SPACE},
	{"key-t",                         SDL_SCANCODE_T},
	{"key-tab",                       SDL_SCANCODE_TAB},
	{"key-u",                         SDL_SCANCODE_U},
	{"key-up",                        SDL_SCANCODE_UP},
	{"key-v",                         SDL_SCANCODE_V},
	{"key-w",                         SDL_SCANCODE_W},
	{"key-x",                         SDL_SCANCODE_X},
	{"key-y",                         SDL_SCANCODE_Y},
	{"key-z",                         SDL_SCANCODE_Z}
};

#define ARRAY_SIZE(a)  (sizeof(a)/sizeof(a[0]))

int scancode_by_name(const char *name)
{
	unsigned l, h;
	l = 0;
	h = ARRAY_SIZE(keytable);
	while (l < h) {
		unsigned mid = (l + h) / 2;
		int cmp = strcmp(name, keytable[mid].name);
		if (cmp > 0) {
			l = mid + 1;
		} else if (cmp < 0) {
			h = mid;
		} else {
			return keytable[mid].code;
		}
	}
	return SDL_SCANCODE_UNKNOWN;
}

#define LOCK_SIZE 5

@implementation KeyboardView
@synthesize externKeyDelegate;
@synthesize backgroundImage;
@synthesize keys;
@synthesize capsLock, numLock;

const CGFloat kIPhoneLandscapeKeyboardWidth = 480.0;//1024 : 288
const CGFloat kIPhoneLandscapeKeyboardHeight = 200.0;// : 288

-(KeyView*)createKey:(const char*)title code:(int)scancode x:(int)x y:(int)y width:(int)w height:(int)h
{

    KeyView *btn = [[KeyView alloc] initWithFrame:CGRectMake(x, y,w,h)];
    btn.code = scancode;
    btn.title = [NSString stringWithFormat:@"%s",title];
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
   
//   float scale = maxwidth / self.frame.size.width;
//   x0 *= scale;
//   kw *+ scale;
//   marginx *=
   
    
    [self createKey:"ESC" code:SDL_SCANCODE_ESCAPE x:x y:y width:kw height:kh];
    
    x = maxwidth - 12 * kw - 11 * marginx;
    rowY[0]=y;
    for (int i = 0; i < ARRAY_SIZE(combo_f); i++) {
        [self createKey:combo_f[i].title code:combo_f[i].code x:x y:y width:kw height:kh];
        x += kw+marginx;
    }
    
    // 1 2 3 4 5 ...
    y += kh + marginy*3;
    if (fullKeys) y+=0.2*kh;
    rowY[1]=y;
    x = x0;
    for (int i = 0; i < ARRAY_SIZE(combo_1); i++) {
        [self createKey:combo_1[i].title code:combo_1[i].code x:x y:y width:kw height:kh];
        x += kw+marginx;
    }
    [self createKey:" BS " code:SDL_SCANCODE_BACKSPACE x:x y:y width:maxwidth-x height:kh];
    
    // TAB Q W E R T Y ...
    y += kh + marginy;
    x = x0;
    rowY[2]=y;

    [self createKey:"TAB" code:SDL_SCANCODE_TAB x:x y:y width:kw*1.5 height:kh];

    x+=kw*1.5+marginx;
    
    for (int i = 0; i < ARRAY_SIZE(combo_2); i++) {
        [self createKey:combo_2[i].title code:combo_2[i].code x:x y:y width:kw height:kh];
        x += kw+marginx;
    }
    
    // CAPSLOCK A S D F ....
    y += kh + marginy;
    x = x0;
    rowY[3]=y;

    key=[self createKey:"CAPSLOCK" code:SDL_SCANCODE_CAPSLOCK x:x y:y width:kw*2 height:kh];
    self.capsLock=[[KeyLockIndicator alloc] initWithFrame:CGRectMake(8,8,LOCK_SIZE,LOCK_SIZE)];
    [key addSubview:self.capsLock];
    
    x+=kw*2+marginx;
    
    for (int i = 0; i < ARRAY_SIZE(combo_3); i++) {
        [self createKey:combo_3[i].title code:combo_3[i].code x:x y:y width:kw height:kh];
        x += kw+marginx;
    }
    [self createKey:"RETURN" code:SDL_SCANCODE_RETURN x:x y:y width:maxwidth-x height:kh];

    // SHIFT Z X C ...
    y += kh + marginy;
    x = x0;
    rowY[4]=y;

    [self createKey:"SHIFT" code:SDL_SCANCODE_LSHIFT x:x y:y width:kw*2.5 height:kh];
    x+=kw*2.5+marginx;
    for (int i = 0; i < ARRAY_SIZE(combo_4); i++) {
        [self createKey:combo_4[i].title code:combo_4[i].code x:x y:y width:kw height:kh];
        x += kw+marginx;
    }
    [self createKey:"SHIFT" code:SDL_SCANCODE_RSHIFT x:x y:y width:maxwidth-x height:kh];

    // CTRL, ALT, WHITESPACE, ...
    y+= kh + marginy;
    rowY[5]=y;

    x = x0;
    if (!fullKeys) {
        kh = 1.2 * kh;
    }
    [self createKey:"CTRL" code:SDL_SCANCODE_LCTRL x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    [self createKey:"ALT" code:SDL_SCANCODE_LALT x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    
    float spaceWidth;
    if (fullKeys) {
        spaceWidth = (maxwidth-3*kw-2*marginx-x);
    } else {
        spaceWidth = 5.5*kw;
    }
    
    [self createKey:" " code:SDL_SCANCODE_SPACE x:x y:y width:spaceWidth height:kh];
    x += spaceWidth + marginx;
    [self createKey:"ALT" code:SDL_SCANCODE_RALT x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    [self createKey:"CTRL" code:SDL_SCANCODE_RCTRL x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    
    if (!fullKeys) {
        float tmp_marginy = 5;
        x += 20;
        if (transparentKeys) {
            [self createKey:"    " code:SDL_SCANCODE_LEFT x:x y:y+kw+tmp_marginy width:kw height:kw];
            x += kw + marginx;
            [self createKey:"    " code:SDL_SCANCODE_DOWN x:x y:y+kw+tmp_marginy width:kw height:kw];
            [self createKey:"    " code:SDL_SCANCODE_UP x:x y:y+tmp_marginy width:kw height:kw];
            x += kw + marginx;
            [self createKey:"    " code:SDL_SCANCODE_RIGHT x:x y:y+kw+tmp_marginy width:kw height:kw];
        } else {
            [self createKey:"LEFT" code:SDL_SCANCODE_LEFT x:x y:y+kw+tmp_marginy width:kw height:kw];
            x += kw + marginx;
            [self createKey:"DOWN" code:SDL_SCANCODE_DOWN x:x y:y+kw+tmp_marginy width:kw height:kw];
            [self createKey:" UP " code:SDL_SCANCODE_UP x:x y:y+tmp_marginy width:kw height:kw];
            x += kw + marginx;
            [self createKey:"RIGHT" code:SDL_SCANCODE_RIGHT x:x y:y+kw+tmp_marginy width:kw height:kw];            
        }
    } else {
        x0 = maxwidth+(self.bounds.size.width-maxwidth-3*kw-2*marginx)/2;
        y = rowY[1];
        x = x0;
        [self createKey:"INS" code:SDL_SCANCODE_INSERT x:x y:y width:kw height:kh];
        x += kw+marginx;
        [self createKey:"HOME" code:SDL_SCANCODE_HOME x:x y:y width:kw height:kh];
        x += kw+marginx;
        [self createKey:"PGUP" code:SDL_SCANCODE_PAGEUP x:x y:y width:kw height:kh];
        ////////////////////
        y = rowY[2];
        x = x0;
        [self createKey:"DEL" code:SDL_SCANCODE_DELETE x:x y:y width:kw height:kh];
        x += kw+marginx;
        [self createKey:"END" code:SDL_SCANCODE_END x:x y:y width:kw height:kh];
        x += kw+marginx;
        [self createKey:"PGDN" code:SDL_SCANCODE_PAGEDOWN x:x y:y width:kw height:kh];
        ////////////////////
        y = rowY[4];
        x = x0+kw+marginx;
        [self createKey:" UP " code:SDL_SCANCODE_UP x:x y:y width:kw height:kh];
        x += kw+marginx;
        ////////////////////
        y = rowY[5];
        x = x0;
        [self createKey:"LEFT" code:SDL_SCANCODE_LEFT x:x y:y width:kw height:kh];
        x += kw+marginx;
        [self createKey:"DOWN" code:SDL_SCANCODE_DOWN x:x y:y width:kw height:kh];
        x += kw+marginx;
        [self createKey:"RIGHT" code:SDL_SCANCODE_RIGHT x:x y:y width:kw height:kh];
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
			int code = scancode_by_name(scancode.UTF8String);
			if (code == SDL_SCANCODE_UNKNOWN) {
				if ([scancode isEqualToString:@"key-fn"]) {
					code = FN_KEY;
				}
			}
			KeyView *key = [self createKey:label.UTF8String code:code
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

-(void)createIphonePortraitKeys
{
	int row = 5;
	int col = 11;
	if (self.frame.size.height > 240) {
		row = 6;
	}

	NSString *configFile = [NSString stringWithFormat:@"configs/kbd%dx%d%@.json", col,row,fnSwitch?@"_fn":@""];
	NSString *kbdFile = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:configFile];
	[self createKeysFromConfigFile:kbdFile];
}

-(void)createIphoneLandscapeKeys
{
	int row = 5;
	int col = 11;
	
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
                    [self createIphoneLandscapeKeys];
                    break;
                case KeyboardTypePortrait:
                    [self createIphonePortraitKeys];
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
			if (self.frame.size.width > 320) {
            	[self createIphoneLandscapeKeys];
			} else {
            	[self createIphonePortraitKeys];
			}
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
