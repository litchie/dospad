//
//  KeyboardSpy.m
//  iDOS
//
//  Created by Chaoji Li on 2020/10/16.
//
#import "KeyboardSpy.h"
#import "DOSPadEmulator.h"
#include "SDL.h"
#import "SDL_keyboard_c.h"
#import "keyinfotable.h"

#define COMBO(mod,k) [NSString stringWithFormat:@"%@-%@", mod, k]

@interface KeyboardSpy()
<UITextFieldDelegate>
{
	NSMutableArray *_keyCommands;
	NSMutableDictionary *_keyMap;
}
@end

@implementation KeyboardSpy
@synthesize hasText;
@synthesize autocorrectionType;
@synthesize enablesReturnKeyAutomatically;
@synthesize autocapitalizationType;
@synthesize keyboardAppearance;
@synthesize keyboardType;
@synthesize spellCheckingType;
@synthesize smartDashesType;
@synthesize smartQuotesType;
@synthesize smartInsertDeleteType;
@synthesize returnKeyType;
@synthesize secureTextEntry;

- (void)setActive:(BOOL)active
{
	[self becomeFirstResponder];
}

- (BOOL)active
{
	return [self isFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
	return YES;
}

- (UIView*)inputAccessoryView {
	return nil;
}

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	//self.backgroundColor = [UIColor redColor];
	self.hidden = YES;
	
	/* set UITextInputTrait properties, mostly to defaults */
	self.autocapitalizationType = UITextAutocapitalizationTypeNone;
	self.autocorrectionType = UITextAutocorrectionTypeNo;
	self.enablesReturnKeyAutomatically = NO;
	self.keyboardAppearance = UIKeyboardAppearanceDefault;
	self.keyboardType = UIKeyboardTypeASCIICapable;
	self.returnKeyType = UIReturnKeyDefault;
	self.secureTextEntry = NO;
	self.inputAssistantItem.leadingBarButtonGroups = @[];
	self.inputAssistantItem.trailingBarButtonGroups = @[];
	self.spellCheckingType = UITextSpellCheckingTypeNo;
	if (@available(iOS 11.0, *)) {
		self.smartDashesType = UITextSmartDashesTypeNo;
		self.smartQuotesType = UITextSmartQuotesTypeNo;
		self.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
	} else {
		// Fallback on earlier versions
	}
	
	_keyCommands = [NSMutableArray array];
	_keyMap = [NSMutableDictionary dictionaryWithDictionary:@{
		@"F1": @(SDL_SCANCODE_F1),
		@"F2": @(SDL_SCANCODE_F2),
		@"F3": @(SDL_SCANCODE_F3),
		@"F4": @(SDL_SCANCODE_F4),
		@"F5": @(SDL_SCANCODE_F5),
		@"F6": @(SDL_SCANCODE_F6),
		@"F7": @(SDL_SCANCODE_F7),
		@"F8": @(SDL_SCANCODE_F8),
		@"F9": @(SDL_SCANCODE_F9),
		@"F10": @(SDL_SCANCODE_F10),
		@"F11": @(SDL_SCANCODE_F11),
		@"F12": @(SDL_SCANCODE_F12),
		@"ALT": @(SDL_SCANCODE_LALT),
		@"CTRL": @(SDL_SCANCODE_LCTRL),
		@"ESC": @(SDL_SCANCODE_ESCAPE),
	}];
	
	// For text selection in dos programs
	[self registerKeyCommand:COMBO(@"shift", UIKeyInputLeftArrow)];
	[self registerKeyCommand:COMBO(@"shift", UIKeyInputRightArrow)];
	[self registerKeyCommand:COMBO(@"shift", UIKeyInputUpArrow)];
	[self registerKeyCommand:COMBO(@"shift", UIKeyInputDownArrow)];

	// For alt- and ctrl- shortcut keys in dos programs
	for (int i = 'a'; i <= 'z'; i++)
	{
		NSString *x = [NSString stringWithFormat:@"%c",i];
		[self registerKeyCommand:COMBO(@"alt", x) code:SDL_SCANCODE_A + i - 'a'];
		[self registerKeyCommand:COMBO(@"ctrl", x)];
	}
	
	
	[self registerKeyCommand:UIKeyInputEscape code:SDL_SCANCODE_ESCAPE];
	[self registerKeyCommand:UIKeyInputLeftArrow code:SDL_SCANCODE_LEFT];
	[self registerKeyCommand:UIKeyInputRightArrow code:SDL_SCANCODE_RIGHT];
	[self registerKeyCommand:UIKeyInputUpArrow code:SDL_SCANCODE_UP];
	[self registerKeyCommand:UIKeyInputDownArrow code:SDL_SCANCODE_DOWN];
	[self registerKeyCommand:UIKeyInputPageUp code:SDL_SCANCODE_PAGEUP];
	[self registerKeyCommand:UIKeyInputPageDown code:SDL_SCANCODE_PAGEDOWN];
	
	if (@available(iOS 13.4, *)) {
		[self registerKeyCommand:UIKeyInputHome code:SDL_SCANCODE_HOME];
		[self registerKeyCommand:UIKeyInputEnd code:SDL_SCANCODE_END];
		[self registerKeyCommand:UIKeyInputF1 code:SDL_SCANCODE_F1];
		[self registerKeyCommand:UIKeyInputF2 code:SDL_SCANCODE_F2];
		[self registerKeyCommand:UIKeyInputF3 code:SDL_SCANCODE_F3];
		[self registerKeyCommand:UIKeyInputF4 code:SDL_SCANCODE_F4];
		[self registerKeyCommand:UIKeyInputF5 code:SDL_SCANCODE_F5];
		[self registerKeyCommand:UIKeyInputF6 code:SDL_SCANCODE_F6];
		[self registerKeyCommand:UIKeyInputF7 code:SDL_SCANCODE_F7];
		[self registerKeyCommand:UIKeyInputF8 code:SDL_SCANCODE_F8];
		[self registerKeyCommand:UIKeyInputF9 code:SDL_SCANCODE_F9];
		[self registerKeyCommand:UIKeyInputF10 code:SDL_SCANCODE_F10];
		[self registerKeyCommand:UIKeyInputF11 code:SDL_SCANCODE_F11];
		[self registerKeyCommand:UIKeyInputF12 code:SDL_SCANCODE_F12];
	}
	
	// Unfortunately, only F5&F6 works in above code.
	// For example, F1/F2 are used by system to control brightness,
	// and we won't get those key commands.
	// Therefore we provide an alternative way to generate function
	// keys.
	[self registerCommandPrefix:@"`" title:@"ESC"];
	[self registerCommandPrefix:@"1" title:@"F1"];
	[self registerCommandPrefix:@"2" title:@"F2"];
	[self registerCommandPrefix:@"3" title:@"F3"];
	[self registerCommandPrefix:@"4" title:@"F4"];
	[self registerCommandPrefix:@"5" title:@"F5"];
	[self registerCommandPrefix:@"6" title:@"F6"];
	[self registerCommandPrefix:@"7" title:@"F7"];
	[self registerCommandPrefix:@"8" title:@"F8"];
	[self registerCommandPrefix:@"9" title:@"F9"];
	[self registerCommandPrefix:@"0" title:@"F10"];
	[self registerCommandPrefix:@"-" title:@"F11"];
	[self registerCommandPrefix:@"=" title:@"F12"];
	[self registerCommandPrefix:@"c" title:@"CTRL"];
	[self registerCommandPrefix:@"x" title:@"ALT"];
	return self;
}

