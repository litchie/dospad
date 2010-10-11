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
@synthesize keys;
@synthesize externKeyDelegate;
@synthesize color;
@synthesize asOverlay;
@synthesize capsLock;
@synthesize numLock;


- (void)setAsOverlay:(BOOL)b
{
    asOverlay=b;
    if (b)
        self.color=[UIColor clearColor];
    else 
        self.color=[UIColor grayColor];
}

- (void)setColor:(UIColor *)c
{
    color = c;
    [c retain];
    [self setNeedsDisplay];
}

-(void)updateKeyLock
{
    SDLMod keystate = SDL_GetModState();
	if(keystate&KMOD_NUM) {
        self.numLock.locked=YES;
    } else {
        self.numLock.locked=NO;
    }
    
    for (int i = 0; i < [keys count]; i++) {
        KeyView *btn = [self.keys objectAtIndex:i];
        switch (btn.code) {
            case SDL_SCANCODE_KP_7:
                btn.title=numLock.locked?@"7":@"Home";
                break;
            case SDL_SCANCODE_KP_8:
                btn.title=numLock.locked?@"8":@" Up ";
                break;
            case SDL_SCANCODE_KP_9:
                btn.title=numLock.locked?@"9":@"PgUp";
                break;
            case SDL_SCANCODE_KP_4:
                btn.title=numLock.locked?@"4":@"Left";
                break;
            case SDL_SCANCODE_KP_5:
                btn.title=numLock.locked?@"5":@" ";
                break;
            case SDL_SCANCODE_KP_6:
                btn.title=numLock.locked?@"6":@"Right";
                break;
            case SDL_SCANCODE_KP_1:
                btn.title=numLock.locked?@"1":@"End";
                break;
            case SDL_SCANCODE_KP_2:
                btn.title=numLock.locked?@"2":@"Down";
                break;
            case SDL_SCANCODE_KP_3:
                btn.title=numLock.locked?@"3":@"PgDn";
                break;
            case SDL_SCANCODE_KP_0:
                btn.title=numLock.locked?@"0":@"Ins";
                break;
            case SDL_SCANCODE_KP_PERIOD:
                btn.title=numLock.locked?@".":@"Del";
                break;
        }
    }
    
	if(keystate&KMOD_CAPS) {
        self.capsLock.locked=YES;
    } else {
        self.capsLock.locked=NO;
    }
}

-(void)onKeyDown:(KeyView*)k
{
    if (k.code == FN_KEY) {
        fnSwitch = !fnSwitch;
        if (ISIPAD()) {
            [self createLandscapeKeys];
        } else {
            [self createIphoneKeys];
        }
    } else if (externKeyDelegate) {
        [externKeyDelegate onKeyDown:k];
    } else {
        if (k.code >= 0) {
            SDL_SendKeyboardKey( 0, SDL_PRESSED, k.code);
        }
    }
}

