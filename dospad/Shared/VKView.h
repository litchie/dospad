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

#import <UIKit/UIKit.h>


@interface TPos : UITextPosition
{
    int line;
    int column;
}

@property (nonatomic, assign) int line; // line number of the text position. 0-based
@property (nonatomic, assign) int column; // first char is 0, the end of line column.
                                          // a chinese char is counted as one column
                                          // although it is twice as wide
@property (weak, nonatomic, readonly) NSString *description;

- (NSComparisonResult)compareTo:(TPos *)another;
+ (TPos*)positionWithLine:(int)line column:(int)column;

@end

@interface TRange : UITextRange
{
    TPos* __weak start;
    TPos* __weak end;
}
@property (weak, nonatomic, readonly) TPos* start;
@property (weak, nonatomic, readonly) TPos* end;
@property (nonatomic, readonly, getter=isEmpty) BOOL empty;     //  Whether the range is zero-length.
@property (weak, nonatomic, readonly) NSString *description;

+ (TRange*)rangeWithStart:(TPos*)start end:(TPos*)end;
@end


@interface VKView : UIView<UIKeyInput, UITextInput, UITextInputTraits> {
    NSString *text;
    TRange *selectedTextRange;
    BOOL useNativeKeyboard;
}

@property (nonatomic, assign) BOOL useNativeKeyboard;
@property (nonatomic, assign) BOOL active;

@end
