//
//  UIColor+hexColor.m
//  Created by Chaoji Li on 2020/8/8.
//  Copyright © 2020 Chaoji Li. All rights reserved.
//

#import "UIColor+hexColor.h"

static NSMutableDictionary *colors = nil;

@implementation UIColor (hexColor)

+ (UIColor*)hexColor:(NSString*)hexString
{
    if (!colors) {
        colors = [NSMutableDictionary dictionary];
    }
    UIColor *c = colors[hexString];
    if (!c) {
        unsigned rgbValue = 0;
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        [scanner setScanLocation:1]; // bypass '#' character
        [scanner scanHexInt:&rgbValue];
        c = [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0
            green:((rgbValue & 0xFF00) >> 8)/255.0
            blue:(rgbValue & 0xFF)/255.0
            alpha:1.0];
        colors[hexString] = c;
    }
    return c;
}

- (NSString*)hexString
{
    CGFloat red, green, blue, alpha;
    [self getRed:&red green:&green blue:&blue alpha:&alpha];
    return [NSString stringWithFormat:@"#%02x%02x%02x",
        (int)(red * 255),
        (int)(green * 255),
        (int)(blue * 255)];
}

@end
