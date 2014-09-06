//
//  ColorTheme.m
//  TestKeyboard
//
//  Created by Chaoji Li on 8/13/14.
//  Copyright (c) 2014 Chaoji Li. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface ColorTheme : NSObject

- (id)initWithPath:(NSString*)path;
- (UIColor*)colorByName:(NSString*)name;
+ (ColorTheme*)defaultTheme;
+ (void)setDefaultTheme:(ColorTheme*)theme;

@end
