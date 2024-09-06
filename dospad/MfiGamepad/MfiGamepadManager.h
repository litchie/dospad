/*
 *  Copyright (C) 2020-2024 Chaoji Li
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

//
// Manage Mfi (Made for iPhone) controller connection and input events.
// We support up to 4 players, each with its own configuration.
//
// - Oct 12, 2020  Chaoji
//   MFi Game Controller support was first implemented by Yoshi Sugawara.
//   Now it's reimplemented to support multiple controllers, to have a
//   intuitive keymapping UI, and to save key mapping in a local configuration file.
//
#import <GameController/GameController.h>
#import "MfiGamepadConfiguration.h"

@class MfiGamepadManager;

@protocol MfiGamepadManagerDelegate

- (void)mfiDidUpdatePlayers;
- (void)mfiButton:(MfiGamepadButtonIndex)buttonIndex pressed:(BOOL)pressed atPlayer:(NSInteger)playerIndex;
- (void)mfiJoystickMoveWithX:(float)x y:(float)y atPlayer:(NSInteger)playerIndex;
@end

NS_ASSUME_NONNULL_BEGIN

@interface MfiGamepadManager : NSObject
@property id<MfiGamepadManagerDelegate> delegate;
@property (nonatomic, strong) NSMutableArray<GCController*> *players;

+ (MfiGamepadManager*)defaultManager;

@end

NS_ASSUME_NONNULL_END
