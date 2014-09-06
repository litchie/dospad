//
//  ColorTheme.m
//  TestKeyboard
//
//  Created by Chaoji Li on 8/13/14.
//  Copyright (c) 2014 Chaoji Li. All rights reserved.
//

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
	_defaultTheme = [theme retain];
}

- (void)dealloc
{
	[_colorDict release];
	[super dealloc];
}


@end