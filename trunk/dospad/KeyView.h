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

@protocol KeyDelegate

-(void)onKeyDown:(KeyView*)k;
-(void)onKeyUp:(KeyView*)k;

@end

@interface KeyView : UIView {
    int code;
    UIColor *textColor;
    UIColor *bkgColor;
    UIColor *edgeColor;
    NSString *title;
    BOOL highlight;
    id<KeyDelegate> delegate;
    float padding;
}

@property float padding;
@property BOOL highlight;
@property (nonatomic,retain)NSString *title;
@property int code;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *bkgColor,*edgeColor;
@property (nonatomic,assign) id<KeyDelegate> delegate;

@end
