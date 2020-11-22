//
//  PianoKeyboard.h
//  dospad
//
//  Created by chaojili on 1/10/11.
//  Copyright 2011 Chaoji Li. All rights reserved.
//

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
