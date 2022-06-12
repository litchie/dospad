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

@class DOSPadEmulator;

@protocol DOSPadEmulatorDelegate

- (void)emulatorWillStart:(DOSPadEmulator*)emulator;
- (void)emulator:(DOSPadEmulator*)emulator saveScreenshot:(NSString*)path;
- (void)emulator:(DOSPadEmulator*)emulator open:(NSString*)path;

@end

@interface DOSPadEmulator : NSObject

@property (strong) NSString *diskcDirectory;
@property (readonly) NSString *dospadConfigFile;
@property (readonly) NSString *gamepadConfigFile;
@property (readonly) NSString *uiConfigFile;
@property (readonly) NSString *mfiConfigFile; // External Gamepad Configuration File
@property (readonly) BOOL started;
@property (strong) id<DOSPadEmulatorDelegate> delegate;

+ (DOSPadEmulator*)sharedInstance;
+ (void)setSharedInstance:(DOSPadEmulator*)instance;

- (void)start;
- (void)takeScreenshot;
- (void)sendText:(NSString *)text;
- (void)sendCommand:(NSString *)cmd;
- (void)updateJoystick:(NSInteger)index x:(float)x y:(float)y;
- (void)joystickButton:(NSInteger)buttonIndex pressed:(BOOL)pressed joystickIndex:(NSInteger)index;
- (void)sendKey:(int)scancode pressed:(BOOL)pressed;
- (void)sendKey:(int)scancode;

@end
