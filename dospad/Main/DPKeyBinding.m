//
//  DPKeyBinding.m
//  iDOS
//
//  Created by Chaoji Li on 2020/11/1.
//

#import "DPKeyBinding.h"
#include "keys.h"

static struct {
	const char *name;
	int code;
} keytable[] = {
	{"key-0",                         SDL_SCANCODE_0},
	{"key-1",                         SDL_SCANCODE_1},
	{"key-2",                         SDL_SCANCODE_2},
	{"key-3",                         SDL_SCANCODE_3},
	{"key-4",                         SDL_SCANCODE_4},
	{"key-5",                         SDL_SCANCODE_5},
	{"key-6",                         SDL_SCANCODE_6},
	{"key-7",                         SDL_SCANCODE_7},
	{"key-8",                         SDL_SCANCODE_8},
	{"key-9",                         SDL_SCANCODE_9},
	{"key-a",                         SDL_SCANCODE_A},
	{"key-b",                         SDL_SCANCODE_B},
	{"key-backslash",                 SDL_SCANCODE_BACKSLASH},
	{"key-backspace",                 SDL_SCANCODE_BACKSPACE},
	{"key-break",                     SDL_SCANCODE_PAUSE},
	{"key-c",                         SDL_SCANCODE_C},
	{"key-caps-lock",                 SDL_SCANCODE_CAPSLOCK},
	{"key-comma",                     SDL_SCANCODE_COMMA},

	{"key-d",                         SDL_SCANCODE_D},
	{"key-delete",                    SDL_SCANCODE_DELETE},
	{"key-down",                      SDL_SCANCODE_DOWN},
	{"key-e",                         SDL_SCANCODE_E},
	{"key-end",                       SDL_SCANCODE_END},
	{"key-enter",                     SDL_SCANCODE_RETURN},
	{"key-equals",                    SDL_SCANCODE_EQUALS},
	{"key-esc",                       SDL_SCANCODE_ESCAPE},
	{"key-f",                         SDL_SCANCODE_F},
	{"key-f1",                        SDL_SCANCODE_F1},
	{"key-f10",                       SDL_SCANCODE_F10},
	{"key-f11",                       SDL_SCANCODE_F11},
	{"key-f12",                       SDL_SCANCODE_F12},
	{"key-f2",                        SDL_SCANCODE_F2},
	{"key-f3",                        SDL_SCANCODE_F3},
	{"key-f4",                        SDL_SCANCODE_F4},
	{"key-f5",                        SDL_SCANCODE_F5},
	{"key-f6",                        SDL_SCANCODE_F6},
	{"key-f7",                        SDL_SCANCODE_F7},
	{"key-f8",                        SDL_SCANCODE_F8},
	{"key-f9",                        SDL_SCANCODE_F9},
	{"key-fn",                        DP_KEY_FN},
	{"key-g",                         SDL_SCANCODE_G},
	{"key-grave",                     SDL_SCANCODE_GRAVE},
	{"key-h",                         SDL_SCANCODE_H},
	{"key-home",                      SDL_SCANCODE_HOME},
	{"key-i",                         SDL_SCANCODE_I},
	{"key-insert",                    SDL_SCANCODE_INSERT},
	{"key-j",                         SDL_SCANCODE_J},
	{"key-k",                         SDL_SCANCODE_K},
	{"key-kp-5",                      SDL_SCANCODE_KP_5},
	{"key-kp-add",                    SDL_SCANCODE_KP_PLUS},
	{"key-kp-delete",                 SDL_SCANCODE_KP_BACKSPACE},
	{"key-kp-divide",                 SDL_SCANCODE_KP_DIVIDE},
	{"key-kp-down",                   SDL_SCANCODE_KP_2},
	{"key-kp-end",                    SDL_SCANCODE_KP_1},
	{"key-kp-enter",                  SDL_SCANCODE_KP_ENTER},
	{"key-kp-home",                   SDL_SCANCODE_KP_7},
	{"key-kp-insert",                 SDL_SCANCODE_KP_0},
	{"key-kp-left",                   SDL_SCANCODE_KP_4},
	{"key-kp-multiply",               SDL_SCANCODE_KP_MULTIPLY},
	{"key-kp-page-down",              SDL_SCANCODE_KP_3},
	{"key-kp-page-up",                SDL_SCANCODE_KP_9},
	{"key-kp-right",                  SDL_SCANCODE_KP_6},
	{"key-kp-subtract",               SDL_SCANCODE_KP_MINUS},
	{"key-kp-up",                     SDL_SCANCODE_KP_8},
	{"key-l",                         SDL_SCANCODE_L},
	{"key-lalt",                      SDL_SCANCODE_LALT},
	{"key-lctrl",                     SDL_SCANCODE_LCTRL},
	{"key-left",                      SDL_SCANCODE_LEFT},
//	{"key-left-backslash",            SDL_SCANCODE_},
	{"key-left-bracket",              SDL_SCANCODE_LEFTBRACKET},
	{"key-lshift",                    SDL_SCANCODE_LSHIFT},
	{"key-m",                         SDL_SCANCODE_M},
	{"key-minus",                     SDL_SCANCODE_MINUS},
	{"key-n",                         SDL_SCANCODE_N},
	{"key-num-lock",                  SDL_SCANCODE_NUMLOCKCLEAR},
	{"key-o",                         SDL_SCANCODE_O},
	{"key-p",                         SDL_SCANCODE_P},
	{"key-page-down",                 SDL_SCANCODE_PAGEDOWN},
	{"key-page-up",                   SDL_SCANCODE_PAGEUP},
	{"key-pause",                     SDL_SCANCODE_PAUSE},
	{"key-period",                    SDL_SCANCODE_PERIOD},
	{"key-print",                     SDL_SCANCODE_PRINTSCREEN},
	{"key-q",                         SDL_SCANCODE_Q},
	{"key-quote",                     SDL_SCANCODE_APOSTROPHE},
	{"key-r",                         SDL_SCANCODE_R},
	{"key-ralt",                      SDL_SCANCODE_RALT},
	{"key-rctrl",                     SDL_SCANCODE_RCTRL},
	{"key-right",                     SDL_SCANCODE_RIGHT},
	{"key-right-bracket",             SDL_SCANCODE_RIGHTBRACKET},
	{"key-rshift",                    SDL_SCANCODE_RSHIFT},
	{"key-s",                         SDL_SCANCODE_S},
	{"key-scrl-lock",                 SDL_SCANCODE_SCROLLLOCK},
	{"key-semicolon",                 SDL_SCANCODE_SEMICOLON},
	{"key-slash",                     SDL_SCANCODE_SLASH},
	{"key-space",                     SDL_SCANCODE_SPACE},
	{"key-t",                         SDL_SCANCODE_T},
	{"key-tab",                       SDL_SCANCODE_TAB},
	{"key-u",                         SDL_SCANCODE_U},
	{"key-up",                        SDL_SCANCODE_UP},
	{"key-v",                         SDL_SCANCODE_V},
	{"key-w",                         SDL_SCANCODE_W},
	{"key-x",                         SDL_SCANCODE_X},
	{"key-y",                         SDL_SCANCODE_Y},
	{"key-z",                         SDL_SCANCODE_Z},

	// For binding to mouse button
	{"mouse-left",                    DP_KEY_MOUSE_LEFT},
	{"mouse-right",                   DP_KEY_MOUSE_RIGHT},
};

