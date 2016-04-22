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

#import "VKView.h"
#include "keys.h"
#import "Common.h"

extern int SDL_SendKeyboardKey(int index, Uint8 state, SDL_scancode scancode);


@implementation TPos
@synthesize line;
@synthesize column;

- (id)initWithLine:(int)ln Column:(int)col
{
    line = ln;
    column = col;
    return self;
}

+ (TPos*)positionWithLine:(int)line column:(int)column
{
    TPos *tp = [[TPos alloc] initWithLine:line Column:column];
    return tp;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"(%d,%d)", line, column];
}

- (NSComparisonResult)compareTo:(TPos *)another
{
    TPos *tp = another;
    if (another == nil)
    {
        return NSOrderedAscending;
    }
    if (line < tp.line || (line == tp.line && column < tp.column))
        return NSOrderedAscending;
    else if (line == tp.line && column == tp.column)
        return NSOrderedSame;
    else
        return NSOrderedDescending;
}

@end

@implementation TRange
@synthesize start;
@synthesize end;
@synthesize empty;

- (id)initWithPos:(TPos*)beg end:(TPos*)endPos
{
    if (start!=nil) ;
    if (end !=nil) ;
    start = beg; 
    end = endPos; 
    return self;
}

+ (TRange*)rangeWithStart:(TPos *)start end:(TPos *)end
{
    TRange *range = [[TRange alloc] initWithPos:start end:end];
    return range;
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"(start=%@, end=%@)",
            start.description, end.description];
}

- (BOOL)isEmpty
{
    if (start == nil || end == nil) return YES;
    return start.line==end.line && start.column == end.column;
}


@end


@implementation VKView

@synthesize useNativeKeyboard;
@synthesize active;

- (void)setActive:(BOOL)b
{
    if (b == [self isFirstResponder]) return;
    DEBUGLOG(@"active %d", b);
    if (b)
    {
        [self becomeFirstResponder];
    }
    else
    {
        [self resignFirstResponder];
    }
}

- (BOOL)active
{
    return [self isFirstResponder];
}


- (void)setUseNativeKeyboard:(BOOL)b
{
    if (useNativeKeyboard == b)
    {
        return;
    }
    
    useNativeKeyboard = b;
    if ([self isFirstResponder]) {
        [self resignFirstResponder];
        [self becomeFirstResponder];
    }
}


- (UIView*)inputView
{
    if (useNativeKeyboard) return nil;
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    inputView.backgroundColor=[UIColor clearColor];
    inputView.alpha=0;
    return inputView;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.backgroundColor=[UIColor blueColor];
        selectedTextRange = [TRange rangeWithStart:[TPos positionWithLine:0 column:0]
                                               end:[TPos positionWithLine:0 column:0]];
    }
    return self;
}

/*
- (void)drawRect:(CGRect)rect {
    // Drawing code
    if (text != nil)
    {
        [text drawInRect:rect withFont:[UIFont systemFontOfSize:20]];
    }
}
 */


- (void)sendKeyEvent:(int)keyCode
{
    SDL_SendKeyboardKey(0, SDL_PRESSED, keyCode);
    [NSThread sleepForTimeInterval:0.05]; // Very very important
    SDL_SendKeyboardKey(0, SDL_RELEASED, keyCode);
}

// We need to declare this for it to work
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self isFirstResponder] == NO) 
    {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        //DEBUGLOG(@"tap at %f %f ", location.x, location.y);
        [self becomeFirstResponder];
    }
    else 
    {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)deleteBackward
{
    [self sendKeyEvent:SDL_SCANCODE_BACKSPACE];
}