- (void)registerCommandPrefix:(NSString*)keyInput title:(NSString*)title
{
	UIKeyCommand *cmd = [UIKeyCommand keyCommandWithInput:keyInput modifierFlags:UIKeyModifierCommand action:@selector(onCommandPrefix:) discoverabilityTitle:title];
	[_keyCommands addObject:cmd];
}

- (void)onCommandPrefix:(UIKeyCommand *)keyCommand
{
	NSLog(@"command prefix: %@ %@", keyCommand.input, keyCommand.discoverabilityTitle);
	NSNumber *code = (NSNumber*)_keyMap[keyCommand.discoverabilityTitle];
	if (code) {
		[[DOSPadEmulator sharedInstance] sendKey:code.intValue];
	}
}

// The keyInput is already registered in _keyMap
- (void)registerKeyCommand:(NSString*)keyInput
{
	[self registerKeyCommand:keyInput code:0];
}

- (void)registerKeyCommand:(NSString*)keyInput code:(int)code
{
	NSInteger flags = 0;
	if ([keyInput hasPrefix:@"shift-"]) {
		flags |= UIKeyModifierShift;
	} else if ([keyInput hasPrefix:@"ctrl-"]) {
		flags |= UIKeyModifierControl;
	} else if ([keyInput hasPrefix:@"alt-"]) {
		flags |= UIKeyModifierAlternate;
	}
	NSUInteger i = [keyInput rangeOfString:@"-"].location;
	if (i != NSNotFound) {
		keyInput = [keyInput substringFromIndex:i+1];
	}
	UIKeyCommand *cmd = [UIKeyCommand keyCommandWithInput:keyInput
		modifierFlags:flags action:@selector(onKeyCommand:)];
	[_keyCommands addObject:cmd];
	if (code > 0)
	{
		_keyMap[keyInput] = @(code);
	}
}

