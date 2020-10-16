//
//  MfiGamepadManager.m
//  iDOS
//
//  Created by Chaoji Li on 2020/10/12.
//

#import "MfiGamepadManager.h"

static MfiGamepadManager *_defaultManager;

@interface MfiGamepadManager ()
{
	
}

@end

@implementation MfiGamepadManager

+ (MfiGamepadManager*)defaultManager
{
	if (!_defaultManager)
	{
		_defaultManager = [[MfiGamepadManager alloc] init];
	}
	return _defaultManager;
}

- (id)init
{
	self = [super init];
	_players = [NSMutableArray array];
	
	int i = 0;
	for (GCController *c in [GCController controllers])
	{
		if (c.microGamepad || c.extendedGamepad)
		{
			c.playerIndex = i;
			[self registerInputHandler:c];
			[_players addObject:c];
		}
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnect:)
                                                 name:GCControllerDidConnectNotification
                                               object:nil];
                                               
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnect:)
                                                 name:GCControllerDidDisconnectNotification
                                               object:nil];
                                               
	return self;
}

- (void)onButton:(MfiGamepadButtonIndex)buttonIndex pressed:(BOOL)pressed atPlayer:(NSInteger)playerIndex
{
	NSLog(@"gamepad button %d pressed=%d playerIndex=%d", (int)buttonIndex, pressed, (int)playerIndex);
	if (_delegate) {
		[_delegate mfiButton:buttonIndex pressed:pressed atPlayer:playerIndex];
	}
}

- (void)onJoystickX:(float)x y:(float)y atPlayer:(NSInteger)playerIndex
{
	NSLog(@"gamepad joystick x=%f y=%f playerIndex=%d", x, y, (int)playerIndex);
	if (_delegate) {
		[_delegate mfiJoystickMoveWithX:x y:y atPlayer:playerIndex];
	}
}

- (void)registerInputHandler:(GCController*)c
{
	if (c.extendedGamepad)
	{
		GCExtendedGamepad *gamepad = c.extendedGamepad;
		[gamepad.buttonA setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_A pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.buttonB setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_B pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.buttonX setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_X pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.buttonY setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_Y pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.leftShoulder setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_L1 pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.leftTrigger setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_L2 pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.rightShoulder setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_R1 pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.rightTrigger setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_R2 pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.dpad.left setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_LEFT pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.dpad.right setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_RIGHT pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.dpad.up setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_UP pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.dpad.down setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_DOWN pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.leftThumbstick setValueChangedHandler:^(GCControllerDirectionPad * _Nonnull dpad,
				float xValue, float yValue)
			{
				[self onJoystickX:xValue y:yValue atPlayer:c.playerIndex];
			}];
	}
	else if (c.microGamepad)
	{
		GCMicroGamepad *gamepad = c.microGamepad;
		[gamepad.buttonA setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_A pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.buttonX setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_X pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.dpad.left setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_LEFT pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.dpad.right setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_RIGHT pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.dpad.up setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_UP pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.dpad.down setPressedChangedHandler:^(GCControllerButtonInput * _Nonnull button,
				float value, BOOL pressed)
			{
				[self onButton:MFI_GAMEPAD_BUTTON_DOWN pressed:pressed atPlayer:c.playerIndex];
			}];
		[gamepad.dpad setValueChangedHandler:^(GCControllerDirectionPad * _Nonnull dpad,
				float xValue, float yValue)
			{
				[self onJoystickX:xValue y:yValue atPlayer:c.playerIndex];
			}];
	}
}

- (void)didConnect:(NSNotification*)note
{
	NSLog(@"mfi didConnect");
	GCController *c = note.object;
	if (_players.count < MFI_GAMEPAD_MAX_PLAYERS && (c.microGamepad || c.extendedGamepad))
	{
		c.playerIndex = _players.count;
		[self registerInputHandler:c];
		[_players addObject:c];
		if (_delegate) {
			[_delegate mfiDidUpdatePlayers];
		}
	}
}

- (void)didDisconnect:(NSNotification*)note
{
	GCController *c = note.object;
	NSLog(@"mfi didDisconnect");
	for (GCController *x in _players)
	{
		if (x != c)
			continue;
		c.playerIndex = GCControllerPlayerIndexUnset;
		[_players removeObject:c];
		for (int i = 0; i < _players.count; i++)
			_players[i].playerIndex = i;
		if (_delegate) {
			[_delegate mfiDidUpdatePlayers];
		}
		break;
	}
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GCControllerDidConnectNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GCControllerDidDisconnectNotification
                                                  object:nil];

}

@end
