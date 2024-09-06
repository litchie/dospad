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

//
//  Used for embedding in a floating view so that it can be dragged
//  around and toggle the visibility of the floating view.
//
//  Created by Chaoji Li on 2020/11/10.
//

#import <UIKit/UIKit.h>

@class DPThumbView;

NS_ASSUME_NONNULL_BEGIN

@protocol DPThumbViewDelegate

- (void)thumbViewDidMove:(DPThumbView*)thumbView;
- (void)thumbViewDidStop:(DPThumbView*)thumbView;

@end

@interface DPThumbView : UILabel
@property BOOL showThumbOnly;
@property (nonatomic, weak) id<DPThumbViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