-(void)onKeyUp:(KeyView*)k
{
    if (externKeyDelegate) {
        [externKeyDelegate onKeyUp:k];
    } else {
        if (k.code >= 0) {
            SDL_SendKeyboardKey( 0, SDL_RELEASED, k.code);
        }
        if (k.code==SDL_SCANCODE_CAPSLOCK ||
            k.code==SDL_SCANCODE_NUMLOCKCLEAR) {
            [self updateKeyLock];
        }
    }
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(KeyView*)createKey:(const char*)title code:(int)scancode x:(int)x y:(int)y width:(int)w height:(int)h
{
    KeyView *btn = [[[KeyView alloc] initWithFrame:CGRectMake(x, y,w,h)] autorelease];
    [self addSubview:btn];
    btn.code = scancode;
    btn.title = [NSString stringWithFormat:@"%s",title];
    btn.delegate = self;
    self.keys = [self.keys arrayByAddingObject:btn];
    return btn;
}

-(void)createKeys
{
    for (int i = 0; i < [self.keys count]; i++) {
        KeyView *btn = [self.keys objectAtIndex:i];
        [btn removeFromSuperview];
    }
    KeyView *key;
    BOOL fullKeys = (self.frame.size.width > 800);
    int mainKeysWidth = 740;
    if (fullKeys) {
        mainKeysWidth = 780;
    }
    self.keys = [NSArray array];
    float x0 = 15;
    float marginy = 5;
    float kw = 42.5;
    float kh = 42.5;
    float marginx = (mainKeysWidth-x0-x0-14.5*kw)/13;
    float x = x0;
    float y = 10;
    float maxwidth = x0 + kw * 1.5 + 13 * (kw + marginx);
    float rowY[6];
    
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
    self.capsLock=[[[KeyLockIndicator alloc] initWithFrame:CGRectMake(8,8,LOCK_SIZE,LOCK_SIZE)] autorelease];
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
        if (asOverlay) {
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
    
    if (asOverlay) {
        for (int i = 0; i < [self.keys count]; i++) {
            KeyView *btn = [self.keys objectAtIndex:i];
            btn.bkgColor=[UIColor clearColor];
            btn.edgeColor=[UIColor clearColor];
            if (btn.code == SDL_SCANCODE_LEFT ||
                btn.code == SDL_SCANCODE_RIGHT ||
                btn.code == SDL_SCANCODE_UP ||
                btn.code == SDL_SCANCODE_DOWN)
            {
                btn.textColor=[UIColor whiteColor];
            }
            btn.padding=5;
        }
    }
    // On iPad, we will recreate keyboard
    // after rotation. So we need to refresh
    // Lock states.
    [self updateKeyLock];
}

-(void)createLandscapeKeys
{
    for (int i = 0; i < [self.keys count]; i++) {
        KeyView *btn = [self.keys objectAtIndex:i];
        [btn removeFromSuperview];
    }
    
    KeyView *key;
    self.keys = [NSArray array];
    float x0 = 18;
    float marginy = 5;
    float kw = 42.5;
    float kh = 42.5;
    float marginx = 7.3;
    float x = x0;
    float y = 1;
    float maxwidth = x0 + kw * 1.5 + 13 * (kw + marginx);
    float rowY[6];
    
    rowY[0] = y;
    if (fnSwitch) {
        [self createKey:"ESC" code:SDL_SCANCODE_ESCAPE x:x y:y width:kw height:kh];
        x += kw+marginx;
        for (int i = 0; i < ARRAY_SIZE(combo_f); i++) {
            [self createKey:combo_f[i].title code:combo_f[i].code x:x y:y width:kw height:kh];
            x += kw+marginx;
        }
    } else {
        for (int i = 0; i < ARRAY_SIZE(combo_1); i++) {
            [self createKey:combo_1[i].title code:combo_1[i].code x:x y:y width:kw height:kh];
            x += kw+marginx;
        }
    }
    [self createKey:" BS " code:SDL_SCANCODE_BACKSPACE x:x y:y width:maxwidth-x height:kh];
    
    // TAB Q W E R T Y ...
    y += kh + marginy;
    x = x0;
    rowY[1]=y;
    
    [self createKey:"TAB" code:SDL_SCANCODE_TAB x:x y:y width:kw*1.5 height:kh];
    
    x+=kw*1.5+marginx;
    
    for (int i = 0; i < ARRAY_SIZE(combo_2); i++) {
        [self createKey:combo_2[i].title code:combo_2[i].code x:x y:y width:kw height:kh];
        x += kw+marginx;
    }
    
    // CAPSLOCK A S D F ....
    y += kh + marginy;
    x = x0;
    rowY[2]=y;
    
    key=[self createKey:"CAPSLOCK" code:SDL_SCANCODE_CAPSLOCK x:x y:y width:kw*2 height:kh];
    self.capsLock=[[[KeyLockIndicator alloc] initWithFrame:CGRectMake(8,8,LOCK_SIZE,LOCK_SIZE)] autorelease];
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
    rowY[3]=y;
    
    [self createKey:"SHIFT" code:SDL_SCANCODE_LSHIFT x:x y:y width:kw*2.5 height:kh];
    x+=kw*2.5+marginx;
    for (int i = 0; i < ARRAY_SIZE(combo_4); i++) {
        [self createKey:combo_4[i].title code:combo_4[i].code x:x y:y width:kw height:kh];
        x += kw+marginx;
    }
    [self createKey:"SHIFT" code:SDL_SCANCODE_RSHIFT x:x y:y width:maxwidth-x height:kh];
    
    // CTRL, ALT, WHITESPACE, ...
    y+= kh + marginy;
    rowY[4]=y;
    
    x = x0;
    
    kh *= 1.2;
    
    [self createKey:" Fn " code:FN_KEY x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    
    [self createKey:"CTRL" code:SDL_SCANCODE_LCTRL x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    [self createKey:"ALT" code:SDL_SCANCODE_LALT x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    
    float spaceWidth = (maxwidth-3*kw-2*marginx-x);
    
    [self createKey:" " code:SDL_SCANCODE_SPACE x:x y:y width:spaceWidth height:kh];
    x += spaceWidth + marginx;
    [self createKey:"ALT" code:SDL_SCANCODE_RALT x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    [self createKey:"CTRL" code:SDL_SCANCODE_RCTRL x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    
    kh/=1.2; /* Restore key height */
    
    x0 = self.bounds.size.width-4*kw-4*marginx-12;
    
    // 1st Row
    //  [Num Lock]  [/]   [*]  [-]
    y = rowY[0];
    x = x0;
    key=[self createKey:"NumLk" code:SDL_SCANCODE_NUMLOCKCLEAR x:x y:y width:kw height:kh];
    self.numLock =[[[KeyLockIndicator alloc] initWithFrame:CGRectMake(8,8,LOCK_SIZE,LOCK_SIZE)] autorelease];
    [key addSubview:self.numLock];

    x += kw+marginx;
    [self createKey:"/" code:SDL_SCANCODE_KP_DIVIDE x:x y:y width:kw height:kh];
    x += kw+marginx;
    [self createKey:"*" code:SDL_SCANCODE_KP_MULTIPLY x:x y:y width:kw height:kh];
    x += kw+marginx;
    [self createKey:"-" code:SDL_SCANCODE_KP_MINUS x:x y:y width:kw height:kh];
    
    // 2nd Row
    // [7] [8] [9] [+]
    //             [ ]
    y = rowY[1];
    x = x0;
    [self createKey:"7" code:SDL_SCANCODE_KP_7 x:x y:y width:kw height:kh];
    x += kw+marginx;
    [self createKey:"8" code:SDL_SCANCODE_KP_8 x:x y:y width:kw height:kh];
    x += kw+marginx;
    [self createKey:"9" code:SDL_SCANCODE_KP_9 x:x y:y width:kw height:kh];
    x += kw+marginx;
    [self createKey:"+" code:SDL_SCANCODE_KP_PLUS x:x y:y width:kw height:2*kh+marginy];
    
    // 3rd Row
    // [4] [5] [6]
    y = rowY[2];
    x = x0;
    [self createKey:"4" code:SDL_SCANCODE_KP_4 x:x y:y width:kw height:kh];
    x += kw+marginx;
    [self createKey:"5" code:SDL_SCANCODE_KP_5 x:x y:y width:kw height:kh];
    x += kw+marginx;
    [self createKey:"6" code:SDL_SCANCODE_KP_6 x:x y:y width:kw height:kh];

    // 4th Row
    // [1] [2] [3] [Enter]
    //             [     ]
    y = rowY[3];
    x = x0;
    [self createKey:"1" code:SDL_SCANCODE_KP_1 x:x y:y width:kw height:kh];
    x += kw+marginx;
    [self createKey:"2" code:SDL_SCANCODE_KP_2 x:x y:y width:kw height:kh];
    x += kw+marginx;
    [self createKey:"3" code:SDL_SCANCODE_KP_3 x:x y:y width:kw height:kh];
    x += kw+marginx;
    [self createKey:"Enter" code:SDL_SCANCODE_KP_ENTER x:x y:y width:kw height:2*kh+marginy];
    
    // 5th Row
    // [   0   ] [.] 
    x=x0;
    y=rowY[4];
    [self createKey:"0" code:SDL_SCANCODE_KP_0 x:x y:y width:kw+kw+marginx height:kh];
    x += 2*kw+marginx*2;
    [self createKey:"." code:SDL_SCANCODE_KP_PERIOD x:x y:y width:kw height:kh];
    
    if (asOverlay) {
        for (int i = 0; i < [self.keys count]; i++) {
            KeyView *btn = [self.keys objectAtIndex:i];
            btn.bkgColor=[UIColor clearColor];
            btn.edgeColor=[UIColor clearColor];
            if (btn.code == SDL_SCANCODE_LEFT ||
                btn.code == SDL_SCANCODE_RIGHT ||
                btn.code == SDL_SCANCODE_UP ||
                btn.code == SDL_SCANCODE_DOWN)
            {
                btn.textColor=[UIColor whiteColor];
            }
            btn.padding=5;
        }
    }
    // On iPad, we will recreate keyboard
    // after rotation. So we need to refresh
    // Lock states.
    [self updateKeyLock];
}


-(void)createIphoneFullKeys
{
    for (int i = 0; i < [self.keys count]; i++) {
        KeyView *btn = [self.keys objectAtIndex:i];
        [btn removeFromSuperview];
    }
    float mainKeysWidth = 400;
    BOOL fullKeys = YES;
    self.keys = [NSArray array];
    float x0 = 4;
    float marginy = 2;
    float kw = 22;
    float kh = 26;
    float marginx = 2;
    float x = x0;
    float y = 6;
    float maxwidth = x0 + kw * 1.5 + 13 * (kw + marginx);
    float rowY[6];
    
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
    
    [self createKey:"CAPSLOCK" code:SDL_SCANCODE_CAPSLOCK x:x y:y width:kw*2 height:kh];
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
        float tmp_kw = (maxwidth - x- 2 * marginx)/3;
        float tmp_marginy = 3;
        float tmp_kh = (kh-tmp_marginy) * 0.5;
        
        [self createKey:"LEFT" code:SDL_SCANCODE_LEFT x:x y:y+tmp_kh+tmp_marginy width:tmp_kw height:tmp_kh];
        x += tmp_kw + marginx;
        [self createKey:"DOWN" code:SDL_SCANCODE_DOWN x:x y:y+tmp_kh+tmp_marginy width:tmp_kw height:tmp_kh];
        [self createKey:" UP " code:SDL_SCANCODE_UP x:x y:y width:tmp_kw height:tmp_kh];
        x += tmp_kw + marginx;
        [self createKey:"RIGHT" code:SDL_SCANCODE_RIGHT x:x y:y+tmp_kh+tmp_marginy width:tmp_kw height:tmp_kh];
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
}

-(void)createIphoneKeys
{
    for (int i = 0; i < [self.keys count]; i++) {
        KeyView *btn = [self.keys objectAtIndex:i];
        [btn removeFromSuperview];
    }
    KeyView *key;
    BOOL fullKeys = FALSE;
    int mainKeysWidth = 460;
    self.keys = [NSArray array];
    float x0 = 4;
    float marginy = 4;
    float kw = 30;
    float kh = 30;
    float marginx = (mainKeysWidth-x0-x0-14.5*kw)/13;
    float x = x0;
    float y = 4;
    float maxwidth = x0 + kw * 1.5 + 13 * (kw + marginx);
    float rowY[6];
    /*
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
     
    */ 
    rowY[1]=y;
    x = x0;
    if (fnSwitch) {
        [self createKey:"ESC" code:SDL_SCANCODE_ESCAPE x:x y:y width:kw height:kh];
        x += kw+marginx;
        for (int i = 0; i < ARRAY_SIZE(combo_f); i++) {
            [self createKey:combo_f[i].title code:combo_f[i].code x:x y:y width:kw height:kh];
            x += kw+marginx;
        }        
    } else {
        for (int i = 0; i < ARRAY_SIZE(combo_1); i++) {
            [self createKey:combo_1[i].title code:combo_1[i].code x:x y:y width:kw height:kh];
            x += kw+marginx;
        }
    }
    [self createKey:"BSPACE" code:SDL_SCANCODE_BACKSPACE x:x y:y width:maxwidth-x height:kh];
    
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
    self.capsLock=[[[KeyLockIndicator alloc] initWithFrame:CGRectMake(5,5,LOCK_SIZE,LOCK_SIZE)] autorelease];
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
    [self createKey:" Fn " code:FN_KEY x:x y:y width:kw height:kh];
    x += kw + marginx;
    [self createKey:"CTRL" code:SDL_SCANCODE_LCTRL x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    [self createKey:"ALT" code:SDL_SCANCODE_LALT x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    
    float spaceWidth;
    if (fullKeys) {
        spaceWidth = (maxwidth-3*kw-2*marginx-x);
    } else {
        spaceWidth = 4*kw;
    }
    
    [self createKey:" " code:SDL_SCANCODE_SPACE x:x y:y width:spaceWidth height:kh];
    x += spaceWidth + marginx;
    [self createKey:"ALT" code:SDL_SCANCODE_RALT x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    [self createKey:"CTRL" code:SDL_SCANCODE_RCTRL x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    
    float tmp_kw = (maxwidth - x- 2 * marginx)/3;
    float tmp_marginy = 3;
    float tmp_kh = (kh-tmp_marginy) * 0.5;
    
    [self createKey:"LEFT" code:SDL_SCANCODE_LEFT x:x y:y+tmp_kh+tmp_marginy width:tmp_kw height:tmp_kh];
    x += tmp_kw + marginx;
    [self createKey:"DOWN" code:SDL_SCANCODE_DOWN x:x y:y+tmp_kh+tmp_marginy width:tmp_kw height:tmp_kh];
    [self createKey:" UP " code:SDL_SCANCODE_UP x:x y:y width:tmp_kw height:tmp_kh];
    x += tmp_kw + marginx;
    [self createKey:"RIGHT" code:SDL_SCANCODE_RIGHT x:x y:y+tmp_kh+tmp_marginy width:tmp_kw height:tmp_kh];    
}

-(void)drawRoundedRectangle
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (color==nil) {
        [[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1] set];
    } else {
        [color set];
    }
    
	// If you were making this as a routine, you would probably accept a rectangle
	// that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
	CGRect rrect = self.bounds;
	CGFloat radius = 10;
	// NOTE: At this point you may want to verify that your radius is no more than half
	// the width and height of your rectangle, as this technique degenerates for those cases.
	
	// In order to draw a rounded rectangle, we will take advantage of the fact that
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc
	// in order to create the path from the current position and the destination position.
	
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
	// Fill & stroke the path
	CGContextDrawPath(context, kCGPathFillStroke);    
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    [self drawRoundedRectangle];

}


- (void)dealloc {
    self.capsLock=nil;
    self.numLock=nil;
    self.color=nil;
    self.keys=nil;
    [super dealloc];
}


@end
