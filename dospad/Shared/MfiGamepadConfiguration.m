//
//  MfiGamepadConfiguration.m
//  iDOS
//
//  Created by Chaoji Li on 2020/10/12.
//

#import "MfiGamepadConfiguration.h"
#import "keys.h"

@interface MfiGamepadConfiguration ()
{
	int _scancode[MFI_GAMEPAD_MAX_PLAYERS][MFI_GAMEPAD_BUTTON_TOTAL];
	int _joystick[MFI_GAMEPAD_MAX_PLAYERS];
	NSString *_path;
	NSArray<NSString*> *_buttonNames;
}
@end

@implementation MfiGamepadConfiguration

- (BOOL)isJoystickAtPlayer:(NSInteger)playerIndex
{
	return _joystick[playerIndex];
}

- (void)setJoystick:(BOOL)value atPlayer:(NSInteger)playerIndex
{
	_joystick[playerIndex] = value;
}

- (int)scancodeForButton:(MfiGamepadButtonIndex)buttonIndex atPlayer:(NSInteger)playerIndex
{
	NSAssert(playerIndex < MFI_GAMEPAD_MAX_PLAYERS && buttonIndex < MFI_GAMEPAD_BUTTON_TOTAL,
		@"Invalid gamepad button");
	return _scancode[playerIndex][buttonIndex];
}

- (void)setScancode:(int)scancode forButton:(MfiGamepadButtonIndex)buttonIndex atPlayer:(NSInteger)playerIndex
{
	NSAssert(playerIndex < MFI_GAMEPAD_MAX_PLAYERS && buttonIndex < MFI_GAMEPAD_BUTTON_TOTAL,
		@"Invalid gamepad button");
	_scancode[playerIndex][buttonIndex] = scancode;
}

- (id)initWithConfig:(NSString *)path
{
	self = [super init];
	_path = path;
	
	// NOTE: must sync with button index
	_buttonNames = @[@"BTN_A",@"BTN_B",@"BTN_X",@"BTN_Y",@"BTN_L1",@"BTN_L2",@"BTN_R1",@"BTN_R2",
		@"DPAD_UP",@"DPAD_DOWN",@"DPAD_LEFT", @"DPAD_RIGHT"];
	
	NSError *err = nil;
	NSData *data = [NSData dataWithContentsOfFile:path];
	NSDictionary *config = [NSJSONSerialization
				  JSONObjectWithData:data
				  options:0
				  error:&err];
				  
	if (config && config[@"players"])
	{
		NSArray *a = config[@"players"];
		for (int i = 0; i < a.count; i++)
		{
			NSDictionary *x = a[i];

			for (int j = 0; j < MFI_GAMEPAD_BUTTON_TOTAL; j++)
			{
				NSString *k = _buttonNames[j];
				if (x[k]) {
					NSString *s = x[k];
					_scancode[i][j] = get_scancode_for_name(s.UTF8String);
				}
			}
				
			if (x[@"joystick"]) {
				_joystick[i] = [x[@"joystick"] boolValue];
			}
		}
	}

	for (int i = 0; i < MFI_GAMEPAD_MAX_PLAYERS; i++)
	{
		if (!_scancode[i][MFI_GAMEPAD_BUTTON_LEFT])
			_scancode[i][MFI_GAMEPAD_BUTTON_LEFT] = get_scancode_for_name("LEFT");
		if (!_scancode[i][MFI_GAMEPAD_BUTTON_RIGHT])
			_scancode[i][MFI_GAMEPAD_BUTTON_RIGHT] = get_scancode_for_name("RIGHT");
		if (!_scancode[i][MFI_GAMEPAD_BUTTON_UP])
			_scancode[i][MFI_GAMEPAD_BUTTON_UP] = get_scancode_for_name("UP");
		if (!_scancode[i][MFI_GAMEPAD_BUTTON_DOWN])
			_scancode[i][MFI_GAMEPAD_BUTTON_DOWN] = get_scancode_for_name("DOWN");
	}
	return self;
}

- (BOOL)save
{
	NSMutableArray *a = [NSMutableArray array];
	for (int i = 0; i < MFI_GAMEPAD_MAX_PLAYERS; i++)
	{
		NSMutableDictionary *x = [NSMutableDictionary dictionary];
		for (int j = 0; j < MFI_GAMEPAD_BUTTON_TOTAL; j++) {
			if (_scancode[i][j] != 0)
			{
				x[_buttonNames[j]] = @(get_key_title(_scancode[i][j]));
			}
		}
		if (_joystick[i]) {
			x[@"joystick"] = @(YES);
		}

		[a addObject:x];
	}
    NSError *err = nil;
    NSData *configData = [NSJSONSerialization dataWithJSONObject:@{
    		@"type": @"iDOS External Gamepad Configuration File",
    		@"players": a
		}
    	options:(NSJSONWritingPrettyPrinted)
    	error:&err];
	return [configData writeToFile:_path atomically:YES];
}

@end
