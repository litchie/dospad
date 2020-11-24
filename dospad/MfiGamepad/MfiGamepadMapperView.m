//
//  MfiGamepadMapperView.m
//  iDOS
//
//  Created by Chaoji Li on 2020/10/13.
//

#import "MfiGamepadMapperView.h"
#import "MfiGamepadManager.h"
#import "keys.h"

@interface MfiGamepadMapperView ()
{
	UILabel *_titleLabel;
	UILabel *_statusLabel;
	UILabel *_dpadLeftLabel;
	UILabel *_dpadRightLabel;
	UILabel *_dpadUpLabel;
	UILabel *_dpadDownLabel;
	UILabel *_buttonL1Label;
	UILabel *_buttonL2Label;
    UILabel *_buttonL3Label;
	UILabel *_buttonR1Label;
	UILabel *_buttonR2Label;
    UILabel *_buttonR3Label;
	UILabel *_buttonALabel;
	UILabel *_buttonBLabel;
	UILabel *_buttonXLabel;
	UILabel *_buttonYLabel;
	UILabel *_selectedLabel;
	UIView *_joystick;
	UIButton *_joystickToggleButton;
	MfiGamepadConfiguration *_config;
	UISegmentedControl *_seg;
	UIColor *_buttonColor;
	UIColor *_highlightButtonColor;
	UIColor *_gamepadButtonColor;
	UIColor *_highlightGamepadButtonColor;
	BOOL _modified;
	UIButton *_btnClose;
}
@end

@implementation MfiGamepadMapperView

- (NSString*)titleForButton:(MfiGamepadButtonIndex)buttonIndex
{
	NSInteger i = _seg.selectedSegmentIndex;
	int code = [_config scancodeForButton:buttonIndex atPlayer:i];
	if (code) {
		if (code == SDL_SCANCODE_SPACE)
			return @"SPACE";
		return @(get_key_title(code));
	} else {
	#if 0
		switch (buttonIndex) {
		case MFI_GAMEPAD_BUTTON_A: return @"A";
		case MFI_GAMEPAD_BUTTON_B: return @"B";
		case MFI_GAMEPAD_BUTTON_X: return @"X";
		case MFI_GAMEPAD_BUTTON_Y: return @"Y";
		case MFI_GAMEPAD_BUTTON_L1: return @"L1";
		case MFI_GAMEPAD_BUTTON_L2: return @"L2";
		case MFI_GAMEPAD_BUTTON_R1: return @"R1";
		case MFI_GAMEPAD_BUTTON_R2: return @"R2";
		default:
			return @"";
		}
	#endif
		return @"";
	}
}

- (void)updateLabels
{
	NSInteger i = _seg.selectedSegmentIndex;
	NSInteger numPlayers = [MfiGamepadManager defaultManager].players.count;
	if (i < numPlayers)
	{
		_titleLabel.text = [MfiGamepadManager defaultManager].players[i].vendorName;
	}
	else
	{
		_titleLabel.text = @"N/A";
	}
	
	_buttonXLabel.text   = [self titleForButton:MFI_GAMEPAD_BUTTON_X];
	_buttonYLabel.text   = [self titleForButton:MFI_GAMEPAD_BUTTON_Y];
	_buttonALabel.text   = [self titleForButton:MFI_GAMEPAD_BUTTON_A];
	_buttonBLabel.text   = [self titleForButton:MFI_GAMEPAD_BUTTON_B];
	_buttonL1Label.text  = [self titleForButton:MFI_GAMEPAD_BUTTON_L1];
	_buttonL2Label.text  = [self titleForButton:MFI_GAMEPAD_BUTTON_L2];
    _buttonL3Label.text  = [self titleForButton:MFI_GAMEPAD_BUTTON_L3];
	_buttonR1Label.text  = [self titleForButton:MFI_GAMEPAD_BUTTON_R1];
	_buttonR2Label.text  = [self titleForButton:MFI_GAMEPAD_BUTTON_R2];
    _buttonR3Label.text  = [self titleForButton:MFI_GAMEPAD_BUTTON_R3];
	_dpadLeftLabel.text  = [self titleForButton:MFI_GAMEPAD_BUTTON_LEFT];
	_dpadRightLabel.text = [self titleForButton:MFI_GAMEPAD_BUTTON_RIGHT];
	_dpadUpLabel.text    = [self titleForButton:MFI_GAMEPAD_BUTTON_UP];
	_dpadDownLabel.text  = [self titleForButton:MFI_GAMEPAD_BUTTON_DOWN];
	
	if ([_config isJoystickAtPlayer:i])
	{
		_buttonALabel.text = @"0";
		_buttonXLabel.text = @"1";
		[_joystickToggleButton setTitle:@"Joystick ON" forState:UIControlStateNormal];
	}
	else
	{
		[_joystickToggleButton setTitle:@"Joystick OFF" forState:UIControlStateNormal];
	}
	
}

