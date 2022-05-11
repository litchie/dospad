//
//  DPGamepadButtonEditController.m
//  iDOS
//
//  Created by Chaoji Li on 2020/11/1.
//

#import "DPGamepadButtonEditor.h"
#import "KeyboardView.h"
#import "DPTheme.h"
#import "DPKeyBinding.h"
#import "UIViewController+Alert.h"

@interface DPGamepadButtonEditor () <KeyDelegate,UITextFieldDelegate>
{
	DPKeyIndex _keyIndex;
	NSString *_textCommand;
}
@property (strong) UIView *container;
@property (strong) UIScrollView *scroller;
@property (strong) UITextField *titleTextField;
@property (strong) UISwitch *visibilitySwitch;
@property (strong) UILabel *bindingLabel;
@property (strong) KeyboardView *keyboard;
@property (strong) UIButton *mouseLeftButton;
@property (strong) UIButton *mouseRightButton;
@property (strong) UIButton *textCommandButton;
@property (strong) UIButton *textButton;
@end



@implementation DPGamepadButtonEditor

- (void)textFieldDidChangeSelection:(UITextField *)textField
{
	self.navigationItem.rightBarButtonItem.enabled = YES;
	if (textField.text.length == 0) {
		textField.layer.borderColor = [UIColor redColor].CGColor;
	} else {
		textField.layer.borderColor = [UIColor blueColor].CGColor;
	}
}

- (void)visibilityChanged
{
	[_gamepadConfig setHidden:!_visibilitySwitch.on forButton:_buttonIndex];
	self.navigationItem.rightBarButtonItem.enabled = YES;
	[self updateVisibility];
}

- (void)updateVisibility
{
	if (!_visibilitySwitch.on) {
		_keyIndex = 0;
		_textCommand = nil;
	}
	_keyboard.hidden = !_visibilitySwitch.on;
	_mouseLeftButton.hidden = !_visibilitySwitch.on;
	_mouseRightButton.hidden = !_visibilitySwitch.on;
	_textCommandButton.hidden = !_visibilitySwitch.on;
	_textButton.hidden = !_visibilitySwitch.on;
	[self updateBindingLabel];
}

- (void)updateBindingLabel
{
	if (_visibilitySwitch.on) {
		if (_textCommand) {
			_bindingLabel.text = [_textCommand stringByReplacingOccurrencesOfString:@"\n" withString:@"⮐"];
		} else if (_keyIndex != 0) {
			_bindingLabel.text = [DPKeyBinding keyName:_keyIndex];
		} else {
			_bindingLabel.text = @"Pick a key";
		}
	} else {
		_bindingLabel.text = @"Button disabled.";
		_titleTextField.text = nil;
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	CGRect r = self.view.bounds;
	self.scroller = [[UIScrollView alloc] initWithFrame:r];
	self.scroller.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	[self.view addSubview:self.scroller];
	self.scroller.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
	
	
	CGFloat x = 0;
	CGFloat y = 0;
	CGFloat margin = 4;
	CGFloat w = r.size.width - self.scroller.contentInset.left
		- self.scroller.contentInset.right;
		
	self.container = [[UIView alloc] initWithFrame:CGRectZero];
	self.container.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
	[self.scroller addSubview:self.container];
	
	CGSize buttonSize = CGSizeMake(60, 60);

	//  ..TT.V...
	//  ..TT.B...
	//  ...MMM...
	//  .........
	//  .........
	_titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, buttonSize.width,buttonSize.height)];
	_titleTextField.placeholder = @"title";
	_titleTextField.text = [_gamepadConfig titleForButtonIndex:_buttonIndex];
	_titleTextField.backgroundColor = [UIColor whiteColor];
	_titleTextField.textColor = [UIColor blackColor];
	_titleTextField.delegate = self;
	_titleTextField.textAlignment = NSTextAlignmentCenter;
	_titleTextField.layer.borderColor = [UIColor blueColor].CGColor;
	_titleTextField.layer.borderWidth = 1;
	_titleTextField.layer.cornerRadius = buttonSize.height/2;
	_titleTextField.center = CGPointMake(
		w/2-buttonSize.width-margin,
		y + 40);
	[self.container addSubview:_titleTextField];

  	_visibilitySwitch = [[UISwitch alloc] initWithFrame:CGRectMake(w/2,
		CGRectGetMidY(_titleTextField.frame) - 30, 60, 30)];
	_visibilitySwitch.on = ![_gamepadConfig isButtonHidden:_buttonIndex];
	if (_buttonIndex == DP_GAMEPAD_BUTTON_LEFT
		|| _buttonIndex == DP_GAMEPAD_BUTTON_RIGHT
		|| _buttonIndex == DP_GAMEPAD_BUTTON_UP
		|| _buttonIndex == DP_GAMEPAD_BUTTON_DOWN)
	{
		_visibilitySwitch.hidden = YES;
	}
	[_visibilitySwitch addTarget:self action:@selector(visibilityChanged)
		forControlEvents:UIControlEventValueChanged];
	
  	[self.container addSubview:_visibilitySwitch];

	_bindingLabel = [[UILabel alloc] initWithFrame:CGRectMake(w/2,
		CGRectGetMidY(_titleTextField.frame), w/2, 30)];
  	[self.container addSubview:_bindingLabel];

	y += 80 + margin;
 	
	self.keyboard = [[KeyboardView alloc] initWithFrame:CGRectMake(x, y, w, 236) layout:@"kbd11x5"];
	[self.container addSubview:self.keyboard];
	self.keyboard.externKeyDelegate = self;
	y += self.keyboard.frame.size.height + margin;
	
	_mouseLeftButton = [self createButton:@"mouse-left" frame:CGRectMake(w/2-130, y, 120, 36)];
	_mouseRightButton = [self createButton:@"mouse-right" frame:CGRectMake(w/2+10, y, 120, 36)];
	y += 40 + margin;
	
	_textCommandButton = [self createButton:@"text-command" frame:CGRectMake(w/2-130, y, 120, 36)];
	_textButton = [self createButton:@"text" frame:CGRectMake(w/2+10, y, 120, 36)];
	y += 40 + margin;

	self.container.frame = CGRectMake(0, 0, w, y);
  	self.scroller.contentSize = CGSizeMake(w, y);
  	
  	DPKeyBinding *keybinding = [_gamepadConfig bindingForButton:_buttonIndex];
	if (keybinding.text)
		_textCommand = keybinding.text;
	else
		_keyIndex = keybinding.index;
  	[self updateVisibility];
	
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.navigationItem.rightBarButtonItem = [self doneButtonItem];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.editing = YES;
    self.navigationItem.leftBarButtonItem = [self cancelButtonItem];
}