@implementation DPKeyBinding

- (id)initWithText:(NSString*)text
{
	self = [super init];
	self.text = text;
	return self;
}

- (id)initWithKeyIndex:(DPKeyIndex)keyIndex
{
	self = [super init];
	self.index = keyIndex;
	return self;
}

- (NSString*)name
{
	if (!_name) {
		_name = [DPKeyBinding keyName:self.index];
	}
	return _name;
}

- (id)initWithAttributes:(NSDictionary*)attrs
{
	self = [super init];
	if (attrs[@"text"]) {
		self.text = attrs[@"text"];
	} else if (attrs[@"key"]) {
		self.index = [DPKeyBinding keyIndexFromName:attrs[@"key"]];
		if (self.index != SDL_SCANCODE_UNKNOWN) {
			self.name = attrs[@"key"];
		}
	}
	return self;
}

#define ARRAY_SIZE(a)  (sizeof(a)/sizeof(a[0]))

+ (NSString*)keyName:(DPKeyIndex)index
{
	for (int i = 0; i < ARRAY_SIZE(keytable); i++) {
		if (keytable[i].code == index)
			return [NSString stringWithUTF8String:keytable[i].name];
	}
	return @"key-unknown";
}

+ (int)keyIndexFromName:(NSString*)name
{
	unsigned l, h;
	l = 0;
	h = ARRAY_SIZE(keytable);
	
	if (name == nil)
		return 0;
	
	while (l < h) {
		unsigned mid = (l + h) / 2;
		int cmp = strcmp(name.UTF8String, keytable[mid].name);
		if (cmp > 0) {
			l = mid + 1;
		} else if (cmp < 0) {
			h = mid;
		} else {
			return keytable[mid].code;
		}
	}
	return SDL_SCANCODE_UNKNOWN;
}

@end