- (void)onSwitchPlayer
{
	[self updateLabels];
}

- (id)initWithFrame:(CGRect)frame configuration:(MfiGamepadConfiguration*)config
{
	self = [super initWithFrame:frame];
	self.backgroundColor = [UIColor colorWithWhite:0.4 alpha:1];
	self.layer.cornerRadius = 8;
	self.layer.masksToBounds = YES;
	_config = config;
	
	CGFloat w = frame.size.width;
	CGFloat h = frame.size.height;
	
	_buttonColor = [UIColor colorWithWhite:0.7 alpha:1];
	_gamepadButtonColor = [UIColor colorWithWhite:0.3 alpha:1];
	_highlightGamepadButtonColor = [UIColor colorWithWhite:0.5 alpha:1];
	UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, 40)];
	header.backgroundColor = [UIColor darkGrayColor];
	[self addSubview:header];
	
	_btnClose = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 30)];
	[_btnClose setBackgroundColor:_buttonColor];
	[_btnClose setTitle:@"Done" forState:UIControlStateNormal];
	[_btnClose setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	_btnClose.center = CGPointMake(40, header.bounds.size.height/2);
	_btnClose.layer.cornerRadius = 8;
	[_btnClose addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
	[header addSubview:_btnClose];
	
	_seg = [[UISegmentedControl alloc] initWithItems:@[@" 1 ",@" 2 ",@" 3 ",@" 4 "]];
	_seg.center = CGPointMake(0.5*w, header.bounds.size.height/2);
	_seg.selectedSegmentIndex = 0;
	if (@available(iOS 13.0, *)) {
		_seg.selectedSegmentTintColor = self.backgroundColor;
	}
	[_seg addTarget:self action:@selector(onSwitchPlayer) forControlEvents:UIControlEventValueChanged];
	[header addSubview:_seg];
	
	// Footer
	_statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, h-20, w, 20)];
	_statusLabel.textColor = [UIColor blackColor];
	_statusLabel.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1];
	_statusLabel.text = @"Press button on bluetooth gamepad first";
	_statusLabel.textAlignment = NSTextAlignmentCenter;
	[self addSubview:_statusLabel];

	h -= header.frame.size.height + _statusLabel.frame.size.height;
	UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, header.frame.size.height, w, h)];
	//mainView.backgroundColor = [UIColor lightGrayColor];
	[self addSubview:mainView];
	
	// 10x4 grid
	// u is like 'rem' in web design
	CGFloat gw = w/10;
	CGFloat gh = h/4;
	CGFloat u = MIN(gw,gh) * 0.9;
	CGFloat x = 0, y = 0;
	
	_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(3*gw, 0, 4*gw, gh*2)];
	_titleLabel.center = CGPointMake(w/2, 50);
	_titleLabel.textAlignment = NSTextAlignmentCenter;
	_titleLabel.font = [UIFont systemFontOfSize:u*0.4];
	_titleLabel.numberOfLines = 2;
	[mainView addSubview:_titleLabel];

	CGRect rect1 = CGRectMake(0, 0, u*1.2, u*.6);
	CGRect rect2 = CGRectMake(0, 0, u, u);
	
	x = 8.5*gw;
	y = 2.5*gh;
	_buttonALabel = [[UILabel alloc] initWithFrame:rect2];
	_buttonYLabel = [[UILabel alloc] initWithFrame:rect2];
	_buttonBLabel = [[UILabel alloc] initWithFrame:rect2];
	_buttonXLabel = [[UILabel alloc] initWithFrame:rect2];
    _buttonR3Label = [[UILabel alloc] initWithFrame:rect2];
	_buttonALabel.center = CGPointMake(x, y+u);
	_buttonBLabel.center = CGPointMake(x+u, y);
	_buttonXLabel.center = CGPointMake(x-u, y);
	_buttonYLabel.center = CGPointMake(x, y-u);
    _buttonR3Label.center = CGPointMake(x-(u*2.0), y+u);
	
	x = 1.5*gw;
	y = 2.5*gh;
	_dpadDownLabel  = [[UILabel alloc] initWithFrame:rect1];
	_dpadUpLabel    = [[UILabel alloc] initWithFrame:rect1];
	_dpadLeftLabel  = [[UILabel alloc] initWithFrame:rect1];
	_dpadRightLabel = [[UILabel alloc] initWithFrame:rect1];
    _buttonL3Label  = [[UILabel alloc] initWithFrame:rect2];
	
	_dpadDownLabel.center  = CGPointMake(x, y+u);
	_dpadRightLabel.center = CGPointMake(x+u, y);
	_dpadLeftLabel.center  = CGPointMake(x-u, y);
	_dpadUpLabel.center    = CGPointMake(x, y-u);
	_dpadDownLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
	_dpadUpLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
    _buttonL3Label.center  = CGPointMake(x+(u*2.0), y+u);
	
	x = 1.5*gw;
	y = 0.5*gh;
	_buttonL1Label = [[UILabel alloc] initWithFrame:rect1];
	_buttonL2Label = [[UILabel alloc] initWithFrame:rect1];
	_buttonL1Label.center = CGPointMake(x+u, y);
	_buttonL2Label.center = CGPointMake(x-u, y);
	
	
	x = 8.5*gw;
	_buttonR1Label = [[UILabel alloc] initWithFrame:rect1];
	_buttonR2Label = [[UILabel alloc] initWithFrame:rect1];
	_buttonR1Label.center = CGPointMake(x-u, y);
	_buttonR2Label.center = CGPointMake(x+u, y);
	
	
	for (UILabel *x in @[_buttonXLabel,_buttonBLabel,_buttonYLabel,_buttonALabel,
		_buttonL1Label,_buttonL2Label, _buttonL3Label, _buttonR1Label,_buttonR2Label,
		_buttonR3Label, _dpadUpLabel,_dpadDownLabel,_dpadLeftLabel,_dpadRightLabel])
	{
		x.textAlignment = NSTextAlignmentCenter;
		x.textColor = [UIColor whiteColor];
		x.backgroundColor = _gamepadButtonColor;
		x.font = [UIFont systemFontOfSize:u*0.3];
		x.layer.cornerRadius = 4;
		x.layer.masksToBounds = YES;
		[mainView addSubview:x];
	}

	for (UILabel *x in @[_buttonXLabel,_buttonBLabel,_buttonYLabel,_buttonALabel, _buttonR3Label, _buttonL3Label]) {
		x.layer.cornerRadius = x.bounds.size.width/2;
	}



	// Joystick
	
	_joystickToggleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 2*u,u/2)];
	[_joystickToggleButton addTarget:self action:@selector(toggleJoystick) forControlEvents:UIControlEventTouchUpInside];
	_joystickToggleButton.center = CGPointMake(5*gw,1.5*gh);
	_joystickToggleButton.layer.cornerRadius = 8;
	_joystickToggleButton.backgroundColor = _buttonColor;
	_joystickToggleButton.titleLabel.font = [UIFont systemFontOfSize:u*0.3];
	[_joystickToggleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[mainView addSubview:_joystickToggleButton];
	
	UIView *joystickContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2*u, 2*u)];
	joystickContainer.center = CGPointMake(5*gw, 3*gh);
	joystickContainer.backgroundColor = _gamepadButtonColor;
	joystickContainer.layer.cornerRadius = joystickContainer.bounds.size.width/2;
	_joystick = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1.5*u, 1.5*u)];
	_joystick.backgroundColor = _highlightGamepadButtonColor;
	_joystick.center = CGPointMake(joystickContainer.bounds.size.width/2,
		joystickContainer.bounds.size.height/2);
	_joystick.layer.cornerRadius = _joystick.bounds.size.width/2;
	[joystickContainer addSubview:_joystick];
	[mainView addSubview:joystickContainer];

	[self updateLabels];

	return self;
}

