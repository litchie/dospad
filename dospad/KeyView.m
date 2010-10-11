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

#import "KeyView.h"
#import "KeyboardView.h"
#import <AudioToolbox/AudioServices.h>
#import "Common.h"
#include "SDL.h"
static SystemSoundID keyPressSound=0;

@implementation KeyView

@synthesize code,title,highlight,padding;
@synthesize textColor;
@synthesize bkgColor,edgeColor;
@synthesize delegate;

-(void)setHighlight:(BOOL)b
{
    highlight=b;
    [self setNeedsDisplay];
}

-(void)setTitle:(NSString *)t
{
    if (title != nil) [title release];
    title = t;
    [title retain];
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor blackColor];
        self.bkgColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor blackColor];
        self.bkgColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    }
    return self;
}

-(void)drawRoundedRectangle
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    [bkgColor set];

	// If you were making this as a routine, you would probably accept a rectangle
	// that defines its bounds, and a radius reflecting the "rounded-ness" of the rectangle.
	CGRect rrect = self.bounds;
    rrect.origin.x += padding;
    rrect.origin.y += padding;
    rrect.size.width -= padding*2;
    rrect.size.height -= padding*2;
    
	CGFloat radius = 6;
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

    if (edgeColor==nil) {
        [[UIColor blackColor] set];
    } else {
        [edgeColor set];
    }
    CGContextSetLineWidth(context, 1);

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
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextMoveToPoint(context, minx+radius, miny);
    CGContextAddLineToPoint(context, maxx-radius, miny);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, minx+radius, maxy);
    CGContextAddLineToPoint(context, maxx-radius, maxy);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, minx, miny+radius);
    CGContextAddLineToPoint(context, minx, maxy-radius);
    CGContextStrokePath(context);
    
    CGContextMoveToPoint(context, maxx, miny+radius);
    CGContextAddLineToPoint(context, maxx, maxy-radius);
    CGContextStrokePath(context);
    
}

- (void)drawRect:(CGRect)rect {
    UIColor *origTextColor = self.textColor;
    UIColor *origBkgColor = self.bkgColor;
    [origBkgColor retain];
    [origTextColor retain];
    
    if (self.highlight) {
        self.textColor = [UIColor blackColor];
        self.bkgColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
    }
    
    // Drawing code
    [self drawRoundedRectangle];

    if (title == nil||[title length]==0) return;
    [textColor set];

    if ([title length] == 1 || [[title substringToIndex:1] compare:@"F"] == 0) {
        UIFont *font = [UIFont systemFontOfSize:12];
        CGSize size = [title sizeWithFont:font];
        float offsetX = (self.bounds.size.width - size.width)/2;
        float offsetY = (self.bounds.size.height - size.height)/2;
        [title drawInRect:CGRectMake(offsetX,offsetY,size.width,size.height) withFont:font];            
    } else if ([title length] == 2) {
        UIFont *font;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            font = [UIFont systemFontOfSize:12];
        } else {
            font = [UIFont systemFontOfSize:10];
        }
        NSString * down = [title substringToIndex:1];
        NSString * up = [title substringFromIndex:1];
        CGSize size = [down sizeWithFont:font];
        float offsetX = (self.bounds.size.width - size.width)/2;
        float offsetY;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            offsetY = 5;
        } else {
            offsetY = 2;
        }
        [up drawInRect:CGRectMake(offsetX,offsetY,size.width,size.height) withFont:font];            
        [down drawInRect:CGRectMake(offsetX,self.bounds.size.height-offsetY-size.height,size.width,size.height) withFont:font];            
    } else {
        UIFont *font;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            font = [UIFont systemFontOfSize:9];
        } else {
            font = [UIFont systemFontOfSize:8];
        }
        CGSize size = [title sizeWithFont:font];
        float offsetX = (self.bounds.size.width - size.width)/2;
        float offsetY = (self.bounds.size.height - size.height)/2;
        [title drawInRect:CGRectMake(offsetX,offsetY,size.width,size.height) withFont:font];            
    }
    
    if (self.highlight) {
        self.textColor=origTextColor;
        self.bkgColor=origBkgColor;
    }
    [origBkgColor release];
    [origTextColor release];
}

- (void)dealloc {
    self.textColor = nil;
    self.bkgColor = nil;
    self.title = nil;
    self.edgeColor=nil;
    [super dealloc];
}

-(void)playKeyPressSound
{
    if (DEFS_GET_INT(kDisableKeySound)) return;
    if (keyPressSound == 0) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"keypress" ofType:@"wav"];
        AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:path],&keyPressSound);
    }
    if (keyPressSound != 0) AudioServicesPlaySystemSound(keyPressSound);
}

-(void)showHighlight
{
    self.highlight=YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self performSelector:@selector(playKeyPressSound) withObject:nil afterDelay:1.0f/4];
    [self performSelector:@selector(showHighlight) withObject:nil afterDelay:1.0f/32];

    if (delegate != nil) {
        [delegate onKeyDown:self];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlight=NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showHighlight) object:nil];

    if (delegate != nil) {
        [delegate onKeyUp:self];
    }
}

@end
