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
@synthesize externKeyDelegate;
@synthesize backgroundImage;
@synthesize keys;
@synthesize capsLock, numLock;

-(KeyView*)createKey:(const char*)title code:(int)scancode x:(int)x y:(int)y width:(int)w height:(int)h
{
    KeyView *btn = [[[KeyView alloc] initWithFrame:CGRectMake(x, y,w,h)] autorelease];
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
    [self removeKeys];    
    KeyView *key;
    self.keys = [NSArray array];
    
    float x0,y0,marginy,kw,kh,marginx,x,y;
    
    if (ISIPAD())
    {
        x0 = 18;
        y0 = 5;
        marginx = 7.3;
        marginy = 5;
        kw = 42.5;
        kh = 42.5;
    }
    else
    {
        x0 = 6;
        y0 = 3;
        marginx = 3;
        marginy = 3;
        kw = 34;
        kh = 36;
    }
    
    // 1st Row
    //  [Num Lock]  [/]   [*]  [-]
    x = x0;
    y = y0;
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
    y += kh + marginy;
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
    y += kh + marginy;
    x = x0;
    [self createKey:"4" code:SDL_SCANCODE_KP_4 x:x y:y width:kw height:kh];
    x += kw+marginx;
    [self createKey:"5" code:SDL_SCANCODE_KP_5 x:x y:y width:kw height:kh];
    x += kw+marginx;
    [self createKey:"6" code:SDL_SCANCODE_KP_6 x:x y:y width:kw height:kh];
    
    // 4th Row
    // [1] [2] [3] [Enter]
    //             [     ]
    y += kh + marginy;
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
    y += kh + marginy;
    [self createKey:"0" code:SDL_SCANCODE_KP_0 x:x y:y width:kw+kw+marginx height:kh];
    x += 2*kw+marginx*2;
    [self createKey:"." code:SDL_SCANCODE_KP_PERIOD x:x y:y width:kw height:kh];
    
    // On iPad, we will recreate keyboard
    // after rotation. So we need to refresh
    // Lock states.
    [self updateKeyLock];    
}

