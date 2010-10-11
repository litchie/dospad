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

#import "CommandListView.h"
#include "cmd_history.h"

@implementation CommandListView
@synthesize selectedCommand, selected;

- (id)initWithParent:(UIView *)parent
{
    if (self = [super initWithParent:parent]) {
        cmdList=[NSMutableArray arrayWithCapacity:cmd_count];
        [cmdList retain];
        cmd_entry*p;
        lineCount=17; /* Align with image file */
        int n = 0;
        for (p = cmd_list; p && n < lineCount; p=p->next) {
            [cmdList addObject:[NSString stringWithUTF8String:p->cmd]];
            n++;
        }
        UIImage *img=[UIImage imageNamed:@"dpnote.png"];
        
        imgRect = CGRectMake( (self.bounds.size.width-img.size.width)/2, 20,
                             img.size.width,img.size.height);
        listRect=CGRectMake(103+imgRect.origin.x, 92+imgRect.origin.y,320, 448);

    }
    return self;
}

- (void)dismissWithSelectedCommand
{
    selected=YES;
    [super dismiss];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch=[touches anyObject];
    CGPoint pt = [touch locationInView:self];
    if (CGRectContainsPoint(listRect, pt)) {
        float lineHeight = (listRect.size.height/lineCount);
        int index = (pt.y - listRect.origin.y)/lineHeight;
        if (index >= 0 && index < [cmdList count]) {
            self.selectedCommand = [cmdList objectAtIndex:index];
            if (btnEnter==nil) {
                btnEnter=[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                [self addSubview:btnEnter];
                [btnEnter addTarget:self action:@selector(dismissWithSelectedCommand) forControlEvents:UIControlEventTouchUpInside];
            }
            btnEnter.center=CGPointMake(listRect.origin.x + listRect.size.width + btnEnter.frame.size.width/2,
                                        listRect.origin.y + lineHeight * index + btnEnter.frame.size.height/2);
        }
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    UIImage *img=[UIImage imageNamed:@"dpnote.png"];
    [img drawInRect:imgRect];
    for (int i = 0; i < [cmdList count]; i++) {
        NSString *s = [cmdList objectAtIndex:i];
        float lineHeight = (listRect.size.height/lineCount);
        CGRect rc = CGRectMake(listRect.origin.x, listRect.origin.y+lineHeight*i, 
                               listRect.size.width, lineHeight);
        [s drawInRect:rc withFont:[UIFont fontWithName:@"AmericanTypewriter" size:lineHeight*0.6]];
    }
}

- (void)dealloc {
    self.selectedCommand=nil;
    [cmdList release];
    [super dealloc];
}


@end
