/*
 *  Copyright (C) 2010-2024 Chaoji Li
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
#include "KeyView.h"
#include "KeyLockIndicator.h"

typedef enum 
{
    KeyboardTypeLandscape,
    KeyboardTypePortrait,
    KeyboardTypeNumPad
} KeyboardType;

@interface KeyboardView : UIView<KeyDelegate> 
{
    NSArray *keys;
    BOOL fnSwitch;
    id<KeyDelegate> __weak externKeyDelegate;
    KeyLockIndicator *capsLock;
    KeyLockIndicator *numLock;
}

@property (nonatomic, weak) id<KeyDelegate> externKeyDelegate;
@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) KeyLockIndicator *capsLock;
@property (nonatomic, strong) KeyLockIndicator *numLock;

-(id)initWithFrame:(CGRect)frame layout:(NSString*)config;
- (void)updateKeyLock;

@end