- (BOOL)hasText
{
    return [text length]>0;
}
- (void)insertText:(NSString *)_text
{
    text = _text;
    unichar c = [_text characterAtIndex:0];
    
    if ([_text isEqualToString:@"\n"]) [self sendKeyEvent:SDL_SCANCODE_RETURN];
    
    if (c < 128)
    {
        int shift=0;
        int code=get_scancode_for_char(c, &shift);
        if (shift)
        {
            SDL_SendKeyboardKey(0, SDL_PRESSED, SDL_SCANCODE_LSHIFT);
        }
        if (code > 0) [self sendKeyEvent:code];
        if (shift)
        {
            SDL_SendKeyboardKey(0, SDL_RELEASED, SDL_SCANCODE_LSHIFT);
        }
    }
    [self setNeedsDisplay];
}


//==============================================================================
// UITextInput Protocol
//==============================================================================
#pragma mark UITextInput implementation

//@synthesize inputDelegate;
@synthesize selectionAffinity;

//------------------------------------------------------------------------------
// An affiliated view that provides a coordinate system for all geometric values 
// in this protocol. (read-only)
//
// Discussion
//   The view that both draws the text and provides a coordinate system for all 
//   geometric values in this protocol. (This is typically an instance of the 
//   UITextInput-adopting class.) If this property is unimplemented,
//   the first view in the responder chain is selected.
- (UIView*)textInputView
{
    //DEBUGLOG(@"returning textInputView");
    return self;
}

//------------------------------------------------------------------------------
// An input tokenizer that provides information about the granularity of text 
// units. (readonly)
//
// Discussion
//   Standard units of granularity include characters, words, lines, and 
//   paragraphs. In most cases, you may lazily create and assign an instance of 
//   a subclass of UITextInputStringTokenizer for this purpose. If you require 
//   different behavior than this system-provided tokenizer, you can create a 
//   custom tokenizer that adopts the UITextInputTokenizer protocol.
//------------------------------------------------------------------------------
- (id<UITextInputTokenizer>)tokenizer
{
    return nil;
}

//------------------------------------------------------------------------------
// A dictionary of attributes that describes how marked text should be drawn. 
// (copy)
//
// Discussion
//   Marked text requires a unique visual treatment when displayed to users. 
//   See “Style Dictionary Keys” for descriptions of the valid keys and values 
//   for this dictionary.
//------------------------------------------------------------------------------
- (NSDictionary *)markedTextStyle
{
    DEBUGLOG(@"markedTextStyle not implemented");
    return nil;
}

- (void)setMarkedTextStyle:(NSDictionary *)style
{
    DEBUGLOG(@"setMarkedTextStyle not implemented");
}

//------------------------------------------------------------------------------
// The range of text that is currently marked in a document. (readonly)
//
// Discussion
//  If there is no marked text, the value of the property is nil. Marked text is 
//  provisionally inserted text that requires user confirmation; it occurs in 
//  multistage text input. The current selection, which can be a caret or an 
//  extended range, always occurs within the marked text.
//------------------------------------------------------------------------------
- (UITextRange*)markedTextRange
{
    //DEBUGLOG(@"markedTextRange");
    return nil;
}

//------------------------------------------------------------------------------
// Insert the provided text and marks it to indicate that it is part of an 
// active input session.
//
// Parameters
//   markedText - The text to be marked.
//   selectedRange - A range within markedText that indicates the current 
//                   selection. This range is always relative to markedText.
// Discussion
//   Setting marked text either replaces the existing marked text or, if none is
//   present, inserts it in place of the current selection.
//------------------------------------------------------------------------------
- (void)setMarkedText:(NSString *)markedText selectedRange:(NSRange)selectedRange
{
    //DEBUGLOG(@"setMarkedText");
}


- (UITextRange*)selectedTextRange
{
    //DEBUGLOG(@"selectedTextRange");
    return selectedTextRange;
}

