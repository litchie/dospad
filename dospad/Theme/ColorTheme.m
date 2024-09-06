/*
 *  Copyright (C) 2014-2024 Chaoji Li
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


#import "ColorTheme.h"

@interface ColorTheme ()
{
	NSMutableDictionary *_colorDict;
}

@end

static ColorTheme* _defaultTheme;

@implementation ColorTheme

#define RED(a)   (((a)>>16) & 0xff)
#define GREEN(a) (((a)>>8)  & 0xff)
#define BLUE(a)  (((a))     & 0xff)

- (id)initWithPath:(NSString*)path
{
	self = [super init];
	if (self) {
		NSDictionary *dict = [NSJSONSerialization
							  JSONObjectWithData:[NSData dataWithContentsOfFile:path]
							  options:0
							  error:nil];
		_colorDict = [[NSMutableDictionary alloc] init];
		if (dict != nil && [dict isKindOfClass:[NSDictionary class]]) {
			for (NSString *k in dict.allKeys) {
				NSString *value = [dict objectForKey:k];
				int a = 0;
				if (sscanf(value.UTF8String, "#%x", &a) == 1) {
					UIColor *color = [UIColor colorWithRed:RED(a)/255.0
													 green:GREEN(a)/255.0
													  blue:BLUE(a)/255.0
													  alpha:1.0];
					[_colorDict setObject:color forKey:k];
				}
			}
		}
	}
	return self;
}

- (UIColor*)colorByName:(NSString*)name
{
	return [_colorDict objectForKey:name];
}

+ (ColorTheme*)defaultTheme
{
	return _defaultTheme;
}

+ (void)setDefaultTheme:(ColorTheme *)theme
{
	_defaultTheme = theme;
}



@end
