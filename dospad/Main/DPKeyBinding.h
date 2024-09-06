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
// Manage Key Bindings
//
//

#import <Foundation/Foundation.h>

// Use negative integers to be conflict free with
// SDL scancodes
typedef enum {
	DP_KEY_FN = -1,
	DP_KEY_THUMB = -2,
	DP_KEY_MOUSE_LEFT = -1000,
	DP_KEY_MOUSE_RIGHT,
	DP_KEY_X1,
	DP_KEY_X2

} DPKeyIndex;

NS_ASSUME_NONNULL_BEGIN

@interface DPKeyBinding : NSObject
@property (strong) NSString *text;
@property (nonatomic, strong) NSString *name;
@property DPKeyIndex index;

- (id)initWithText:(NSString*)text;
- (id)initWithKeyIndex:(DPKeyIndex)index;
- (id)initWithAttributes:(NSDictionary*)attrs;
+ (int)keyIndexFromName:(NSString*)name;
+ (NSString*)keyName:(DPKeyIndex)index;

@end

NS_ASSUME_NONNULL_END
