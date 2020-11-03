
#import "DPGamepad.h"
#import "DPGamepadConfiguration.h"

#define CENTER_OF_RECT(r) CGPointMake(r.size.width/2,r.size.height/2)
#define DISTANCE_BETWEEN(a,b) sqrt((a.x-b.x)*(a.x-b.x) + (a.y-b.y)*(a.y-b.y))
#define CHOP(x) \
if ((x) > 1.0) { \
    (x) = 1.0; \
} else if ((x) < -1.0) { \
    (x) = -1.0; \
} else {}




/** DPadView */
@implementation DPGamepadDPad
@synthesize currentDirection;
@synthesize backgroundImage;
@synthesize images;
@synthesize fourWay;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
		minDistance = MAX(10, frame.size.width/2 * 0.16);
		fourWay = NO;
	}
	return self;
}

- (UIImage*)imageForDirection:(DPGamepadDPadDirection)dir
{
	switch (dir) {
	case DPGamepadDPadDirectionNone      : return [images objectAtIndex:0];
	case DPGamepadDPadDirectionRight     : return [images objectAtIndex:1];
	case DPGamepadDPadDirectionRightUp   : return [images objectAtIndex:2];
	case DPGamepadDPadDirectionUp        : return [images objectAtIndex:3];
	case DPGamepadDPadDirectionLeftUp    : return [images objectAtIndex:4];
	case DPGamepadDPadDirectionLeft      : return [images objectAtIndex:5];
	case DPGamepadDPadDirectionLeftDown  : return [images objectAtIndex:6];
	case DPGamepadDPadDirectionDown      : return [images objectAtIndex:7];
	case DPGamepadDPadDirectionRightDown : return [images objectAtIndex:8];
	default                     : return nil;
	}
}

- (void)drawRect:(CGRect)rect 
{
	UIImage *image;
	if (backgroundImage)
		[backgroundImage drawInRect:rect];
	CGFloat r = rect.size.width/2;
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGFloat iw = rect.size.width * 0.3;
	CGFloat ih = iw * 1.3;
	CGRect iRect = CGRectMake(-iw/2, -ih/2, iw, ih);
	
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, r, r*0.5);
	[self.images[!!(currentDirection & DPGamepadDPadDirectionUp)] drawInRect:iRect];
	CGContextRestoreGState(ctx);

	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, r*1.5, r);
	CGContextRotateCTM(ctx, M_PI/2);
	[self.images[!!(currentDirection & DPGamepadDPadDirectionRight)] drawInRect:iRect];
	CGContextRestoreGState(ctx);

	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, r, r*1.5);
	CGContextRotateCTM(ctx, M_PI);
	[self.images[!!(currentDirection & DPGamepadDPadDirectionDown)] drawInRect:iRect];
	CGContextRestoreGState(ctx);

	CGContextTranslateCTM(ctx, r*.5, r);
	CGContextRotateCTM(ctx, M_PI/2*3);
	[self.images[!!(currentDirection & DPGamepadDPadDirectionLeft)] drawInRect:iRect];
}

