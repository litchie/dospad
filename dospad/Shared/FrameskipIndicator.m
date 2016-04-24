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

#import "FrameskipIndicator.h"


@implementation FrameskipIndicator
@synthesize count;


-(void)setCount:(int)cnt
{
    count=cnt;
    [self setNeedsDisplay];
}


- (id)initWithFrame:(CGRect)frame style:(FrameskipIndicatorStyle)_style {
    if ((self = [super initWithFrame:frame])) {
        style=_style;
        self.backgroundColor=[UIColor clearColor];
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect 
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(ctx, 121/255.0, 196/255.0, 5/255.0, 1); // Green bars
    if ((style == FrameskipIndicatorStyleAuto
         && rect.size.width >= rect.size.height) // wider 
        || style == FrameskipIndicatorStyleHorizontal)
    {
        float barWidth = rect.size.width/MAX(5, count);
        for (int i = 0; i < count; i++) {
            CGRect rcBar=CGRectMake(i*barWidth, 0, barWidth*0.8, rect.size.height);
            CGContextFillRect(ctx, rcBar);
        }
    }
    else 
    {
        float barHeight = rect.size.height/MAX(5, count);
        float realHeight = barHeight * 0.5;
        float posY = rect.size.height - realHeight;
        for (int i = 0; i < count; i++) {
            CGRect rcBar = CGRectMake(0, posY, rect.size.width, realHeight);
            CGContextFillRect(ctx, rcBar);
            posY -= barHeight;
        }
    }
}



@end
