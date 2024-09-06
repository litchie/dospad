/*
 *  Copyright (C) 2010-2024 Chaoji Li
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
#import "DPSettings.h"
#import "SoundEffect.h"

@implementation KeyView

@synthesize code,title,altTitle,highlight;
@synthesize textColor;
@synthesize bkgColor,edgeColor,bottomColor,highlightColor;
@synthesize delegate;

-(void)setHighlight:(BOOL)b
{
    highlight=b;
    [self setNeedsDisplay];
}

-(void)setAltTitle:(NSString *)t
{
    altTitle = t;
    [self setNeedsDisplay];
}
-(void)setTitle:(NSString *)t
{
    title = t;
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        self.textColor = [UIColor blackColor];
        self.bkgColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();

	UIBezierPath* path = [UIBezierPath
		bezierPathWithRoundedRect:rect
		byRoundingCorners:UIRectCornerAllCorners
		cornerRadii:CGSizeMake(3, 3)];
	[path addClip];

	if (!self.highlight) {
		[bkgColor set];
		CGContextFillRect(ctx, rect);
		[bottomColor set];
		CGContextFillRect(ctx, CGRectMake(0, rect.size.height*0.9, rect.size.width, rect.size.height*0.1));
	} else {
		[highlightColor set];
		CGContextFillRect(ctx, rect);
	}

    UIEdgeInsets padding = UIEdgeInsetsMake(0, 0, rect.size.height*0.1, 0);
	CGRect labelRect = UIEdgeInsetsInsetRect(rect, padding);

	BOOL hasAltTitle = altTitle != nil && altTitle.length > 0;
	
    NSString *text;
    CGFloat fontSize;
    
    // If we have an alternative title,
    // show it on top of the title.
    if (hasAltTitle) {
    	text = [NSString stringWithFormat:@"%@\n%@",
    		altTitle, title];
		fontSize = labelRect.size.height * 0.4;
	} else {
		text = title;
		fontSize = labelRect.size.height * 0.6;
	}
    UIFont *font = [UIFont systemFontOfSize:fontSize];

	NSDictionary *attrs = @{
		NSFontAttributeName: [UIFont systemFontOfSize:MIN(12,labelRect.size.height/2)],
		NSForegroundColorAttributeName: textColor
	};
	CGSize size = [text sizeWithAttributes:attrs];
	CGRect textRect = CGRectMake(
		labelRect.origin.x + (labelRect.size.width - size.width)/2,
		labelRect.origin.y + (labelRect.size.height - size.height)/2,
		size.width, size.height);
	[text drawInRect:textRect withAttributes:attrs];
}


-(void)playKeyPressSound
{
	if ([DPSettings shared].keyPressSound) {
		[SoundEffect play:@"keypress.wav"];
	}
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