- (DPGamepadDPadDirection)directionOfPoint:(CGPoint)pt
{
	static DPGamepadDPadDirection eight_way_map[] = {
		DPGamepadDPadDirectionLeft,  DPGamepadDPadDirectionLeftDown,  DPGamepadDPadDirectionLeftDown,  DPGamepadDPadDirectionDown,
		DPGamepadDPadDirectionDown,  DPGamepadDPadDirectionRightDown, DPGamepadDPadDirectionRightDown, DPGamepadDPadDirectionRight,
		DPGamepadDPadDirectionRight, DPGamepadDPadDirectionRightUp,   DPGamepadDPadDirectionRightUp,   DPGamepadDPadDirectionUp,
		DPGamepadDPadDirectionUp,    DPGamepadDPadDirectionLeftUp,    DPGamepadDPadDirectionLeftUp,    DPGamepadDPadDirectionLeft
	};
	static DPGamepadDPadDirection four_way_map[] = {
		DPGamepadDPadDirectionLeft,  DPGamepadDPadDirectionLeft,  DPGamepadDPadDirectionDown,  DPGamepadDPadDirectionDown,
		DPGamepadDPadDirectionDown,  DPGamepadDPadDirectionDown,  DPGamepadDPadDirectionRight, DPGamepadDPadDirectionRight,
		DPGamepadDPadDirectionRight, DPGamepadDPadDirectionRight, DPGamepadDPadDirectionUp,    DPGamepadDPadDirectionUp,
		DPGamepadDPadDirectionUp,    DPGamepadDPadDirectionUp,    DPGamepadDPadDirectionLeft,  DPGamepadDPadDirectionLeft
	};
    
	CGPoint ptCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
	double angle = atan2(ptCenter.y - pt.y, pt.x - ptCenter.x);
	int index = (unsigned)((angle+M_PI) / (M_PI/8)) % 16;
	return fourWay ? four_way_map[index] : eight_way_map[index];
}

- (void)sendKey:(DPGamepadButtonIndex)index pressed:(BOOL)pressed
{
	[self.gamepad.gamepadDelegate gamepad:self.gamepad buttonIndex:index pressed:pressed];
}

- (void)setCurrentDirection:(DPGamepadDPadDirection)dir
{
	if (dir != currentDirection) {
		int chg = currentDirection ^ dir;
		if (chg & 1) [self sendKey:DP_GAMEPAD_BUTTON_RIGHT pressed:dir & 1];
		if (chg & 2) [self sendKey:DP_GAMEPAD_BUTTON_UP    pressed:dir & 2];
		if (chg & 4) [self sendKey:DP_GAMEPAD_BUTTON_LEFT  pressed:dir & 4];
		if (chg & 8) [self sendKey:DP_GAMEPAD_BUTTON_DOWN  pressed:dir & 8];
		currentDirection = dir;        
		[self setNeedsDisplay];
	}
}

- (void)updateCurrentDirectionFromPoint:(CGPoint)pt
{
	DPGamepadDPadDirection dir = DPGamepadDPadDirectionNone;
	CGPoint ptCenter = CENTER_OF_RECT(self.bounds);
	if (DISTANCE_BETWEEN(pt, ptCenter) > minDistance) 
		dir = [self directionOfPoint:pt];
	if (dir != currentDirection) 
		[self setCurrentDirection:dir];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
	[self updateCurrentDirectionFromPoint:pt];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
	[self updateCurrentDirectionFromPoint:pt];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[self setCurrentDirection:DPGamepadDPadDirectionNone];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	if (fabs(self.bounds.size.width - self.bounds.size.height) < 1) {
		CGPoint ptCenter = CENTER_OF_RECT(self.bounds);
		return DISTANCE_BETWEEN(point, ptCenter) < self.bounds.size.width/2;
	} else {
		float a = self.bounds.size.width / 2;
		float b = self.bounds.size.height / 2;
		CGPoint ptCenter = CGPointMake(a, b);
		double theta = atan2(ptCenter.y - point.y, point.x - ptCenter.x);
		float x = b * cos( theta );
		float y = a * sin( theta );
		float r = (a * b) / sqrt(x*x + y*y);
		return DISTANCE_BETWEEN(point, ptCenter) < r;
	}
}

@end

@implementation DPGamepadJoystick

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	[self.backgroundImage drawInRect:rect];
	CGFloat r = rect.size.width / 2;
	CGFloat rHat = r * 0.7;
	CGFloat x = r + _axisPosition.x*(r-rHat) - rHat;
	CGFloat y = r + _axisPosition.y*(r-rHat) - rHat;
	CGRect frame = CGRectMake(x,y,rHat*2,rHat*2);
	[self.hatImage drawInRect:frame];
}


