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

#import "TipView.h"

#define TIP_ARROW_LENGTH 20.0f
#define TIP_ARROW_WIDTH  10.0f

@implementation TipView
@synthesize label;

-(id)initWithFrame:(CGRect)frame style:(TipViewStyle)_style pointTo:(CGPoint)pt
{
    if ((self = [super initWithFrame:frame])) {
        style = _style;
        pointTo=CGPointMake(pt.x-frame.origin.x,pt.y-frame.origin.y);
        self.backgroundColor=[UIColor clearColor];
        CGRect rect=frame;
        rect.origin=CGPointZero;
        switch (style) {
            case TipViewUpward:
                rect.origin.y+=TIP_ARROW_LENGTH;
                rect.size.height-=TIP_ARROW_LENGTH;
                break;
            case TipViewToLeft:
                rect.origin.x+=TIP_ARROW_LENGTH;
                rect.size.width-=TIP_ARROW_LENGTH;
                break;
            case TipViewToRight:
                rect.size.width-=TIP_ARROW_LENGTH;
                break;
            case TipViewDownward:
                rect.size.height-=TIP_ARROW_LENGTH;
                break;
        }
                
        label = [[UILabel alloc] initWithFrame:rect];
        label.backgroundColor=[UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment=UITextAlignmentCenter;
        [self addSubview:label];
    }
    return self;    
}

-(void)drawRoundedRectangle
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1] set];
    
	// If you were making this as a routine, you would probably accept a rectangle
	// that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
	CGRect rrect = label.frame;
	CGFloat radius = 10;
	// NOTE: At this point you may want to verify that your radius is no more than half
	// the width and height of your rectangle, as this technique degenerates for those cases.
	
	// In order to draw a rounded rectangle, we will take advantage of the fact that
	// CGContextAddArcToPoint will draw straight lines past the start and end of the arc
	// in order to create the path from the current position and the destination position.
	
	// In order to create the 4 arcs correctly, we need to know the min, mid and max positions
	// on the x and y lengths of the given rectangle.
	CGFloat minx = CGRectGetMinX(rrect), midx = CGRectGetMidX(rrect), maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect), midy = CGRectGetMidY(rrect), maxy = CGRectGetMaxY(rrect);
	
	// Next, we will go around the rectangle in the order given by the figure below.
	//       minx    midx    maxx
	// miny    2       3       4
	// midy   1 9              5
	// maxy    8       7       6
	// Which gives us a coincident start and end point, which is incidental to this technique, but still doesn't
	// form a closed path, so we still need to close the path to connect the ends correctly.
	// Thus we start by moving to point 1, then adding arcs through each pair of points that follows.
	// You could use a similar tecgnique to create any shape with rounded corners.
	
	// Start at 1
	CGContextMoveToPoint(context, minx, midy);
	// Add an arc through 2 to 3
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	// Add an arc through 4 to 5
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	// Add an arc through 6 to 7
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	// Add an arc through 8 to 9
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	// Close the path
	CGContextClosePath(context);
	// Fill & stroke the path
	CGContextDrawPath(context, kCGPathFillStroke);    
    
}

/*        B
       A /\ C
        -----------
        /          \
        \----------/
 
 */
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self drawRoundedRectangle];
    CGPoint a,b,c;
    b = pointTo;
    switch (style) {
        case TipViewToLeft:
            c.x=a.x = b.x+TIP_ARROW_LENGTH;
            c.y = b.y - TIP_ARROW_WIDTH/2;
            a.y = b.y + TIP_ARROW_WIDTH/2;
            break;
        case TipViewToRight:
            c.x=a.x = b.x-TIP_ARROW_LENGTH;
            c.y = b.y - TIP_ARROW_WIDTH/2;
            a.y = b.y + TIP_ARROW_WIDTH/2;
            break;
        case TipViewUpward:
            a.x = b.x-TIP_ARROW_WIDTH/2;
            c.x = b.x+TIP_ARROW_WIDTH/2;
            c.y = a.y = b.y+TIP_ARROW_LENGTH;
            break;
        case TipViewDownward:
            a.x = b.x-TIP_ARROW_WIDTH/2;
            c.x = b.x+TIP_ARROW_WIDTH/2;
            c.y = a.y = b.y-TIP_ARROW_LENGTH;
            break;            
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1] set];
    CGContextMoveToPoint(context, a.x, a.y);
    CGContextAddLineToPoint(context, b.x, b.y);
    CGContextAddLineToPoint(context, c.x, c.y);
    CGContextClosePath(context);
    CGContextFillPath(context);
}


- (void)dealloc {
    [label release];
    [super dealloc];
}


@end
