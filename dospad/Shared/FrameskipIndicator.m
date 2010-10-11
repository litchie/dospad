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
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
    [[UIColor blackColor] set];
    CGContextRef ctx=UIGraphicsGetCurrentContext();
    CGContextFillRect(ctx, rect);
    CGContextSetRGBFillColor(ctx, 121/255.0, 196/255.0, 5/255.0, 1);
    
    if ( (style==FrameskipIndicatorStyleAuto
          && rect.size.width >= rect.size.height)
        || style==FrameskipIndicatorStyleHorizontal)
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
        for (int i = 0; i < count; i++) {
            CGRect rcBar=CGRectMake(0, rect.size.height-(i+1)*barHeight+0.5*barHeight, 
                                    rect.size.width,
                                    barHeight*0.5);
            CGContextFillRect(ctx, rcBar);
        }
    }
}

- (void)dealloc {
    [super dealloc];
}


@end
