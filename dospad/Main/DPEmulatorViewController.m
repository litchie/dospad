/*
 *  Copyright (C) 2010  Chaoji Li
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

#import "DPEmulatorViewController.h"
#import "Common.h"
#import "AppDelegate.h"
#import "ColorTheme.h"
#import "DPTheme.h"
#import "DPGamepad.h"
#import "DPGamepadButtonEditor.h"
#import "DPThumbView.h"
#import "UIViewController+Alert.h"
#import "MfiGamepadManager.h"
#import "MfiGamepadMapperView.h"

typedef NS_ENUM(NSInteger, DPFloatingInputType) {
	TAG_INPUT_MIN = 1000,
	TAG_INPUT_KEYBOARD,
	TAG_INPUT_MOUSE_BUTTONS,
	TAG_INPUT_GAMEPAD,
	TAG_INPUT_JOYSTICK,
	TAG_INPUT_NUMPAD,
	TAG_INPUT_PIANO_KEYBOARD,
	TAG_INPUT_MAX
};

static struct {
	int type;
	const char *onImageName;
	const char *offImageName;
} toggleButtonInfo [] = {
	{TAG_INPUT_KEYBOARD,       "modekeyon.png",          "modekeyoff.png"    },
	{TAG_INPUT_MOUSE_BUTTONS,  "mouseon.png",            "mouseoff.png"      },
	{TAG_INPUT_GAMEPAD,        "modegamepadpressed.png", "modegamepad.png"   },
	{TAG_INPUT_JOYSTICK,       "modejoypressed.png",     "modejoy.png"       },
	{TAG_INPUT_NUMPAD,         "modenumpadpressed.png",  "modenumpad.png"    },
	{TAG_INPUT_PIANO_KEYBOARD, "modepianopressed.png",   "modepiano.png"     },
};
#define NUM_BUTTON_INFO (sizeof(toggleButtonInfo)/sizeof(toggleButtonInfo[0]))

@interface DPEmulatorViewController ()
<
	SDL_uikitopenglview_delegate,
	MouseHoldDelegate,
	KeyDelegate,
	UIAlertViewDelegate,
	DOSPadEmulatorDelegate,
	UIDocumentPickerDelegate,
	DPGamepadDelegate,
	MfiGamepadManagerDelegate,
	MfiGamepadMapperDelegate
>
{
	MfiGamepadConfiguration *_mfiConfig;
	MfiGamepadManager *_mfiManager;
	MfiGamepadMapperView *_mfiMapper;

	// Only used in portrait mode
	UIView *_rootContainer;
	DPTheme *_currentTheme;
	DPThemeScene *_currentScene;
	
    UILabel *labCycles;
    UILabel *labCycles2;
    FrameskipIndicator *fsIndicator;
    FrameskipIndicator *fsIndicator2;
	
    FloatPanel *fullscreenPanel;
    
    BOOL shouldShrinkScreen;
    CGRect _screenRect; // portraint only?
    
    HoldIndicator *holdIndicator;
    KeyboardView *kbd;
    KeyboardView *numpad;
    PianoKeyboard *piano;
}

@property (strong) DPGamepadConfiguration *gamepadConfig;
@end

@implementation DPEmulatorViewController

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UILabel*)cyclesLabel:(CGRect)frame
{
	if (labCycles) {
		labCycles.frame = frame;
		return labCycles;
	}
    labCycles = [[UILabel alloc] initWithFrame:frame];
    labCycles.backgroundColor = [UIColor clearColor];
    labCycles.textColor=[UIColor colorWithRed:74/255.0 green:1 blue:55/255.0 alpha:1];
    labCycles.font=[UIFont fontWithName:@"DBLCDTempBlack" size:frame.size.height*.6];
    labCycles.text=[self currentCycles];
    labCycles.textAlignment = NSTextAlignmentCenter;
    //labCycles.baselineAdjustment=UIBaselineAdjustmentAlignCenters;
    return labCycles;
}

- (UIView*)findInputView:(NSInteger)tag
{
	for (UIView *v in _rootContainer.subviews)
	{
		if (v.tag == tag)
			return v;
	}
	return nil;
}

- (void)toggleInput:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    
    if ([self removeFloatingInput:btn.tag] == NO) {
		[self createFloatingInput:btn.tag];
	}
}

// Return YES if floating input of type exists
- (BOOL)removeFloatingInput:(DPFloatingInputType)type
{
    UIView *v = [self findInputView:type];
    if (v) {
    	[v removeFromSuperview];
	    [self refreshFullscreenPanel];
    	return YES;
	}
	return NO;
}

- (void)createFloatingInput:(DPFloatingInputType)type
{
	for (UIView *v in _rootContainer.subviews)
	{
		if (v.tag > TAG_INPUT_MIN && v.tag < TAG_INPUT_MAX)
			[v removeFromSuperview];
	}
	
	switch (type) {
	case TAG_INPUT_NUMPAD:
		[self createNumpad];
		break;
	case TAG_INPUT_KEYBOARD:
		[self createPCKeyboard];
		break;
	case TAG_INPUT_PIANO_KEYBOARD:
		[self createPianoKeyboard];
		break;
	case TAG_INPUT_GAMEPAD:
		[self createGamepad];
		break;
	case TAG_INPUT_JOYSTICK:
		[self createJoystick];
		break;
	case TAG_INPUT_MOUSE_BUTTONS:
		[self createMouseButtons];
		break;
	default:
		break;
	}

    [self refreshFullscreenPanel];
}


- (BOOL)allowsInput:(DPFloatingInputType)type
{
	switch (type) {
		case TAG_INPUT_JOYSTICK:
			return DEFS_GET_BOOL(kJoystickEnabled);
		case TAG_INPUT_NUMPAD:
			return DEFS_GET_BOOL(kNumpadEnabled);
		case TAG_INPUT_PIANO_KEYBOARD:
			return NO;
		default:
			return YES;
	}
}

- (void)refreshFullscreenPanel
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:16];
    
    UIImageView *cpuWindow = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,48,24)];
    cpuWindow.image = [UIImage imageNamed:@"cpuwindow.png"];
    
    if (labCycles2 == nil)
    {
        labCycles2 = [[UILabel alloc] initWithFrame:CGRectMake(1,8,43,12)];
        labCycles2.backgroundColor = [UIColor clearColor];
        labCycles2.textColor=[UIColor colorWithRed:74/255.0 green:1 blue:55/255.0 alpha:1];
        labCycles2.font=[UIFont fontWithName:@"DBLCDTempBlack" size:12];
        labCycles2.text=[self currentCycles];
        labCycles2.textAlignment= NSTextAlignmentCenter;
        labCycles2.baselineAdjustment=UIBaselineAdjustmentAlignCenters;
        fsIndicator2 = [FrameskipIndicator alloc];
        fsIndicator2 = [fsIndicator2 initWithFrame:CGRectMake(labCycles2.frame.size.width-8,2,4,labCycles2.frame.size.height-4)
                                             style:FrameskipIndicatorStyleVertical];
        fsIndicator2.count = [self currentFrameskip];
        [labCycles2 addSubview:fsIndicator2];
    }
    [cpuWindow addSubview:labCycles2];
    [items addObject:cpuWindow];

    for (int i = 0; i < NUM_BUTTON_INFO; i++) {
		if ([self allowsInput:toggleButtonInfo[i].type]) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0,0,48,24)];
            NSString *on = [NSString stringWithUTF8String:toggleButtonInfo[i].onImageName];
            NSString *off = [NSString stringWithUTF8String:toggleButtonInfo[i].offImageName];
            BOOL active = [self findInputView:toggleButtonInfo[i].type] != nil;
            [btn setImage:[UIImage imageNamed:active?on:off] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:on] forState:UIControlStateHighlighted];
            [btn setTag:toggleButtonInfo[i].type];
            [btn addTarget:self action:@selector(toggleInput:) forControlEvents:UIControlEventTouchUpInside];
            [items addObject:btn];
        }
    }
        
    UIButton *btnOption = [[UIButton alloc] initWithFrame:CGRectMake(380,0,48,24)];
    [btnOption setImage:[UIImage imageNamed:@"options.png"] forState:UIControlStateNormal];
    [btnOption addTarget:self action:@selector(showOption:) forControlEvents:UIControlEventTouchUpInside];
    [items addObject:btnOption];
    
    UIButton *btnRemap = [[UIButton alloc] initWithFrame:CGRectMake(340,0,20,24)];
    [btnRemap setImage:[UIImage imageNamed:@"ic_bluetooth_white_18pt"] forState:UIControlStateNormal];
    [btnRemap addTarget:self action:@selector(openMfiMapper:) forControlEvents:UIControlEventTouchUpInside];
    [items addObject:btnRemap];
    
    [fullscreenPanel setItems:items];
}

-(void)updateFrameskip:(NSNumber*)skip
{
    fsIndicator.count=[skip intValue];
    fsIndicator2.count=[skip intValue];
    if (_currentScene && !_currentScene.isPortrait)
    {
        [fullscreenPanel showContent];
    }
}

-(void)updateCpuCycles:(NSString*)title
{
    labCycles.text=title;
    labCycles2.text=title;
    if (_currentScene && !_currentScene.isPortrait)
    {
        [fullscreenPanel showContent];    
    }
}


-(void)updateAlpha
{
    float a = [DPSettings shared].floatAlpha;
    for (UIView *v in _rootContainer.subviews)
    {
    	if (v.tag > TAG_INPUT_MIN && v.tag < TAG_INPUT_MAX)
    	{
    		v.alpha = a;
		}
	}
}

- (void)createMouseButtons
{
    CGFloat vw = _rootContainer.bounds.size.width;
    CGFloat vh = _rootContainer.bounds.size.height;
	UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, vh-40, 200, 40)];
    // Transparency
    container.tag = TAG_INPUT_MOUSE_BUTTONS;
    container.alpha = [DPSettings shared].floatAlpha;
	[_rootContainer addSubview:container];
	
	// Add movable control
	DPThumbView *thumbView = [[DPThumbView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
	thumbView.text = @"☰";
	[container addSubview:thumbView];
	
    // Left Mouse Button
    UIButton *btnMouseLeft = [[UIButton alloc] initWithFrame:CGRectMake(40,0,80,40)];
	[btnMouseLeft setImage:[_currentScene getImage:@"assets/mouse-button-left.png"] forState:UIControlStateNormal];
	[btnMouseLeft setImage:[_currentScene getImage:@"assets/mouse-button-left-pressed.png"] forState:UIControlStateHighlighted];
    [btnMouseLeft addTarget:self
                    action:@selector(onMouseLeftDown)
          forControlEvents:UIControlEventTouchDown];
    [btnMouseLeft addTarget:self
                    action:@selector(onMouseLeftUp)
          forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:btnMouseLeft];
    
    // Right Mouse Button
    UIButton *btnMouseRight = [[UIButton alloc] initWithFrame:CGRectMake(120,0,80,40)];
	[btnMouseRight setImage:[_currentScene getImage:@"assets/mouse-button-right.png"] forState:UIControlStateNormal];
	[btnMouseRight setImage:[_currentScene getImage:@"assets/mouse-button-right-pressed.png"]
		forState:UIControlStateHighlighted];
	[btnMouseRight addTarget:self
                     action:@selector(onMouseRightDown)
           forControlEvents:UIControlEventTouchDown];
    [btnMouseRight addTarget:self
                    action:@selector(onMouseRightUp)
          forControlEvents:UIControlEventTouchUpInside];
	[container addSubview:btnMouseRight];
}


- (void)createNumpad
{
	KeyboardView *numpad = [[KeyboardView alloc] initWithFrame:CGRectMake(_rootContainer.bounds.size.width-160,120,160,200)
	layout:@"kpad4x5"];
	numpad.alpha = [DPSettings shared].floatAlpha;
	numpad.tag = TAG_INPUT_NUMPAD;
	[_rootContainer addSubview:numpad];
	
	CGPoint ptOld = numpad.center;
	numpad.center = CGPointMake(ptOld.x, ptOld.y+numpad.frame.size.height);
	[UIView beginAnimations:nil context:NULL];
	numpad.center = ptOld;
	[UIView commitAnimations];
}


- (void)createPCKeyboard
{
	const CGFloat keyboardHeight = ISIPAD() ? 250 : 175;
	CGRect rect = CGRectMake(0,
		_rootContainer.bounds.size.height-keyboardHeight,
		_rootContainer.bounds.size.width,
		keyboardHeight);
	kbd = [[KeyboardView alloc] initWithFrame:rect
			layout:(NSString*)[_currentScene getAttribute:@"keyboard"]];
	kbd.alpha = [DPSettings shared].floatAlpha;
	[_rootContainer addSubview:kbd];
	kbd.tag = TAG_INPUT_KEYBOARD;
}

- (DPGamepad*)createGamepadHelper
{
	DPThemeScene *scn = [_currentTheme findSceneByName:(NSString*)[_currentScene getAttribute:@"gamepad"]];
	CGFloat height = 240;
	if (ISIPAD()) {
		height = _rootContainer.bounds.size.width*0.3;
	}
	CGRect rect = CGRectMake(0, CGRectGetMaxY(_rootContainer.bounds)-height,
		_rootContainer.bounds.size.width, height);
	
	DPGamepad *gamepad = [[DPGamepad alloc] initWithFrame:rect scene:scn];
	[_rootContainer addSubview:gamepad];
	if (_gamepadConfig) {
		[gamepad applyConfiguration:_gamepadConfig];
	}
	gamepad.gamepadDelegate = self;
	return gamepad;
}

- (void)createJoystick
{
	DPGamepad *gamepad = [self createGamepadHelper];
	gamepad.tag = TAG_INPUT_JOYSTICK;
	gamepad.alpha = [DPSettings shared].floatAlpha;
	gamepad.stickMode = YES;
}

- (void)createGamepad
{
	DPGamepad *gamepad = [self createGamepadHelper];
	gamepad.alpha = [DPSettings shared].floatAlpha;
	gamepad.tag = TAG_INPUT_GAMEPAD;
}



-(void)updateScreen
{
	CGRect viewRect = _rootContainer.bounds;
	if (_currentScene.isPortrait)
	{
		[self fillScreen:_screenRect];
	}
	else
	{
		if (shouldShrinkScreen)
		{
			if (ISIPAD()) {
				viewRect.size.height -= 250;
				[self putScreen:viewRect scaleMode:[DPSettings shared].screenScaleMode];
			} else {
				[self putScreen:viewRect scaleMode:DPScreenScaleModeAspectFit4x3];
			}
		}
		else
		{
			[self putScreen:viewRect scaleMode:[DPSettings shared].screenScaleMode];
		}
	}
}

- (void)toggleScreenSize
{
    shouldShrinkScreen = !shouldShrinkScreen;
    [self updateScreen];
}

// iPhone have many different sizes, but only 3 aspect ratios:
// - 4:3   Original up to iPhone 4S
// - 16:9  iPhone 5 & 6
// - 20:9  iPhone X
- (DPThemeScene*)findSceneForSize:(CGSize)size
{
	CGFloat aspectRatio = size.width / size.height;
	
	if (size.width < size.height)
	{
		if (aspectRatio < 0.52)
		{
			// iPhone Max
			return [_currentTheme findSceneByName:@"iphone-portrait-tall"];
		}
		else if (aspectRatio < 0.6)
		{
			// iPhone 5,6
			return [_currentTheme findSceneByName:@"iphone-portrait-medium"];
		}
		else
		{
			if (size.width >= 768) {
				return [_currentTheme findSceneByName:@"ipad-portrait"];
			} else {
				// iPhone 4S
				return [_currentTheme findSceneByName:@"iphone-portrait-small"];
			}
		}
	}
	else
	{
		if (ISIPAD()) {
			return [_currentTheme findSceneByName:@"ipad-landscape"];
		}
		if (size.width <= 480) { // iPhone 4S
			return [_currentTheme findSceneByName:@"iphone-landscape-short"];
		} else if (aspectRatio < 1.5) {
			return [_currentTheme findSceneByName:@"iphone-landscape-short"];
		} else if (aspectRatio < 1.92 ) {
			return [_currentTheme findSceneByName:@"iphone-landscape-medium"];
		} else {
			return [_currentTheme findSceneByName:@"iphone-landscape-long"];
		}
	}
}

- (UIView*)createSceneView:(DPThemeScene*)scene frame:(CGRect)rootRect
{
	CGFloat scaleX = rootRect.size.width / scene.size.width;
	CGFloat scaleY = rootRect.size.height / scene.size.height;

	UIImageView *sceneContainer = [[UIImageView alloc] initWithFrame:rootRect];
	sceneContainer.userInteractionEnabled = YES;
	if (scene.backgroundImageURL)
		sceneContainer.image = [UIImage imageWithContentsOfFile:scene.backgroundImageURL.path];
	for (NSDictionary *x in scene.nodes)
	{
		CGRect frame = CGRectZero;
		if (x[@"frame"]) {
			NSArray *t = x[@"frame"];
			frame.origin.x    = [t[0] floatValue] * scaleX;
			frame.origin.y    = [t[1] floatValue] * scaleY;
			frame.size.width  = [t[2] floatValue] * scaleX;
			frame.size.height = [t[3] floatValue] * scaleY;
		}
		NSString *type = x[@"type"];
		BOOL hidden = [x[@"hidden"] boolValue];
		if ([type isEqualToString:@"screen"])
		{
			[sceneContainer addSubview:self.screenView];
			_screenRect = frame;
		}
		else if ([type isEqualToString:@"cycles-label"])
		{
			[sceneContainer addSubview:[self cyclesLabel:frame]];
		}
		else if ([type isEqualToString:@"keyboard"])
		{
			KeyboardView* kv;
			kv = [[KeyboardView alloc] initWithFrame:frame layout:x[@"layout"]];
			kv.hidden = hidden;
			[sceneContainer addSubview:kv];
		}
		else if ([type isEqualToString:@"gamepad"])
		{
			NSString *sceneName = x[@"scene"];
			if (!sceneName) sceneName = @"gamepad";
			DPThemeScene *scn = [_currentTheme findSceneByName:sceneName];
			DPGamepad *gamepad = [[DPGamepad alloc] initWithFrame:frame scene:scn];
			gamepad.gamepadDelegate = self;
			gamepad.hidden = hidden;
			if (_gamepadConfig) {
				[gamepad applyConfiguration:_gamepadConfig];
			}
			[sceneContainer addSubview:gamepad];
		}
		else if ([type isEqualToString:@"landbar"])
		{
			// FIXME: A dirty fix, FloatPanel has certain sizing requirements
			// Ignore the frame settings
			CGSize barSize = ISIPAD() ? CGSizeMake(700, 47): CGSizeMake(480, 32);
			frame = CGRectMake((rootRect.size.width-barSize.width)/2, 0, barSize.width, barSize.height);
			UIButton *btnExitFS;
			
			fullscreenPanel = [[FloatPanel alloc] initWithFrame:frame];
			if (ISIPAD()) {
				btnExitFS = [[UIButton alloc] initWithFrame:CGRectMake(0,0,72,36)];
			    btnExitFS.center=CGPointMake(63, 18);
			    [btnExitFS setImage:[UIImage imageNamed:@"exitfull~ipad"] forState:UIControlStateNormal];
			} else {
				btnExitFS = [[UIButton alloc] initWithFrame:CGRectMake(0,0,48,24)];
				btnExitFS.center=CGPointMake(44, 13);
				[btnExitFS setImage:[UIImage imageNamed:@"exitfull.png"] forState:UIControlStateNormal];
			}
			
			[btnExitFS addTarget:self action:@selector(toggleScreenSize) forControlEvents:UIControlEventTouchUpInside];
			[fullscreenPanel.contentView addSubview:btnExitFS];
			[sceneContainer addSubview:fullscreenPanel];
			[self refreshFullscreenPanel];
			[fullscreenPanel showContent];
		}
		else if ([type isEqualToString:@"image"])
		{
			UIImageView *iv = [[UIImageView alloc] initWithFrame:frame];
			if (x[@"bgcolor"]) {
				iv.backgroundColor = [UIColor hexColor:x[@"bgcolor"]];
			}
			if (x[@"bg"]) {
				iv.image = [scene getImage:x[@"bg"]];
			}
			[sceneContainer addSubview:iv];
		}
		else if ([type isEqualToString:@"button"])
		{
			UIButton *btn = [[UIButton alloc] initWithFrame:frame];
			[btn setImage:[scene getImage:x[@"bg"]]
				forState:UIControlStateNormal];
			[btn setImage:[scene getImage:x[@"bg-pressed"]]
				forState:UIControlStateHighlighted];
			[self registerButton:btn name:x[@"id"]];
			[sceneContainer addSubview:btn];
		}
	}
	return sceneContainer;

}

- (void)viewWillLayoutSubviews
{
	CGRect viewRect = [self safeRootRect];
	//CGRect viewRect = CGRectMake(0,0,480,320);
	NSLog(@"viewWillLayoutSubviews: %@", @(viewRect));
	[super viewWillLayoutSubviews];
	DPThemeScene *scene = [self findSceneForSize:viewRect.size];
	NSAssert(scene != nil, @"No scene for %@", @(viewRect));
	_currentScene = scene;
		
	if (_currentScene == scene && _rootContainer &&
		CGRectEqualToRect(_rootContainer.bounds, viewRect))
	{
		// No change
		return;
	}
	if (_rootContainer) {
		NSLog(@"Recreate scene %@ %@, origin=%@", scene.name, @(viewRect), @(_rootContainer.bounds));
		[_rootContainer removeFromSuperview];
	}
	_rootContainer = [self createSceneView:_currentScene frame:viewRect];
	[self.view addSubview:_rootContainer];
	[self updateScreen];
}

// Portrait mode only
- (DPGamepad*)findGamepad
{
	for (UIView *v in _rootContainer.subviews) {
		if ([v isKindOfClass:DPGamepad.class])
			return (DPGamepad*)v;
	}
	return nil;
}

// Portrait mode only
- (KeyboardView*)findKeyboard
{
	for (UIView *v in _rootContainer.subviews) {
		if ([v isKindOfClass:KeyboardView.class])
			return (KeyboardView*)v;
	}
	return nil;
}

- (void)toggleGamepad:(UIButton*)btn
{
	DPGamepad *gamepad = [self findGamepad];
	KeyboardView *kv = [self findKeyboard];
	if (gamepad.isHidden) {
		gamepad.hidden = NO;
		kv.hidden = YES;
	} else {
		gamepad.hidden = YES;
		kv.hidden = NO;
	}
}

- (void)registerButton:(UIButton*)btn name:(NSString*)name
{
	if ([name isEqualToString:@"power"])
	{
		[btn addTarget:self action:@selector(showOption:) forControlEvents:UIControlEventTouchUpInside];
	}
	else if ([name isEqualToString:@"gamepad-toggle"])
	{
		[btn addTarget:self action:@selector(toggleGamepad:) forControlEvents:UIControlEventTouchUpInside];
	}
	else if ([name isEqualToString:@"floppy"])
	{
		[btn addTarget:self action:@selector(mountDrive:) forControlEvents:UIControlEventTouchUpInside];
	}
	else if ([name isEqualToString:@"cdrom"])
	{
		[btn addTarget:self action:@selector(mountCDDrive:) forControlEvents:UIControlEventTouchUpInside];
	}
	else if ([name isEqualToString:@"mouse-right"])
	{
        [btn addTarget:self
                         action:@selector(onMouseRightDown)
               forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self
                        action:@selector(onMouseRightUp)
              forControlEvents:UIControlEventTouchUpInside];
	}
	else if ([name isEqualToString:@"mouse-left"])
	{
        [btn addTarget:self
                    action:@selector(onMouseLeftDown)
          forControlEvents:UIControlEventTouchDown];
        [btn addTarget:self
                    action:@selector(onMouseLeftUp)
          forControlEvents:UIControlEventTouchUpInside];
	}
}

- (void)mountDrive:(id)sender
{
	NSMutableArray *actions = [NSMutableArray array];
	
	[actions addObject:[UIAlertAction
		actionWithTitle:@"Folder"
		style:UIAlertActionStyleDefault
		handler:^(UIAlertAction * _Nonnull action) {
			[self openDriveMountPicker:DriveMount_Folder];
		}]];
		
	[actions addObject:[UIAlertAction
		actionWithTitle:@"iDOS Packages"
		style:UIAlertActionStyleDefault
		handler:^(UIAlertAction * _Nonnull action) {
			[self openDriveMountPicker:DriveMount_Packages];
		}]];
		
	[actions addObject:[UIAlertAction
		actionWithTitle:@"Disk images"
		style:UIAlertActionStyleDefault
		handler:^(UIAlertAction * _Nonnull action) {
			[self openDriveMountPicker:DriveMount_DiskImage];
		}]];

	// iPad has a dedicated CDROM drive button for this
	if (!ISIPAD())
	{
		[actions addObject:[UIAlertAction
			actionWithTitle:@"CD Images"
			style:UIAlertActionStyleDefault
			handler:^(UIAlertAction * _Nonnull action) {
				[self openDriveMountPicker:DriveMount_CDImage];
			}]];
	}
	
	[self alert:@"Mount as drive" message:@"Choose an option"
		actions:actions
		source:sender];
}

- (void)mountCDDrive:(id)sender
{
	[self openDriveMountPicker:DriveMount_CDImage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[DOSPadEmulator sharedInstance] setDelegate:self];
    
    self.screenView.delegate=self;
    self.screenView.mouseHoldDelegate=self;

    holdIndicator = [[HoldIndicator alloc] initWithFrame:CGRectMake(0,0,100,100)];
    holdIndicator.alpha = 0;
    //holdIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [self.view addSubview:holdIndicator];
    
    NSURL *url = [[NSBundle mainBundle].resourceURL URLByAppendingPathComponent:@"default.idostheme"];
    _currentTheme = [[DPTheme alloc] initWithURL:url];
    self.view.backgroundColor = _currentTheme.backgroundColor;

#ifdef APPSTORE
    // For non appstore builds, we should use private API to support
    // external keyboard.
    self.kbdspy = [[KeyboardSpy alloc] initWithFrame:CGRectMake(0,0,60,40)];
    [self.view addSubview:self.kbdspy];
#endif

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSettingsChanged:) name:DPFSettingsChangedNotification object:nil];
}

- (void)didSettingsChanged:(NSNotification*)note
{
    // May be called in background thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateScreen];
    });
}

// MARK: DPGamepadDelegate

- (void)gamepad:(DPGamepad*)gamepad buttonIndex:(DPGamepadButtonIndex)buttonIndex pressed:(BOOL)pressed
{
	//NSLog(@"gamepad %@ %@", [DPGamepad buttonIdForIndex:buttonIndex], pressed?@"DOWN":@"UP");
	
	if (gamepad.editing)
	{
		if (!pressed) {
			DPGamepadButtonEditor *ed = [[DPGamepadButtonEditor alloc] init];
			ed.buttonIndex = buttonIndex;
			ed.gamepadConfig = _gamepadConfig;
			ed.title = [DPGamepad buttonIdForIndex:buttonIndex].uppercaseString;
			ed.completionHandler = ^{
				[gamepad applyConfiguration:_gamepadConfig];
			};
			UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ed];
			nav.modalPresentationStyle = UIModalPresentationFormSheet;
			[self presentViewController:nav animated:YES completion:nil];
		}
		return;
	}
	
	if (gamepad.stickMode) {
		if (buttonIndex == DP_GAMEPAD_BUTTON_A) {
			[[DOSPadEmulator sharedInstance] joystickButton:0
				pressed:pressed joystickIndex:0];
			return;
		} else if (buttonIndex == DP_GAMEPAD_BUTTON_X) {
			[[DOSPadEmulator sharedInstance] joystickButton:1
				pressed:pressed joystickIndex:0];
			return;
		}
	}
	
	DPKeyBinding *keyBinding = [_gamepadConfig bindingForButton:buttonIndex];
	if (keyBinding) {
		if (keyBinding.text) {
			if (!pressed) {
				[[DOSPadEmulator sharedInstance] sendText:keyBinding.text];
			}
		} else if (keyBinding.index > 0) {
			[[DOSPadEmulator sharedInstance] sendKey:keyBinding.index pressed:pressed];
		}
	}
}

- (void)gamepad:(DPGamepad*)gamepad didJoystickMoveWithX:(float)x y:(float)y
{
	//NSLog(@"gamepad joy %f %f", x, y);
	[[DOSPadEmulator sharedInstance] updateJoystick:0 x:x y:y];
}

// MARK: opengles view delegate
// Screen Resize
-(void)onResize:(CGSize)sizeNew
{
    self.screenView.bounds = CGRectMake(0, 0, sizeNew.width, sizeNew.height);
    [self updateScreen];
}

// scale the screen view to fill the available rect,
// and keep it at 4:3 unless it's a wide screen (16:10).
// Return the occupied rect.
- (CGRect)putScreen:(CGRect)availRect scaleMode:(DPScreenScaleMode)scaleMode
{
	CGFloat cx = CGRectGetMidX(availRect);
	CGFloat cy = CGRectGetMidY(availRect);
	CGFloat w = availRect.size.width;
	CGFloat h = availRect.size.height;
    CGFloat sw = self.screenView.bounds.size.width;
    CGFloat sh = self.screenView.bounds.size.height;

	switch (scaleMode) {
		case DPScreenScaleModeAspectFit4x3:
			if (h * 4 / 3 > w)
				h = w * 3 / 4;
			else
				w = h * 4 / 3;
			break;
		case DPScreenScaleModeAspectFit16x10:
			if (h * 16 / 10 > w)
				h = w * 10 / 16;
			else
				w = h * 16 / 10;
			break;
		case DPScreenScaleModeAspectFit16x9:
			if (h * 16 / 9 > w)
				h = w * 9 / 16;
			else
				w = h * 16 / 9;
			break;
		default:
			break;
	}
	[self scaleScreenViewToSize:CGSizeMake(w, h) center:CGPointMake(cx, cy)];
    return CGRectMake(cx-w/2, cy-h/2, w, h);
}

- (void)fillScreen:(CGRect)availRect
{
	CGFloat cx = CGRectGetMidX(availRect);
	CGFloat cy = CGRectGetMidY(availRect);
	CGFloat w = availRect.size.width;
	CGFloat h = availRect.size.height;
	[self scaleScreenViewToSize:availRect.size center:CGPointMake(cx, cy)];
}

- (void)scaleScreenViewToSize:(CGSize)size center:(CGPoint)center
{
    CGFloat sw = self.screenView.bounds.size.width;
    CGFloat sh = self.screenView.bounds.size.height;
    self.screenView.transform = CGAffineTransformMakeScale(size.width/sw,size.height/sh);
	self.screenView.center = CGPointMake(center.x, center.y);
	if ([DPSettings shared].pixelatedScaling) {
		self.screenView.layer.magnificationFilter = kCAFilterNearest;
		self.screenView.layer.shouldRasterize = YES;
	} else {
		self.screenView.layer.magnificationFilter = kCAFilterLinear;
		self.screenView.layer.shouldRasterize = NO;
	}
}

- (NSString*)currentCycles
{
    AppDelegate *d = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    if (d.maxPercent != 0)
    {
        return [NSString stringWithFormat:@"%3d%%", d.maxPercent];
    }
    else
    {
        return [NSString stringWithFormat:@"%4d", d.cycles];
    }
}

- (int)currentFrameskip
{
    AppDelegate *d = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    return d.frameskip;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.screenView.alpha = 1; // Try to fix reboot problem on iPad 3.2.x
    dospad_resume();
    
    if (self.kbdspy)
    {
    	[self.kbdspy becomeFirstResponder];
		[self.view bringSubviewToFront:self.kbdspy];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (ISIPAD() && !_currentScene.isPortrait)
    {
        self.screenView.alpha = 0; // Try to fix reboot problem on iPad 3.2.x
    }
    dospad_pause();
}

-(void)willResignActive
{

}

-(void)didBecomeActive
{
    if (self.kbdspy)
    {
    	[self.kbdspy becomeFirstResponder];
		[self.view bringSubviewToFront:self.kbdspy];
	}
}


- (void)onMouseLeftDown
{
    [self.screenView sendMouseEvent:0 left:YES down:YES];
}

- (void)onMouseLeftUp
{
    [self.screenView sendMouseEvent:0 left:YES down:NO];
}

- (void)onMouseRightDown
{
    [self.screenView sendMouseEvent:0 left:NO down:YES];
}

- (void)onMouseRightUp
{
    [self.screenView sendMouseEvent:0 left:NO down:NO];
}

-(BOOL)onDoubleTap:(CGPoint)pt
{
    // Do nothing
    return NO;
}

// MARK: Mouse Hold
-(void)onHold:(CGPoint)pt
{
	if ([DPSettings shared].showMouseHold)
	{
		CGPoint pt2 = [self.screenView convertPoint:pt toView:self.view];
		holdIndicator.center=pt2;
		[self.view bringSubviewToFront:holdIndicator];
		[UIView animateWithDuration:0.3 animations:^{
			holdIndicator.alpha = 1;
		}];
	}
}

-(void)cancelHold:(CGPoint)pt
{
    holdIndicator.alpha=0;
}

-(void)onHoldMoved:(CGPoint)pt
{
    CGPoint pt2 = [self.screenView convertPoint:pt toView:self.view];
    holdIndicator.center=pt2;
}

-(void)showOption:(id)sender
{
	[self alert:@"Action" message:@"Please choose an option"
		actions:@[
	 		[UIAlertAction actionWithTitle:@"Screenshot"
	 			style:UIAlertActionStyleDefault
	 			handler:^(UIAlertAction * _Nonnull action) {
	 				[[DOSPadEmulator sharedInstance] takeScreenshot];
                }],
	 		[UIAlertAction actionWithTitle:@"Settings"
	 			style:UIAlertActionStyleDefault
	 			handler:^(UIAlertAction * _Nonnull action) {
					if (@available(iOS 10.0, *)) {
						[[UIApplication sharedApplication]
						 openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]
						 options:@{} completionHandler:nil];
					} else {
						[[UIApplication sharedApplication]
						 openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
					}
                }]
		]
		source:sender];
}

- (void)createPianoKeyboard
{
    NSString *ui_cfg = 0;//get_temporary_merged_file(configPath, get_default_config());
    
    if (ui_cfg != nil)
    {
        piano = [[PianoKeyboard alloc] initWithConfig:ui_cfg section:@"[piano.keybinding]"];
        if (piano)
        {
            [self.view addSubview:piano];
        }
    }
}

#pragma mark -
// MARK: Mfi

-(void) openMfiMapper:(id)sender
{
	// Sometimes we press too early before the emulator sets up
	// configuration file.
	if (![DOSPadEmulator sharedInstance].started)
		return;
		
	if (_mfiMapper) {
		[self.view bringSubviewToFront:_mfiMapper];
		return;
	}

	[self createFloatingInput:TAG_INPUT_KEYBOARD];

	CGRect rect = _rootContainer.bounds;
	rect.size.height -= kbd.frame.size.height+4;
	
	CGFloat maxHeight = 400;
	if (rect.size.height > maxHeight)
	{
		rect.origin.y += (rect.size.height - maxHeight)/2;
		rect.size.height = maxHeight;
	}

	CGFloat maxWidth = rect.size.height * 2;
	if (rect.size.width > maxWidth)
	{
		rect.origin.x = (rect.size.width-maxWidth)/2;
		rect.size.width = maxWidth;
	}

	_mfiMapper = [[MfiGamepadMapperView alloc] initWithFrame:rect configuration:_mfiConfig];
	[_rootContainer addSubview:_mfiMapper];
    kbd.externKeyDelegate = self;
	_mfiMapper.delegate = self;
}

// MARK: MfiGamepadMapperDelegate

- (void)mfiGamepadMapperDidClose:(MfiGamepadMapperView *)mapper
{
	_mfiMapper = nil;
	[self removeFloatingInput:TAG_INPUT_KEYBOARD];
}

// MARK: MfiGamepadManagerDelegate

- (void)mfiButton:(MfiGamepadButtonIndex)buttonIndex pressed:(BOOL)pressed atPlayer:(NSInteger)playerIndex
{
	if (_mfiMapper)
	{
		[_mfiMapper onButton:buttonIndex pressed:pressed atPlayer:playerIndex];
		return;
	}

	if (buttonIndex == MFI_GAMEPAD_BUTTON_A || buttonIndex == MFI_GAMEPAD_BUTTON_X)
	{
		if ([_mfiConfig isJoystickAtPlayer:playerIndex])
		{
			[[DOSPadEmulator sharedInstance] joystickButton:(buttonIndex == MFI_GAMEPAD_BUTTON_A?0:1)
				pressed:pressed joystickIndex:playerIndex];
			return;
		}
	}

	int scancode = [_mfiConfig scancodeForButton:buttonIndex atPlayer:playerIndex];
	if (scancode)
	{
		SDL_SendKeyboardKey( 0, pressed?SDL_PRESSED:SDL_RELEASED, scancode);
	}
}

- (void)mfiJoystickMoveWithX:(float)x y:(float)y atPlayer:(NSInteger)playerIndex
{
	if (_mfiMapper)
	{
		[_mfiMapper onJoystickMoveWithX:x y:y atPlayer:playerIndex];
		return;
	}
	if ([_mfiConfig isJoystickAtPlayer:playerIndex])
	{
		[[DOSPadEmulator sharedInstance] updateJoystick:playerIndex x:x y:y];
	}
}

- (void)mfiDidUpdatePlayers
{
	NSLog(@"mfi did update players");
	if (_mfiMapper) {
		[_mfiMapper update];
	}
}

# pragma - mark KeyDelegate
-(void)onKeyDown:(KeyView*)k {
	if (_mfiMapper && k.code > 0)
	{
		[_mfiMapper onKey:k.code pressed:YES];
	}
}

-(void)onKeyUp:(KeyView*)k {
	if (_mfiMapper && k.code > 0)
	{
		[_mfiMapper onKey:k.code pressed:YES];
	}
}

-(void) onKeyFunction:(KeyView *)k {
}

// MARK: DOSEmulatorDelegate

- (void)emulatorWillStart:(DOSPadEmulator *)emulator
{
	_gamepadConfig = [[DPGamepadConfiguration alloc] initWithURL:[NSURL
		fileURLWithPath:[DOSPadEmulator sharedInstance].gamepadConfigFile]];
	[[self findGamepad] applyConfiguration:_gamepadConfig];
	_mfiConfig = [[MfiGamepadConfiguration alloc] initWithConfig:emulator.mfiConfigFile];
	_mfiManager = [MfiGamepadManager defaultManager];
	_mfiManager.delegate = self;
}

- (void)emulator:(DOSPadEmulator *)emulator saveScreenshot:(NSString *)path
{
	UIImage *image = [self.screenView capture];
	if (image) {
		[UIImagePNGRepresentation(image) writeToFile:path atomically:YES];
	}
}

-(void)openDriveMountPicker:(DriveMountType)mountType
{
	NSArray *utis = nil;
	switch (mountType) {
		case DriveMount_Default:
			utis = @[
				@"public.folder",
				@"com.litchie.idos-package",
				@"com.litchie.idos-cdimage",
				@"com.litchie.idos-diskimage"
			];
			break;
		case DriveMount_Folder:
			utis = @[@"public.folder"];
			break;
		case DriveMount_Packages:
			utis = @[
				@"com.litchie.idos-package"
			];
			break;
		case DriveMount_DiskImage:
			utis = @[
				@"com.litchie.idos-diskimage"
			];
			break;
		case DriveMount_CDImage:
			utis = @[
				@"com.litchie.idos-cdimage"
			];
			break;
		default:
			break;
	}
	
	UIDocumentPickerViewController *picker;
	picker = [[UIDocumentPickerViewController alloc]
		initWithDocumentTypes:utis
		inMode:UIDocumentPickerModeOpen];
	picker.delegate = self;
	if (@available(iOS 13.0, *)) {
		picker.shouldShowFileExtensions = YES;
	}
	if (@available(iOS 11.0, *)) {
		picker.allowsMultipleSelection = YES;
	}
	[self presentViewController:picker
		animated:YES
		completion:nil];
}

- (void)emulator:(DOSPadEmulator *)emulator open:(NSString*)path
{
	if (path == nil)
	{
		[self openDriveMountPicker:DriveMount_Default];
	}
	else if ([path isEqualToString:@"-d"])
	{
		[self openDriveMountPicker:DriveMount_Folder];
	}
}


#pragma mark - DocumentPickerDelegate

- (void)documentPicker:(UIDocumentPickerViewController *)controller
	didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls
{
	NSMutableString *cmd = [NSMutableString string];
	NSFileManager *fm = [NSFileManager defaultManager];
	
	for (NSURL *url in urls) {
		NSURL *url = [urls firstObject];
		[url startAccessingSecurityScopedResource];
		NSString *ext = url.pathExtension.lowercaseString;
		if ([ext isEqualToString:@"iso"] || [ext isEqualToString:@"cue"]) {
			[cmd appendFormat:@"imgmount d \"%@\" -t iso -fs iso\n", url.path];
		} else if ([ext isEqualToString:@"img"]) {
			NSDictionary *attrs = [fm attributesOfItemAtPath:url.path error:nil];
			NSNumber *fileSize = [attrs objectForKey:NSFileSize];
			if ([fileSize integerValue] > 2000000) {
				[cmd appendFormat:@"imgmount d \"%@\" -autoinc\n", url.path];
			} else {
				[cmd appendFormat:@"imgmount a \"%@\" -t floppy\n", url.path];
			}
		} else {
			[cmd appendFormat:@"mount d \"%@\" -autoinc\n", url.path];
		}
	}
	
	if ([cmd length] > 1000) {
		[self alert:@"Can not mount" message:@"Too many items"];
		return;
	}
	if ([cmd length] > 0)
		[[DOSPadEmulator sharedInstance] sendCommand:cmd];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
	// Do nothing
}

#pragma mark -
// MARK: Misc configurations

- (BOOL)prefersHomeIndicatorAutoHidden
{
	return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (CGRect)safeRootRect
{
	if (@available(iOS 11.0, *))
		return UIEdgeInsetsInsetRect(self.view.bounds, self.view.safeAreaInsets);
	else
		return self.view.bounds;
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}


@end
