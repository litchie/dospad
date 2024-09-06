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


#import <UIKit/UIKit.h>
#import "MfiGamepadConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@class MfiGamepadMapperView;

@protocol MfiGamepadMapperDelegate
- (void)mfiGamepadMapperDidClose:(MfiGamepadMapperView*)mapper;
@end

@interface MfiGamepadMapperView : UIView
@property (strong) id<MfiGamepadMapperDelegate> delegate;
- (id)initWithFrame:(CGRect)frame configuration:(MfiGamepadConfiguration*)config;
- (void)onKey:(int)code pressed:(BOOL)pressed;
- (void)onButton:(MfiGamepadButtonIndex)buttonIndex pressed:(BOOL)pressed atPlayer:(NSInteger)playerIndex;
- (void)onJoystickMoveWithX:(float)x y:(float)y atPlayer:(NSInteger)playerIndex;
- (void)update;
@end

NS_ASSUME_NONNULL_END
