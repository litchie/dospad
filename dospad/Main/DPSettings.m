//
//  DPSettings.m
//  dospad
//
//  Created by Chaoji Li on 2020/11/19.
//

#import "DPSettings.h"

#define kTapAsClick @"tap_as_click"
#define kScreenScaleMode @"screen_scale_mode"
#define kDoubleTapAsRightClick @"double_tap_as_right_click"
#define kMouseSpeed            @"mouse_speed"
#define kTransparency          @"transparency"
#define kShowMouseHold         @"show_mouse_hold"
#define kKeySoundEnabled       @"key_sound_enabled"
#define kGamePadSoundEnabled   @"gamepad_sound_enabled"
#define kAutoOpenLast          @"auto_open_last"
#define kPixelatedScaling      @"screen_pixelated"
#define kMouseAbsEnable        @"mouse_abs_enable"
#define kMouseNumpadMultiToggle  @"mouse_numpad_multi_toggle"
#define kLandbarToggleBottonScreen @"landbar_toggle_bottom_screen"
#define kAutoShrinkScreenKeyboardEnabled @"auto_shrink_screen_keyboard_enabled"

static DPSettings *s_settings;

@implementation DPSettings

+ (DPSettings*)shared
{
	if (!s_settings) {
		s_settings = [[DPSettings alloc] init];
	}
	return s_settings;
}


- (id)init
{
	if (self = [super init]) {
		[self registerDefaultSettings];

		[[NSNotificationCenter defaultCenter]
			addObserver:self
    		selector:@selector(defaultsDidChange:)
    		name:NSUserDefaultsDidChangeNotification
    		object:nil];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults addObserver:self forKeyPath:@"landbar_toggle_bottom_screen" options:NSKeyValueObservingOptionNew context:NULL];
        
		[self loadDefaults];
	}
	return self;
}

- (void)registerDefaultSettings
{
	NSString *path = [[NSBundle mainBundle] bundlePath];
	path = [path stringByAppendingPathComponent:@"Settings.bundle"];
	path = [path stringByAppendingPathComponent:@"Root.plist"];
	NSDictionary *settingsDict = [NSDictionary dictionaryWithContentsOfFile:path];
	NSArray *prefs = settingsDict[@"PreferenceSpecifiers"];
	NSMutableDictionary *defs = [NSMutableDictionary dictionary];
	for (NSDictionary *item in prefs) {
		NSString *key = item[@"Key"];
		NSObject *obj = item[@"DefaultValue"];
		if (key && obj) {
			defs[key] = obj;
		}
	}
	if (defs.count > 0) {
		[[NSUserDefaults standardUserDefaults] registerDefaults:defs];
	}
}

- (void)defaultsDidChange:(NSNotification *)aNotification
{
	NSLog(@"defaultsDidChange");
	[self loadDefaults];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification
		notificationWithName:DPFSettingsChangedNotification object:nil]];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSLog(@"KVO: %@ changed property %@ to value %@", object, keyPath, change);
}

- (void)loadDefaults
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    _tapAsClick = [defs boolForKey:kTapAsClick];
	_screenScaleMode = [defs integerForKey:kScreenScaleMode];
	_doubleTapAsRightClick = [defs integerForKey:kDoubleTapAsRightClick];
	_mouseSpeed = [defs floatForKey:kMouseSpeed];
	_floatAlpha = 1-[defs floatForKey:kTransparency];
	_showMouseHold = [defs boolForKey:kShowMouseHold];
	_keyPressSound = [defs boolForKey:kKeySoundEnabled];
	_gamepadSound = [defs boolForKey:kGamePadSoundEnabled];
	_autoOpenLastPackage = [defs boolForKey:kAutoOpenLast];
	_pixelatedScaling = [defs boolForKey:kPixelatedScaling];
    _mouseAbsEnable = [defs boolForKey:kMouseAbsEnable];
    _mouseNumpadMultiToggle = [defs boolForKey:kMouseNumpadMultiToggle];
    _landbarToggleBottomScreen = [defs boolForKey:kLandbarToggleBottonScreen];
    _autoShrinkScreenKeyboardEnabled = [defs boolForKey:kAutoShrinkScreenKeyboardEnabled];
}

@end
