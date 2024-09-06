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


#import "DPThemeScene.h"
#import "DPTheme.h"

@interface DPThemeScene ()
{
        NSDictionary* _attrs;
}
@end

@implementation DPThemeScene

- (BOOL)isPortrait
{
	return _size.width < _size.height;
}

- (id)initWithAttributes:(NSDictionary*)attrs theme:(DPTheme*)theme
{
	self = [super init];
	_attrs = attrs;
	_theme = theme;
	_size.width = [(NSNumber*)attrs[@"width"] floatValue];
	_size.height = [(NSNumber*)attrs[@"height"] floatValue];
	_name = attrs[@"name"];
	NSString *s = attrs[@"background"];
	if (s) {
		_backgroundImageURL = [theme.baseURL URLByAppendingPathComponent:s];
	}
	
	s = attrs[@"scale"];
	if ([s isEqualToString:@"none"]) {
		_scaleMode = DPThemeSceneScaleNone;
	} else if ([s isEqualToString:@"fill"]) {
		_scaleMode = DPThemeSceneScaleFill;
	} else {
		_scaleMode = DPThemeSceneScaleAspectFill;
	}

    _nodes = attrs[@"nodes"];

	return self;
}

- (UIImage*)getImage:(NSString *)name
{
	if (name == nil)
		return nil;
	NSURL *url = [_theme.baseURL URLByAppendingPathComponent:name];
	return [UIImage imageWithContentsOfFile:url.path];
}

- (NSObject*)getAttribute:(NSString *)name
{
	return _attrs[name];
}

@end
