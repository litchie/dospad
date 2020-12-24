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
#define kMouseAbsXScale        @"mouse_abs_xscale"
#define kMouseAbsYScale        @"mouse_abs_yscale"

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
    _mouseAbsXScale = [defs floatForKey:kMouseAbsXScale];
    _mouseAbsYScale = [defs floatForKey:kMouseAbsYScale];
}

@end
