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

//  For mangaging external mouse devices with GC framework.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class DPMouseManager;

@protocol DPMouseManagerDelegate

- (void)mouseManager:(DPMouseManager*)manager moveX:(CGFloat)x andY:(CGFloat)y;
- (void)mouseManager:(DPMouseManager*)manager button:(int)index  pressed:(BOOL)pressed;

@end

@interface DPMouseManager : NSObject
@property (nonatomic, strong) id<DPMouseManagerDelegate> delegate;
@property (nonatomic) BOOL enabled;
+ (DPMouseManager*)defaultManager;

@end

NS_ASSUME_NONNULL_END
