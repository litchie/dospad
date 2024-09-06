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


#import "DPThumbView.h"

@implementation DPThumbView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	self.userInteractionEnabled = YES;
	self.textColor = [UIColor lightGrayColor];
	self.textAlignment = NSTextAlignmentCenter;
	self.backgroundColor = [UIColor clearColor];
	UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
	[self addGestureRecognizer:tap];
	UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
	[self addGestureRecognizer:pan];
	return self;
}

- (void)updatePosition
{
	UIView *parent = self.superview;
	UIView *gp = parent.superview;
	CGFloat minY, maxY, x;
	
	// If the parent view controlled by us is now at the right half
	// of screen, then we should try to stick it to the right edge
	BOOL shouldStickToRight = (parent.frame.size.width < gp.bounds.size.width*0.8 &&
	    parent.center.x > gp.bounds.size.width/2);
	
	if (_showThumbOnly) {
		minY = - self.frame.origin.y;
		x = shouldStickToRight ? gp.bounds.size.width - CGRectGetMaxX(self.frame) : - self.frame.origin.x;
	} else {
		minY = 0;
		x = shouldStickToRight ?  gp.bounds.size.width - parent.frame.size.width : 0;
	}
	maxY = gp.bounds.size.height - parent.frame.size.height;
	CGRect frame = parent.frame;
	frame.origin.x = x;
	if (frame.origin.y < minY + 40)
		frame.origin.y = minY;
	if (frame.origin.y > maxY - 40)
		frame.origin.y = maxY;
	[UIView animateWithDuration:0.2 animations:^{
		parent.frame = frame;
	}];
}

- (void)onTap:(UITapGestureRecognizer*)tap
{
	if (tap.state == UIGestureRecognizerStateEnded) {
		_showThumbOnly = !_showThumbOnly;
		[self updatePosition];
		UIView *parent = self.superview;
		for (UIView *v in parent.subviews) {
			if (v == self) continue;
			v.alpha = _showThumbOnly ? 0 : 1;
		}
	}
}

- (void)onPan:(UIPanGestureRecognizer*)pan
{
    if (pan.state == UIGestureRecognizerStateBegan) {
        //[self.superview bringSubviewToFront:pan.view];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
    	UIView *v = self.superview;
        CGPoint pt = [pan translationInView:v.superview];
        CGPoint old = v.center;
        old.x += pt.x;
        old.y += pt.y;
        v.center = old;
        [pan setTranslation:CGPointZero inView:v.superview];
        [_delegate thumbViewDidMove:self];
    } else if (pan.state == UIGestureRecognizerStateEnded) {
    	[self updatePosition];
		[_delegate thumbViewDidStop:self];
    }
}

@end
