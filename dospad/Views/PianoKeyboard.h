/*
 *  Copyright (C) 2011-2024 Chaoji Li
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

typedef enum {
    PianoKeyButton,
    PianoKeyGrid
} PianoKeyType;

@interface PianoKey : UIView
{
    PianoKeyType type;
    int keyCode;
    int keyCode2;
    BOOL pressed;
    NSString *title;
    UIColor *textColor;
    int index;
}

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, assign) BOOL pressed;
@property (nonatomic, assign) PianoKeyType type;
@property (nonatomic, assign) int keyCode;
@property (nonatomic, assign) int keyCode2;
@property (nonatomic, assign) int index;

@end

#define MAX_PIANO_KEYS  25
#define MAX_PIANO_GRIDS 24

@interface PianoKeyboard : UIView {
    PianoKey *keys[MAX_PIANO_KEYS];
    PianoKey *grids[MAX_PIANO_GRIDS];
}

- (id)initWithConfig:(NSString*)path section:(NSString*)section;

@end
