/*
 *  Copyright (C) 2021-2024 Chaoji Li
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


#import <Foundation/Foundation.h>

@class DPKeyboardManager;

NS_ASSUME_NONNULL_BEGIN

@protocol DPKeyboardManagerDelegate

- (void)keyboardManager:(DPKeyboardManager*)manager scancode:(int)scancode  pressed:(BOOL)pressed;

/**
 * Invoked when COMMAND key is released without pressing any other key when it's down.
 * This is used to release the captured mouse.
 */
- (void)keyboardManagerDidReleaseHostKey:(DPKeyboardManager*)manager;
@end

@interface DPKeyboardManager : NSObject
@property (nonatomic, strong) id<DPKeyboardManagerDelegate> delegate;
+(DPKeyboardManager*)defaultManager;
- (void)willResignActive;

@end

NS_ASSUME_NONNULL_END
