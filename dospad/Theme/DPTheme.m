//
//  DPTheme.m
//  iDOS
//
//  Created by Chaoji Li on 2020/10/26.
//

#import "DPTheme.h"
#import "UIColor+hexColor.h"

@interface DPTheme ()
{
	NSMutableDictionary<NSString*, DPThemeScene*> *_scenes;
}
@end


@implementation DPTheme

- (id)initWithURL:(NSURL*)url
{
	self = [super init];
	_baseURL = url;
	_scenes = [NSMutableDictionary dictionary];
	NSError *err = nil;
	NSURL *infoURL = [_baseURL URLByAppendingPathComponent:@"index.json"];
	NSDictionary *info = [self loadJSON:infoURL];
	self.version = [info[@"version"] intValue];
	self.backgroundColor = [UIColor hexColor:info[@"bgcolor"]];
	self.gamepadTextColor = [UIColor hexColor:info[@"gamepad-text-color"]];
	self.gamepadEditingTextColor = [UIColor hexColor:info[@"gamepad-editing-text-color"]];
	return self;
}


- (NSDictionary*)loadJSON:(NSURL*)url
{
	NSError *err = nil;
	NSData *data = [NSData dataWithContentsOfURL:url];
	if (data) {
		NSDictionary *x = [NSJSONSerialization
				  JSONObjectWithData:data
				  options:0
				  error:&err];
		if (err) {
			NSLog(@"loadJSON: %@", err);
			return nil;
		}
		if (![x isKindOfClass:NSDictionary.class])
		{
			NSLog(@"loadJSON: Not a dictionary");
			return nil;
		}
		return x;
	} else {
		NSLog(@"loadJSON: invalid data");
		return nil;
	}
}

- (DPThemeScene*)findSceneByName:(NSString*)name
{
	if (_scenes[name])
		return _scenes[name];
	NSFileManager *fm = [NSFileManager defaultManager];
	NSURL *url = [_baseURL URLByAppendingPathComponent:[NSString stringWithFormat:@"scenes/%@.json", name]];
	if ([fm fileExistsAtPath:url.path])
	{
		NSDictionary *x = [self loadJSON:url];
		DPThemeScene *scene = [[DPThemeScene alloc] initWithAttributes:x theme:self];
		_scenes[name] = scene;
		return scene;
	}
	return nil;
}

@end