- (void)configUpdated
{
	[self updateLabels];
	if (!_modified) {
		_modified = YES;
		[_btnClose setTitle:@"Save" forState:UIControlStateNormal];
	}
}

- (void)toggleJoystick
{
	NSInteger i = _seg.selectedSegmentIndex;
	BOOL x = [_config isJoystickAtPlayer:i];
	[_config setJoystick:!x atPlayer:i];
	[self configUpdated];
}

- (void)onKey:(int)code pressed:(BOOL)pressed
{
	if (_selectedLabel && pressed) {
		NSInteger i = _seg.selectedSegmentIndex;
		if ([_config isJoystickAtPlayer:i] && (
			_selectedLabel.tag == MFI_GAMEPAD_BUTTON_A ||
			_selectedLabel.tag == MFI_GAMEPAD_BUTTON_X))
		{
			_statusLabel.text = @"Button reserved in joystick mode";
			return;
		}
		[_config setScancode:code forButton:_selectedLabel.tag atPlayer:i];
		[self configUpdated];
	}
}

- (void)onButton:(MfiGamepadButtonIndex)buttonIndex pressed:(BOOL)pressed atPlayer:(NSInteger)playerIndex
{
	NSInteger i = _seg.selectedSegmentIndex;
	if (i != playerIndex) {
		_seg.selectedSegmentIndex = playerIndex;
		[self updateLabels];
	}
	[_selectedLabel setBackgroundColor:_gamepadButtonColor];
	_selectedLabel = nil;
	if (!pressed) {
		_statusLabel.text = nil;
		return;
	}
	_statusLabel.text = @"Press a key for the button";
	switch (buttonIndex) {
	case MFI_GAMEPAD_BUTTON_A:
		_selectedLabel = _buttonALabel;
		break;
	case MFI_GAMEPAD_BUTTON_B:
		_selectedLabel = _buttonBLabel;
		break;
	case MFI_GAMEPAD_BUTTON_X:
		_selectedLabel = _buttonXLabel;
		break;
	case MFI_GAMEPAD_BUTTON_Y:
		_selectedLabel = _buttonYLabel;
		break;
	case MFI_GAMEPAD_BUTTON_L1:
		_selectedLabel = _buttonL1Label;
		break;
	case MFI_GAMEPAD_BUTTON_L2:
		_selectedLabel = _buttonL2Label;
		break;
	case MFI_GAMEPAD_BUTTON_R1:
		_selectedLabel = _buttonR1Label;
		break;
	case MFI_GAMEPAD_BUTTON_R2:
		_selectedLabel = _buttonR2Label;
		break;
	case MFI_GAMEPAD_BUTTON_UP:
		_selectedLabel = _dpadUpLabel;
		break;
	case MFI_GAMEPAD_BUTTON_DOWN:
		_selectedLabel = _dpadDownLabel;
		break;
	case MFI_GAMEPAD_BUTTON_LEFT:
		_selectedLabel = _dpadLeftLabel;
		break;
	case MFI_GAMEPAD_BUTTON_RIGHT:
		_selectedLabel = _dpadRightLabel;
		break;
    case MFI_GAMEPAD_BUTTON_L3:
        _selectedLabel = _buttonL3Label;
        break;
    case MFI_GAMEPAD_BUTTON_R3:
        _selectedLabel = _buttonR3Label;
        break;
	default:
		_selectedLabel = nil;
		break;
	}
	_selectedLabel.tag = buttonIndex;
	[_selectedLabel setBackgroundColor:_highlightGamepadButtonColor];
}

- (void)update
{
	[self updateLabels];
}

- (void)onClose
{
	if (_modified) {
		[_config save];
	}
	[self removeFromSuperview];
	if (_delegate) {
		[_delegate mfiGamepadMapperDidClose:self];
	}
}

- (void)onJoystickMoveWithX:(float)x y:(float)y atPlayer:(NSInteger)playerIndex
{
	NSInteger i = _seg.selectedSegmentIndex;
	if (i != playerIndex) {
		_seg.selectedSegmentIndex = playerIndex;
		[self updateLabels];
	}
	_joystick.transform = CGAffineTransformMakeTranslation(x*_joystick.bounds.size.width/2,
		-y*_joystick.bounds.size.height/2);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