- (void)setSelectedTextRange:(UITextRange *)range
{
   // DEBUGLOG(@"setSelectedTextRange:%@=>%@", 
   //       [selectedTextRange description],
   //      [(TRange*)range description]);
    TRange *trNew = (TRange*)range;
    if (trNew.start.line < selectedTextRange.start.line) 
    {
        [self sendKeyEvent:SDL_SCANCODE_UP];
    }
    else if (trNew.start.line > selectedTextRange.start.line) 
    {
        [self sendKeyEvent:SDL_SCANCODE_DOWN];
    }
    else if (trNew.start.column > selectedTextRange.start.column) 
    {
        [self sendKeyEvent:SDL_SCANCODE_RIGHT];        
    }
    else
    {
        [self sendKeyEvent:SDL_SCANCODE_LEFT];
    }

    selectedTextRange = (TRange*)range;
}

- (UITextPosition*)beginningOfDocument
{
    //DEBUGLOG(@"beginningOfDocument");
    return [TPos positionWithLine:INT_MIN column:0];
}


- (UITextPosition*)endOfDocument
{
    //DEBUGLOG(@"endOfDocument");
    // FIXME: perhaps we need to use the end of last line
    return [TPos positionWithLine:INT_MAX column:0];
}




- (UITextWritingDirection)baseWritingDirectionForPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction
{
    DEBUGLOG(@"baseWritingDirectionForPosition");
    return UITextWritingDirectionLeftToRight;
}

- (CGRect)caretRectForPosition:(UITextPosition *)position
{
    DEBUGLOG(@"caretRectForPosition");
    return CGRectZero;
}


//------------------------------------------------------------------------------
// Return the character offset of a position in a document’s text that falls 
// within a given range.
// 
// This method is used when there is no one-to-one correspondence between 
// UITextPosition objects and characters. For example, one chinese character 
// occupies two position.
//
// Parameters
//   position - An object that identifies a location in a document’s text.
//   range - An object that specifies a range of text in a document.
// 
// Return Value
//   The number of characters in a document's text that occur between position 
//   and the beginning of range.
//------------------------------------------------------------------------------
- (NSInteger)characterOffsetOfPosition:(UITextPosition *)position
                           withinRange:(UITextRange *)range
{
    DEBUGLOG(@"characterOffsetOfPosition");
    return 0;
}


//------------------------------------------------------------------------------
// Return the character or range of characters that is at a given point in a document.
//
// Parameters
//   point - A point in the view that is drawing a document’s text.
// Return Value
//   An object representing a range that encloses a character (or characters) at point.
//------------------------------------------------------------------------------
- (UITextRange *)characterRangeAtPoint:(CGPoint)point
{
    DEBUGLOG(@"characterRangeAtPoint:(%f,%f)",point.x, point.y);
    return nil;
}

//------------------------------------------------------------------------------
// Return a text range from a given text position to its farthest extent in a 
// certain direction of layout. 
//
// Parameters
//   position - A text-position object that identifies a location in a document.
//   direction - A constant that indicates a direction of layout (right, left, 
//               up, down).
// Return Value
//   A text-range object that represents the distance from position to the 
// farthest extent in direction.
//------------------------------------------------------------------------------
- (UITextRange *)characterRangeByExtendingPosition:(UITextPosition *)position 
                                       inDirection:(UITextLayoutDirection)direction
{
    DEBUGLOG(@"characterRangeByExtendingPosition");
    return nil;
}

//------------------------------------------------------------------------------
// Return the position in a document that is closest to a specified point.
//
// Parameters
//   point - A point in the view that is drawing a document’s text.
// Return Value
//   An object locating a position in a document that is closest to point.
//------------------------------------------------------------------------------
- (UITextPosition *)closestPositionToPoint:(CGPoint)point
{
    DEBUGLOG(@"closestPositionToPoint:(%f,%f)", point.x, point.y);
    return nil;
}

//------------------------------------------------------------------------------
// Return the position in a document that is closest to a specified point in a 
// given range. 
// 
// Parameters
//   point - A point in the view that is drawing a document’s text.
//   range - An object representing a range in a document’s text.
// Return Value
//   An object representing the character position in range that is closest to 
//   point.
//------------------------------------------------------------------------------
- (UITextPosition *)closestPositionToPoint:(CGPoint)point 
                               withinRange:(UITextRange *)range
{
    DEBUGLOG(@"closestPositionToPoint");
    return nil;
}

