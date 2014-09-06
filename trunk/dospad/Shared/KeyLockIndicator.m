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

#import "KeyLockIndicator.h"


@implementation KeyLockIndicator
@synthesize locked;

- (void)setLocked:(BOOL)l
{
    locked=l;
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.backgroundColor=[UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    UIColor *col;
    if (locked) {
        col=[UIColor colorWithRed:28/255.0 green:217/255.0 blue:3/255.0 alpha:1];
    } else {
        col=[UIColor grayColor];
    }
    [col set];
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGFloat minX = CGRectGetMinX(rect), minY = CGRectGetMinY(rect), 
            maxX = CGRectGetMaxX(rect), maxY = CGRectGetMaxY(rect);
    
    CGFloat radius = rect.size.height/2;
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, (minX + maxX) / 2.0, minY);
    CGContextAddArcToPoint(context, minX, minY, minX, maxY, radius);
    CGContextAddArcToPoint(context, minX, maxY, maxX, maxY, radius);
    CGContextAddArcToPoint(context, maxX, maxY, maxX, minY, radius);
    CGContextAddArcToPoint(context, maxX, minY, minX, minY, radius);
    CGContextClosePath(context);
    // Drawing code
    CGContextFillPath(context);
}

- (void)dealloc {
    [super dealloc];
}


@end
