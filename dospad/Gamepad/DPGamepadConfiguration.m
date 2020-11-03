//
//  DPGamepadConfiguration.m
//  iDOS
//
//  Created by Chaoji Li on 2020/11/1.
//

#import "DPGamepadConfiguration.h"

@interface DPGamepadConfiguration()
{
	DPKeyBinding *_bindings[DP_GAMEPAD_BUTTON_TOTAL];
	NSString *_titles[DP_GAMEPAD_BUTTON_TOTAL];
	BOOL _hidden[DP_GAMEPAD_BUTTON_TOTAL];
	BOOL _modified;
}
@end

@implementation DPGamepadConfiguration

- (id)initWithURL:(NSURL*)url
{
	self = [super init];
	_fileURL = url;
	NSFileManager *fm = [NSFileManager defaultManager];
	if ([fm fileExistsAtPath:url.path])
	{
		NSDictionary *info = [self loadJSON:url];
		for (int i = 0; i < DP_GAMEPAD_BUTTON_TOTAL; i++)
		{
			NSString *name = [DPGamepad buttonIdForIndex:i];
			if (name && info[name]) {
				_titles[i] = info[name][@"title"];
				_bindings[i] = [[DPKeyBinding alloc] initWithAttributes:info[name]];
				_hidden[i] = [info[name][@"hidden"] boolValue];
			}
		}
	}
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

- (DPKeyBinding*)bindingForButton:(DPGamepadButtonIndex)buttonIndex
{
	return _bindings[buttonIndex];
}

- (void)setBinding:(DPKeyBinding*)binding forButton:(DPGamepadButtonIndex)buttonIndex
{
	_bindings[buttonIndex] = binding;
	_modified = YES;
}

- (NSString*)titleForButtonIndex:(DPGamepadButtonIndex)buttonIndex
{
	return _titles[buttonIndex];
}

- (void)setTitle:(NSString*)title forButton:(DPGamepadButtonIndex)buttonIndex
{
	_titles[buttonIndex] = title;
	_modified = YES;
}

- (void)setHidden:(BOOL)hidden forButton:(DPGamepadButtonIndex)buttonIndex
{
	_hidden[buttonIndex] = hidden;
	_modified = YES;
}

- (BOOL)isButtonHidden:(DPGamepadButtonIndex)buttonIndex
{
	return _hidden[buttonIndex];
}


- (BOOL)save
{
	if (_modified)
	{
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		for (int i = 0; i < DP_GAMEPAD_BUTTON_TOTAL; i++)
		{
			if (_bindings[i])
			{
				NSString *name = [DPGamepad buttonIdForIndex:i];
				NSMutableDictionary *x = [NSMutableDictionary dictionary];
				x[@"hidden"] = @(_hidden[i]);
				if (_bindings[i].text) {
					x[@"text"] = _bindings[i].text;
				} else {
					x[@"key"] = _bindings[i].name;
				}
				if (_titles[i]) {
					x[@"title"] = _titles[i];
				}
				dict[name] = x;
			}
		}

		NSError *err = nil;
	    NSData *configData = [NSJSONSerialization dataWithJSONObject:dict
    	options:(NSJSONWritingPrettyPrinted)
    	error:&err];
		if ([configData writeToFile:_fileURL.path atomically:YES]) {
			_modified = NO;
			return YES;
		}
		return NO;
	}
	return YES;
}

@end
