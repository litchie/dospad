//
//  UIExtendedTextView.m
//  dospad
//
//  Created by Will Powers on 4/27/14.
//  Add additional external keyboard functionality. (ESC, Arrow keys).
//
//

#import "UIExtendedTextField.h"
#import "SDL_keyboard_c.h"

@implementation UIExtendedTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (NSArray *)keyCommands {
    UIKeyCommand *esc = [UIKeyCommand keyCommandWithInput:UIKeyInputEscape modifierFlags:0 action:@selector(esc:)];
    UIKeyCommand *leftArrow = [UIKeyCommand keyCommandWithInput:UIKeyInputLeftArrow modifierFlags:0 action:@selector(leftArrow:)];
    UIKeyCommand *rightArrow = [UIKeyCommand keyCommandWithInput:UIKeyInputRightArrow modifierFlags:0 action:@selector(rightArrow:)];
    UIKeyCommand *upArrow = [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow modifierFlags:0 action:@selector(upArrow:)];
    UIKeyCommand *downArrow = [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow modifierFlags:0 action:@selector(downArrow:)];
    return [[NSArray alloc] initWithObjects:esc, leftArrow, rightArrow, upArrow, downArrow, nil];
}

- (void)esc:(UIKeyCommand *)keyCommand
{
    SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_ESCAPE);
    SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_ESCAPE);
}

- (void)leftArrow:(UIKeyCommand *)keyCommand
{
    SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_LEFT);
    SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_LEFT);
}

- (void)rightArrow:(UIKeyCommand *)keyCommand
{
    SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_RIGHT);
    SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_RIGHT);
}

- (void)upArrow:(UIKeyCommand *)keyCommand
{
    SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_UP);
    SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_UP);
}

- (void)downArrow:(UIKeyCommand *)keyCommand
{
    SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_DOWN);
    SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_DOWN);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
