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
