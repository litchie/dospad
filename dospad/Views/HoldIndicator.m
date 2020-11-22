/*
 *  Copyright (C) 2010  Chaoji Li
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

#import "HoldIndicator.h"


@implementation HoldIndicator


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.layer.cornerRadius = frame.size.width/2;
		self.layer.masksToBounds = YES;
		self.layer.borderWidth = 8;
		self.layer.borderColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1.0].CGColor;
		self.backgroundColor = [UIColor greenColor];
    }
    return self;
}

#if 0
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef myContext=UIGraphicsGetCurrentContext();
    CGGradientRef myGradient;
    CGColorSpaceRef myColorspace;
    size_t num_locations = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 68/255.0,1,59/255.0, 0.5,  // Start color
        68/255.0,1,59/255.0, 0 }; // End color
    
    myColorspace = CGColorSpaceCreateDeviceRGB();
    myGradient = CGGradientCreateWithColorComponents (myColorspace, components,
                                                      locations, num_locations);
    // Drawing code
    
    CGPoint ptCenter = CGPointMake(rect.size.width/2, rect.size.height/2);
    float radius = MIN(rect.size.width/2, rect.size.height/2);

    CGContextDrawRadialGradient (myContext, myGradient, ptCenter,
                                 1, ptCenter, radius,
                                 kCGGradientDrawsBeforeStartLocation);
    
    CGGradientRelease(myGradient);
    CGColorSpaceRelease(myColorspace);
    
    UIImage *img=[UIImage imageNamed:@"holdfinger"];
    CGRect imgRect=CGRectMake( (rect.size.width-img.size.width)/2,
                            (rect.size.height-img.size.height)/2,
                              img.size.width,img.size.height);
    [img drawInRect:imgRect];
}
#endif


@end