- (void)onKeyCommand:(UIKeyCommand *)keyCommand
{
	NSLog(@"onkeycommand: %@ %c%c%c", keyCommand.input,
		(int)keyCommand.modifierFlags & UIKeyModifierShift ? 'S':'-',
		(int)keyCommand.modifierFlags & UIKeyModifierAlternate ? 'A':'-',
		(int)keyCommand.modifierFlags & UIKeyModifierControl ? 'C':'-'
		);
	NSNumber *code = _keyMap[keyCommand.input];
	if (code) {
		if (keyCommand.modifierFlags & UIKeyModifierShift) {
			SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_LSHIFT);
		} else if (keyCommand.modifierFlags & UIKeyModifierAlternate) {
			SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_LALT);
		} else if (keyCommand.modifierFlags & UIKeyModifierControl) {
			SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_LCTRL);
		}
		[[DOSPadEmulator sharedInstance] sendKey:code.intValue];
		if (keyCommand.modifierFlags)
			[NSThread sleepForTimeInterval:1];
		if (keyCommand.modifierFlags & UIKeyModifierShift) {
			SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_LSHIFT);
		} else if (keyCommand.modifierFlags & UIKeyModifierAlternate) {
			SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_LALT);
		} else if (keyCommand.modifierFlags & UIKeyModifierControl) {
			SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_LCTRL);
		}
	}
}

- (UIView*)inputView
{
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    inputView.backgroundColor=[UIColor clearColor];
    inputView.alpha=0;
    return inputView;
}


- (NSArray *)keyCommands {
	return _keyCommands;
}

- (void)sendChar:(unichar)c
{
	Uint16 mod = 0;
	SDL_scancode code;
	
	if (c < 127) {
		/* figure out the SDL_scancode and SDL_keymod for this unichar */
		code = unicharToUIKeyInfoTable[c].code;
		mod  = unicharToUIKeyInfoTable[c].mod;
	}
	else {
		/* we only deal with ASCII right now */
		code = SDL_SCANCODE_UNKNOWN;
		mod = 0;
	}
	
	if (mod & KMOD_SHIFT) {
		/* If character uses shift, press shift down */
		SDL_SendKeyboardKey( 0, SDL_PRESSED, SDL_SCANCODE_LSHIFT);
	}
	/* send a keydown and keyup even for the character */
	[[DOSPadEmulator sharedInstance] sendKey:code];
	if (mod & KMOD_SHIFT) {
		/* If character uses shift, press shift back up */
		SDL_SendKeyboardKey( 0, SDL_RELEASED, SDL_SCANCODE_LSHIFT);
	}
}



- (BOOL)hasText
{
	return YES;
}

- (void)deleteBackward
{
	[[DOSPadEmulator sharedInstance] sendKey:SDL_SCANCODE_BACKSPACE];
}

- (void)insertText:(nonnull NSString *)text {
		int i;
		for (i=0; i<[text length]; i++) {
			
			unichar c = [text characterAtIndex: i];
			[self sendChar:c];
		}
}



@end
