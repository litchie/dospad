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

@class KeyView;

@protocol KeyDelegate<NSObject>

-(void)onKeyDown:(KeyView*)k;
-(void)onKeyUp:(KeyView*)k;

@optional
-(void)onKeyFunction:(KeyView*)k;

@end

@interface KeyView : UIView {
    int code;
    UIColor *textColor;
    UIColor *bkgColor;
    UIColor *bottomColor,*highlightColor;
    UIColor *edgeColor;
    NSString *title,*altTitle;
    BOOL highlight;
    id<KeyDelegate> __weak delegate;
    UIEdgeInsets padding;
	BOOL newStyle;
}

@property UIEdgeInsets padding;
@property (nonatomic) BOOL highlight;
@property (nonatomic,strong)NSString *title,*altTitle;
@property int code;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *bkgColor,*edgeColor,*bottomColor,*highlightColor;
@property (nonatomic,weak) id<KeyDelegate> delegate;
@property (nonatomic) BOOL newStyle;
@property (nonatomic, strong) NSString *mappedKey;

@end
