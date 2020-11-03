//
//  DPThemeScene.m
//  iDOS
//
//  Created by Chaoji Li on 2020/10/27.
//

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