- (void)didPressButton:(UIButton*)btn
{
	if (btn == _mouseRightButton) {
		_textCommand = nil;
		_keyIndex = DP_KEY_MOUSE_RIGHT;
		self.navigationItem.rightBarButtonItem.enabled = YES;
		_titleTextField.text = @"Ⓡ";
		[self updateBindingLabel];
	} else if (btn == _mouseLeftButton) {
		_textCommand = nil;
		_keyIndex = DP_KEY_MOUSE_LEFT;
		_titleTextField.text = @"Ⓛ";
		self.navigationItem.rightBarButtonItem.enabled = YES;
		[self updateBindingLabel];
	
	} else if (btn == _textCommandButton) {
		[self alert:@"Type a text command" message:@"auto appending enter" options:@{}
		  prompt:^(NSString *text) {
			if (text) {
				self->_titleTextField.text = text;
				self->_textCommand = [text stringByAppendingString:@"\n"];
				self.navigationItem.rightBarButtonItem.enabled = YES;
				[self updateBindingLabel];
			}
		}];
	} else if (btn == _textButton) {
		[self alert:@"Enter text" message:nil options:@{}
		  prompt:^(NSString *text) {
			if (text) {
				self->_titleTextField.text = text;
				self->_textCommand = text;
				self.navigationItem.rightBarButtonItem.enabled = YES;
				[self updateBindingLabel];
			}
		}];
	}
}

- (UIButton*)createButton:(NSString*)title frame:(CGRect)frame
{
	UIButton *btn = [[UIButton alloc] initWithFrame:frame];
	[btn setBackgroundColor:[UIColor hexColor:@"#333333"]];
	[btn.titleLabel setTextColor:[UIColor lightGrayColor]];
	btn.layer.cornerRadius = frame.size.height/4;
	[btn setTitle:title forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
	[self.container addSubview:btn];
	return btn;
}


- (UIBarButtonItem*)cancelButtonItem
{
	return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
}

- (UIBarButtonItem*)doneButtonItem
{
	return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(save)];
}

- (void)save
{
	DPKeyBinding *keyBinding = nil;
	if (_textCommand) {
		keyBinding = [[DPKeyBinding alloc] initWithText:_textCommand];
	} else {
		keyBinding = [[DPKeyBinding alloc] initWithKeyIndex:_keyIndex];
	}
	[_gamepadConfig setBinding:keyBinding forButton:_buttonIndex];
	
	[_gamepadConfig setHidden:!_visibilitySwitch.on forButton:_buttonIndex];
	[_gamepadConfig setTitle:_titleTextField.text forButton:_buttonIndex];
		
	[_gamepadConfig save];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[self dismissViewControllerAnimated:YES completion:^{
		if (self.completionHandler) {
			self.completionHandler();
		}
	}];
}

- (void)cancel
{
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)onKeyDown:(KeyView *)k {

}

- (void)onKeyUp:(KeyView *)k {
	_textCommand = nil;
	_keyIndex = k.code;
	NSString *s = [DPKeyBinding keyName:k.code];
	_titleTextField.text = [s substringFromIndex:4];
	self.navigationItem.rightBarButtonItem.enabled = YES;
	[self updateBindingLabel];
}

@end
