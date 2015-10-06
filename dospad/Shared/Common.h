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

#ifndef COMMON_H
#define COMMON_H

#define NS_BLOCK_ASSERTIONS

#ifdef DEBUG
#define DEBUGLOG  if (1) NSLog
#else
#define DEBUGLOG  if (1) NSLog
#endif

#define THREADED

#define DONATE_URL @"http://www.litchie.net/donate/dospad-donate.html"

#include "keys.h"
#include "cmd_history.h"
#import "ConfigManager.h"

#define kTransparency          @"transparency"
#define kKeySoundEnabled       @"key_sound_enabled"
#define kDoubleTapAsRightClick @"double_tap_as_right_click"
#define kGamePadSoundEnabled   @"gamepad_sound_enabled"
#define kDPadMovable           @"dpad_movable"
#define kNumpadEnabled         @"numpad_enabled"
#define kJoystickEnabled       @"joystick_enabled"
#define KWebServerEnabled      @"httpd_enabled"
#define kWebServerPort         @"httpd_port"

/*
 * NOTE: If you are modifying this string,
 *       you must manually update SDL_uikitview.m!
 */
#define kMouseSpeed            @"mouse_speed"


#define BUILD_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

#define HexColor(h) [UIColor colorWithRed:(((h)>>16)&0xff)/255.0f \
	green:(((h)>>8) &0xff)/255.0f \
	blue:((h)&0xff)/255.0f \
	alpha:1.0f]


#define ISIPAD()  (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define KBD_LANDSCAPE_HEIGHT  (ISIPAD()?352:162)
#define KBD_PORTRAIT_HEIGHT   (ISIPAD()?262:216)

#define ISLANDSCAPE(o) ((o) == UIInterfaceOrientationLandscapeLeft || \
                         (o) == UIInterfaceOrientationLandscapeRight)

#define ISPORTRAIT(o) ((o) == UIInterfaceOrientationPortrait || \
                       (o) == UIInterfaceOrientationPortraitUpsideDown)

#define IS_IOS7 ([[UIDevice currentDevice].systemVersion floatValue]>=7.0)
#define IS_IOS8 ([[UIDevice currentDevice].systemVersion floatValue]>=8.0)


#define DEFS_GET_INT(name)    [[NSUserDefaults standardUserDefaults] integerForKey:(name)]
#define DEFS_GET_BOOL(name)   [[NSUserDefaults standardUserDefaults] boolForKey:(name)]
#define DEFS_GET_STRING(name) [[NSUserDefaults standardUserDefaults] stringForKey:(name)]
#define DEFS_GET_FLOAT(name)  [[NSUserDefaults standardUserDefaults] floatForKey:(name)]

#define MAX_HISTORY_ITEMS 20

void dospad_pause();
void dospad_resume();
extern int SDL_SendKeyboardKey(int index, Uint8 state, SDL_scancode scancode);
extern int dospad_should_launch_game;
extern int dospad_command_line_ready;
extern char dospad_launch_config[256];
extern char dospad_launch_section[256];

#endif

