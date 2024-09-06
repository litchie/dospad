/*
 *  Copyright (C) 2020-2024 Chaoji Li
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