//------------------------------------------------------------------------------
// Return how one text position compares to another text position. (required)
//
// Parameters
//   position - A custom object that represents a location within a document.
//   other - A custom object that represents another location within a document.
// Return Value
//   A value that indicates whether the two text positions are identical or 
//   whether one is before the other.
//------------------------------------------------------------------------------
- (NSComparisonResult)comparePosition:(UITextPosition *)position 
                           toPosition:(UITextPosition *)other
{
//    DEBUGLOG(@"comparePosition:%@ toPosition:%@", 
//          [(TPos*)position description], [(TPos*)other description]);
    return [(TPos*)position compareTo:(TPos*)other];
}

//------------------------------------------------------------------------------
// Return the first rectangle that encloses a range of text in a document.
//
// Parameters
//   range - An object that represents a range of text in a document.
// Return Value
//   The first rectangle in a range of text. You might use this rectangle to 
//   draw a correction rectangle. The “first” in the name refers the rectangle 
//   enclosing the first line when the range encompasses multiple lines of text.
//------------------------------------------------------------------------------
- (CGRect)firstRectForRange:(UITextRange *)range
{
    DEBUGLOG(@"firstRectForRange");
    return CGRectZero;
}

//------------------------------------------------------------------------------
// Return the number of visible characters between one text position and another 
// text position.
//
// Parameters
//   fromPosition - A custom object that represents a location within a 
//                  document.
//   toPosition - A custom object that represents another location within 
//                document.
// Return Value
//   The number of visible characters between fromPosition and toPosition.
//------------------------------------------------------------------------------
- (NSInteger)offsetFromPosition:(UITextPosition *)fromPosition 
                     toPosition:(UITextPosition *)toPosition
{
    DEBUGLOG(@"offsetFromPosition");
    return 0;
}

//------------------------------------------------------------------------------
// Returns the text position at a given offset in a specified direction from 
// another text position.
//
// Parameters
//   position - A custom UITextPosition object that represents a location in a document.
//   direction - A UITextLayoutDirection constant that represents the direction of the offset from position. 
//   offset - A character offset from position.
// Return nil if the computed text position is less than 0 or greater than the length of the backing string.
//------------------------------------------------------------------------------
- (UITextPosition *)positionFromPosition:(UITextPosition *)position 
                             inDirection:(UITextLayoutDirection)direction 
                                  offset:(NSInteger)offset
{
//    DEBUGLOG(@"positionFromPosition %@ inDirection %d offset %d", 
//          [(TPos*)position description], direction, offset);
    TPos *tp = (TPos*)position;
    switch (direction)
    {
        case UITextLayoutDirectionUp:
            return [TPos positionWithLine:tp.line-offset column:tp.column];
        case UITextLayoutDirectionDown:
            return [TPos positionWithLine:tp.line+offset column:tp.column];
        case UITextLayoutDirectionLeft:
            return [TPos positionWithLine:tp.line column:tp.column-offset];
        case UITextLayoutDirectionRight:
            return [TPos positionWithLine:tp.line column:tp.column+offset];
    }    
    return nil;
}

//------------------------------------------------------------------------------
// Returns the text position at a given offset from another text position. 
//
// Parameters
//   position - A custom UITextPosition object that represents a location in a 
//              document.
//   offset - A character offset from position. It can be a positive or negative
//            value.
// Return Value
//   A custom UITextPosition object that represents the location in a document 
//   that is at the specified offset from position. 
//   Return nil if the computed text position is less than 0 or greater than the
//   length of the backing string.
//------------------------------------------------------------------------------
- (UITextPosition *)positionFromPosition:(UITextPosition *)position 
                                  offset:(NSInteger)offset
{
    //DEBUGLOG(@"positionFromPosition offset");
    return nil;
}