- (void)updateJoystickAxis:(CGPoint)offset
{
	float r = (self.bounds.size.width / 2) * 0.8;
	double x = offset.x / r;
	double y = offset.y / r;
	CHOP(x);
	CHOP(y);
	_axisPosition.x = x;
	_axisPosition.y = y;
	[self setNeedsDisplay];
	[self.gamepad.gamepadDelegate gamepad:self.gamepad didJoystickMoveWithX:x y:-y];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
	CGPoint ptCenter = CENTER_OF_RECT(self.bounds);

	[self updateJoystickAxis:CGPointMake(pt.x - ptCenter.x, pt.y - ptCenter.y)];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint pt = [touch locationInView:self];
	CGPoint ptCenter = CENTER_OF_RECT(self.bounds);

	[self updateJoystickAxis:CGPointMake(pt.x-ptCenter.x, pt.y-ptCenter.y)];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	[self updateJoystickAxis:CGPointZero];
}

@end


/** GamePadButton */
@implementation DPGamepadButton


- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	if (_style == DPGamePadButtonStyleCircle) {
		CGPoint ptCenter = CENTER_OF_RECT(self.bounds);
		return DISTANCE_BETWEEN(point, ptCenter) < self.bounds.size.width/2;
	} else {
		return [super pointInside:point withEvent:event];
	}
}

- (void)setTitle:(NSString *)s
{
	_title = s;
	[self setNeedsDisplay];
}

- (void)setPressed:(BOOL)b
{
	if (_pressed != b) {
		_pressed = b;
		[self setNeedsDisplay];
		[_gamepad.gamepadDelegate gamepad:_gamepad buttonIndex:self.buttonIndex pressed:b];
	}
}

- (void)setStyle:(DPGamepadButtonStyle)s
{
	_style = s;
	[self setNeedsDisplay];
}

- (void)setTextColor:(UIColor *)textColor
{
	_textColor = textColor;
	[self setNeedsDisplay];
}


- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor clearColor];
		self.textColor       = [UIColor blackColor];
	}
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[self superview] touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[self superview] touchesEnded:touches withEvent:event];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[[self superview] touchesMoved:touches withEvent:event];
}

- (void)drawRect:(CGRect)rect 
{
	int bkgIndex;
	UIColor *color = nil;
    
	if (!_pressed) {
		color = _textColor;
//		color = [textColor colorWithAlphaComponent:0.3];
		bkgIndex = 0;
	} else {
		color = _textColor;
//		color = [textColor colorWithAlphaComponent:0.8];
		bkgIndex = 1;
	}
    
	if ([_images count] > bkgIndex) {
		UIImage *image = [_images objectAtIndex:bkgIndex];
		[image drawInRect:rect];
	}
	
	NSString *text = _title;
	if (_gamepad.stickMode) {
		if (_buttonIndex == DP_GAMEPAD_BUTTON_A) {
			text = @"0";
		} else if (_buttonIndex == DP_GAMEPAD_BUTTON_X) {
			text = @"1";
		}
	}
    
	if (text) {
		float fontSize = rect.size.height * 0.4;
		NSDictionary *attrs = @{
			NSFontAttributeName: [UIFont systemFontOfSize:MIN(14,fontSize)],
			NSForegroundColorAttributeName: color
		};
		CGSize size = [text sizeWithAttributes:attrs];
		CGRect textRect = CGRectMake(
			rect.origin.x + (rect.size.width - size.width)/2,
			rect.origin.y + (rect.size.height - size.height)/2,
			size.width, size.height);
		[text drawInRect:textRect withAttributes:attrs];
	}
}

@end

/** GamePadView is responsible for dispatching key events */
@implementation DPGamepad

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	NSArray *subviews = self.subviews;
	for (int i = 0; i < [subviews count]; i++) {
		UIView *view = [subviews objectAtIndex:i];
		if ([view pointInside:[self convertPoint:point toView:view] 
			withEvent:event]) 
		{
			return YES;
		}
	}
	return NO;
}