-(void)createIPadLandscapeKeys
{
    [self removeKeys];
    KeyView *key;
    self.keys = [NSArray array];
    float x0 = 3;
    float y0 = 9;
    float marginx = 2;
    float marginy = 2;
    float kw = 52;
    float kh = 54;
    float maxwidth = x0 + kw * 1.5 + 13 * (kw + marginx);
    float rowY[6];

    float x = x0;
    float y = y0; //FIXME

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
        
    [self createKey:" Fn " code:FN_KEY x:x y:y width:kw height:kh];
    x += kw + marginx;
    
    [self createKey:"CTRL" code:SDL_SCANCODE_LCTRL x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    [self createKey:"ALT" code:SDL_SCANCODE_LALT x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    
    float spaceWidth = 4*kw;
    
    [self createKey:" " code:SDL_SCANCODE_SPACE x:x y:y width:spaceWidth height:kh];
    x += spaceWidth + marginx;
    [self createKey:"ALT" code:SDL_SCANCODE_RALT x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    [self createKey:"CTRL" code:SDL_SCANCODE_RCTRL x:x y:y width:1.5*kw height:kh];
    x += 1.5*kw + marginx;
    
    float tmp_kw = 53;
    float tmp_kh = 21;
    float tmp_marginy = 3;
    x = 606;
    y += 5;
    key = [self createKey:"LEFT" code:SDL_SCANCODE_LEFT x:x y:y+tmp_kh+tmp_marginy width:tmp_kw height:tmp_kh];
    key.padding = UIEdgeInsetsMake(0, 0, 0, 0);
    x += tmp_kw + marginx;

    key = [self createKey:"DOWN" code:SDL_SCANCODE_DOWN x:x y:y+tmp_kh+tmp_marginy width:tmp_kw height:tmp_kh];
    key.padding = UIEdgeInsetsMake(0, 0, 0, 0);
    
    key = [self createKey:" UP " code:SDL_SCANCODE_UP x:x y:y width:tmp_kw height:tmp_kh];
    key.padding = UIEdgeInsetsMake(0, 0, 0, 0);

    x += tmp_kw + marginx;
    key = [self createKey:"RIGHT" code:SDL_SCANCODE_RIGHT x:x y:y+tmp_kh+tmp_marginy width:tmp_kw height:tmp_kh];    
    key.padding = UIEdgeInsetsMake(0, 0, 0, 0);
        

    x0 = 806;
    
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
    
    // On iPad, we will recreate keyboard
    // after rotation. So we need to refresh
    // Lock states.
    [self updateKeyLock];
}

-(void)createIphoneLandscapeKeys
{
    [self removeKeys];
    KeyView *key;
    BOOL fullKeys = FALSE;
    int mainKeysWidth = 480;
    self.keys = [NSArray array];
    float x0 = 4;
    float marginy = 2;
    float kw = 32;
    float kh = 36;
    float marginx = (mainKeysWidth-x0-x0-14.5*kw)/13;
    float x = x0;
    float y = 4;
    float maxwidth = x0 + kw * 1.5 + 13 * (kw + marginx);
    float rowY[6];
 
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
    
    key = [self createKey:"LEFT" code:SDL_SCANCODE_LEFT x:x y:y+tmp_kh+tmp_marginy width:tmp_kw height:tmp_kh];
    key.padding = UIEdgeInsetsMake(0, 0, 7, 0);
    x += tmp_kw + marginx;
    
    key = [self createKey:"DOWN" code:SDL_SCANCODE_DOWN x:x y:y+tmp_kh+tmp_marginy width:tmp_kw height:tmp_kh];
    key.padding = UIEdgeInsetsMake(0, 0, 7, 0);
 
    key = [self createKey:" UP " code:SDL_SCANCODE_UP x:x y:y width:tmp_kw height:tmp_kh];
    key.padding = UIEdgeInsetsZero;

    x += tmp_kw + marginx;
    key = [self createKey:"RIGHT" code:SDL_SCANCODE_RIGHT x:x y:y+tmp_kh+tmp_marginy width:tmp_kw height:tmp_kh];    
    key.padding = UIEdgeInsetsMake(0, 0, 7, 0);
    
    [self updateKeyLock];
}

- (id)initWithType:(KeyboardType)type frame:(CGRect)frame
{
    if (self = [self initWithFrame:frame])
    {
        transparentKeys = YES;
        self.backgroundColor = [UIColor clearColor];
        
        if (ISIPAD())
        {
            switch (type)
            {
                case KeyboardTypeLandscape:  
                {
                    transparentKeys = YES;
                    self.backgroundImage = [UIImage imageNamed:@"landkey~ipad.png"];
                    keyPadding = UIEdgeInsetsMake(3,3,11,9);
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
                    self.backgroundImage = [UIImage imageNamed:@"landnumpad.png"];
                    keyPadding = UIEdgeInsetsMake(0,  /* top */
                                                  3,  /* left */ 
                                                  5,  /* bottom */
                                                  4); /* right */
                    [self createNumPadKeys];
                    break;
                case KeyboardTypeLandscape: 
                    self.backgroundImage = [UIImage imageNamed:@"landkey.png"];
                    keyPadding = UIEdgeInsetsMake(0,  /* top */
                                                  2,  /* left */ 
                                                  9,  /* bottom */
                                                  5); /* right */                    
                    [self createIphoneLandscapeKeys];
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
    
    for (int i = 0; i < [keys count]; i++) 
    {
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
            [self createIphoneLandscapeKeys];
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

- (void)dealloc 
{
    [backgroundImage release];
    [keys release];
    [capsLock release];
    [numLock release];
    [super dealloc];
}


@end