//------------------------------------------------------------------------------
// Return the position within a range of a document’s text that corresponds to 
// the character offset from the start of that range.
//
// Parameters
//   range - An object that specifies a range of text in a document.
//   offset - A character offset from the start of range.
// Return Value
//   An object that represents a position in a document’s visible text.
//------------------------------------------------------------------------------
- (UITextPosition *)positionWithinRange:(UITextRange *)range atCharacterOffset:(NSInteger)offset
{
    DEBUGLOG(@"positionWithinRange atCharacterOffset");
    return nil;
}

//------------------------------------------------------------------------------
// Return the text position that is at the farthest extent in a given layout 
// direction within a range of text.
//
// Parameters
//   range - A text-range object that demarcates a range of text in a document.
//   direction - A constant that indicates a direction of layout (right, left, 
//               up, down).
// Return Value
//   A text-position object that identifies a location in the visible text.
//------------------------------------------------------------------------------
- (UITextPosition *)positionWithinRange:(UITextRange *)range farthestInDirection:(UITextLayoutDirection)direction
{
    DEBUGLOG(@"positionWithinRange:farthestInDirection not implemented");
    return nil;
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
- (void)replaceRange:(UITextRange *)range withText:(NSString *)text
{
    DEBUGLOG(@"replaceRange not implemented");
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
- (void)setBaseWritingDirection:(UITextWritingDirection)writingDirection forRange:(UITextRange *)range
{
    DEBUGLOG(@"setBaseWritingDirection not implemented");
    
}

//------------------------------------------------------------------------------
// textInRange:
//
// Return the text in the specified range. (required)
//
// Parameters
//   range - A range of text in a document.
//
// Return Value
//   A substring of a document that falls within the specified range.
//------------------------------------------------------------------------------
- (NSString *)textInRange:(UITextRange *)range
{
    DEBUGLOG(@"textInRange");
    return nil;
}

//------------------------------------------------------------------------------
// Return the range between two text positions.
//
// Parameters
//   fromPosition - An object that represents a location in a document.
//   toPosition - An object that represents another location in a document.
// Return Value
//   An object that represents the range between fromPosition and toPosition.
//------------------------------------------------------------------------------
- (UITextRange *)textRangeFromPosition:(UITextPosition *)fromPosition 
                            toPosition:(UITextPosition *)toPosition
{
    //DEBUGLOG(@"textRangeFromPosition:%@ toPosition:%@",
//          [(TPos*)fromPosition description],
//          [(TPos*)toPosition description]);
    return [TRange rangeWithStart:(TPos*)fromPosition end:(TPos*)toPosition];
}

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
- (NSDictionary *)textStylingAtPosition:(UITextPosition *)position inDirection:(UITextStorageDirection)direction
{
    DEBUGLOG(@"textStylingAtPosition not implemented");
    return nil;
}

//------------------------------------------------------------------------------
// Unmark the currently marked text. (required)
// 
// Discussion
//   After this method is called, the value of markedTextRange is nil.
//------------------------------------------------------------------------------
- (void)unmarkText
{
    DEBUGLOG(@"unmarkText");
}

//==============================================================================
// UITextInputTraits Protocol
//==============================================================================
#pragma mark UITextInputTraits Protocol

- ( UITextAutocorrectionType)autocorrectionType
{
    return UITextAutocorrectionTypeDefault;
}

- (UIKeyboardAppearance)keyboardAppearance
{ 
    return UIKeyboardAppearanceAlert; 
}

- (UIReturnKeyType)returnKeyType;                          
{ 
    return UIReturnKeyDefault; 
} 

- (UITextAutocapitalizationType)autocapitalizationType
{
    return UITextAutocapitalizationTypeNone;
}

- (UIKeyboardType)keyboardType
{
    return UIKeyboardTypeASCIICapable;
}

- (BOOL)enablesReturnKeyAutomatically;
{
    return NO;
}

- (BOOL)isSecureTextEntry
{
    return NO;
}


@end