#if 1
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	for (UITouch *touch in touches) {
		CGPoint pt = [touch locationInView:self];
		NSInteger i;
		BOOL hit = NO;
		NSInteger n = [_buttons count];

		/* Buttons created later sits on top.
		   So when hit testing, we should go from tail to head.
		   And only one button can be pressed at one time. 
		   If there are two overlapping buttons, then only the top one
		   will be activated. */
		for (i = n-1; i >= 0; i--) {
			DPGamepadButton *k = [_buttons objectAtIndex:i];
			if (k.alpha == 0) continue;
			if (!hit && [k pointInside:
				[self convertPoint:pt toView:k]
				withEvent:event]) 
			{
				hit = YES;
				k.pressed = YES;
				k.prevtouch = touch;
			} else if (k.prevtouch == touch) {
				k.pressed = NO;
				k.prevtouch = nil;
			}
		}


	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	NSInteger i;
	NSInteger n = [_buttons count];
	for (UITouch *touch in touches) {
		for (i = 0; i < n; i++) {
			DPGamepadButton *k = [_buttons objectAtIndex:i];
			if (k.prevtouch == touch) {
				k.pressed = NO;
				k.prevtouch = nil;
			}
		}
	}
}
#endif

- (UIView*)createComponent:(CGRect)frame attributes:(NSDictionary *)attrs
{
	UIView *v = [super createComponent:frame attributes:attrs];
	if (v) return v;
	NSString *type = attrs[@"type"];
	if ([type isEqualToString:@"gamepad-button"]) {
		DPGamepadButton *btn = [[DPGamepadButton alloc] initWithFrame:frame];
		btn.images = @[
			[self.scene getImage:attrs[@"bg"]],
			[self.scene getImage:attrs[@"bg-pressed"]]
		];
		if (attrs[@"shape"] && [attrs[@"shape"] isEqualToString:@"circle"])
		{
			btn.style = DPGamePadButtonStyleCircle;
		}
		else
		{
			btn.style = DPGamePadButtonStyleRoundedRectangle;
		}
		NSString *buttonId = attrs[@"id"];
		btn.buttonIndex = [DPGamepad buttonIndexForId:buttonId];
		btn.title = [[buttonId substringFromIndex:7] uppercaseString];
		btn.textColor = self.scene.theme.gamepadTextColor;
		btn.gamepad = self;
		//btn.pressed = YES;
		v = btn;
		if (!_buttons) _buttons = [NSMutableArray array];
		[_buttons addObject:btn];
	}
	else if ([type isEqualToString:@"gamepad-dpad"])
	{
		DPGamepadDPad *dpad = [[DPGamepadDPad alloc] initWithFrame:frame];
		dpad.gamepad = self;
		dpad.backgroundImage = [self.scene getImage:attrs[@"bg"]];
		dpad.images = @[
			[self.scene getImage:attrs[@"arrow"]],
			[self.scene getImage:attrs[@"arrow-pressed"]],
		];
		_dpad = dpad;
		v = dpad;
	}
	else if ([type isEqualToString:@"gamepad-joystick"])
	{
		_stick = [[DPGamepadJoystick alloc] initWithFrame:frame];
		_stick.gamepad = self;
		_stick.backgroundImage = [self.scene getImage:attrs[@"bg"]];
		_stick.hatImage = [self.scene getImage:attrs[@"hat"]];
		v = _stick;
	}
	return v;
}

- (BOOL)didButtonPress:(DPButton *)btn
{
	if ([btn.name isEqualToString:@"edit-toggle"]) {
		self.editing = !self.editing;
		if (self.editing)
		{
			[btn setImage:[self.scene getImage:@"assets/edit-toggle-on.png"] forState:UIControlStateNormal];
		}
		else
		{
			[btn setImage:[self.scene getImage:@"assets/edit-toggle-off.png"] forState:UIControlStateNormal];
		}
	} else if ([btn.name isEqualToString:@"joystick-toggle"]) {
		self.stickMode = !self.stickMode;
		if (self.stickMode) {
			[btn setImage:[self.scene getImage:@"assets/joystick-toggle-on.png"]
				forState:UIControlStateNormal];
			[btn setImage:[self.scene getImage:@"assets/joystick-toggle-off.png"]
				forState:UIControlStateHighlighted];
		} else {
			[btn setImage:[self.scene getImage:@"assets/joystick-toggle-off.png"]
				forState:UIControlStateNormal];
			[btn setImage:[self.scene getImage:@"assets/joystick-toggle-on.png"]
				forState:UIControlStateHighlighted];
		}
	}
	return NO;
}

- (void)setEditing:(BOOL)editing
{
	_editing = editing;
	if (_editing) {
		for (DPGamepadButton *btn in _buttons) {
			btn.hidden = NO;
			btn.textColor = self.scene.theme.gamepadEditingTextColor;
		}
	} else if (_config) {
		[self applyConfiguration:_config];
		for (DPGamepadButton *btn in _buttons) {
			btn.textColor = self.scene.theme.gamepadTextColor;
		}
	}
}

- (void)applyConfiguration:(DPGamepadConfiguration*)config
{
	_config = config;
	for (DPGamepadButton *btn in _buttons)
	{
		if (!_editing)
			btn.hidden = [config isButtonHidden:btn.buttonIndex];
		btn.title = [config titleForButtonIndex:btn.buttonIndex];
	}
}

- (BOOL)stickMode
{
	return !_stick.hidden;
}

- (void)setStickMode:(BOOL)stickMode
{
	if (stickMode) {
		_stick.hidden = NO;
		_dpad.hidden = YES;
	} else {
		_stick.hidden = YES;
		_dpad.hidden = NO;
	}
	for (DPGamepadButton *btn in _buttons)
		[btn setNeedsDisplay];
}


+ (NSString*)buttonIdForIndex:(DPGamepadButtonIndex)buttonIndex
{
        switch (buttonIndex) {
        case DP_GAMEPAD_BUTTON_A:
                return @"button-a";
        case DP_GAMEPAD_BUTTON_B:
                return @"button-b";
        case DP_GAMEPAD_BUTTON_DOWN:
                return @"button-down";
        case DP_GAMEPAD_BUTTON_L1:
                return @"button-l1";
        case DP_GAMEPAD_BUTTON_L2:
                return @"button-l2";
        case DP_GAMEPAD_BUTTON_LEFT:
                return @"button-left";
        case DP_GAMEPAD_BUTTON_R1:
                return @"button-r1";
        case DP_GAMEPAD_BUTTON_R2:
                return @"button-r2";
        case DP_GAMEPAD_BUTTON_RIGHT:
                return @"button-right";
        case DP_GAMEPAD_BUTTON_UP:
                return @"button-up";
        case DP_GAMEPAD_BUTTON_X:
                return @"button-x";
        case DP_GAMEPAD_BUTTON_Y:
                return @"button-y";
        default:
                return nil;
        }
}

+ (DPGamepadButtonIndex)buttonIndexForId:(NSString*)buttonId
{
        static NSDictionary *_table = nil;
        if (!_table) {
                _table = @{
                        @"button-a": @(DP_GAMEPAD_BUTTON_A),
                        @"button-b": @(DP_GAMEPAD_BUTTON_B),
                        @"button-x": @(DP_GAMEPAD_BUTTON_X),
                        @"button-y": @(DP_GAMEPAD_BUTTON_Y),
                        @"button-left": @(DP_GAMEPAD_BUTTON_LEFT),
                        @"button-right": @(DP_GAMEPAD_BUTTON_RIGHT),
                        @"button-up": @(DP_GAMEPAD_BUTTON_UP),
                        @"button-down": @(DP_GAMEPAD_BUTTON_DOWN),
                        @"button-l1": @(DP_GAMEPAD_BUTTON_L1),
                        @"button-l2": @(DP_GAMEPAD_BUTTON_L2),
                        @"button-r1": @(DP_GAMEPAD_BUTTON_R1),
                        @"button-r2": @(DP_GAMEPAD_BUTTON_R2)
                };
        }
        return [_table[buttonId] intValue];
}

@end
