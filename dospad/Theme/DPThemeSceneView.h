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


#import "DPThemeScene.h"
#import "DPTheme.h"

@class DPThemeSceneView;


NS_ASSUME_NONNULL_BEGIN

@interface DPButton: UIButton
@property (nonatomic, strong) NSString * _Nullable name;
@end

@protocol DPThemeSceneViewDelegate
- (BOOL)sceneView:(DPThemeSceneView*)sceneView didButtonPress:(UIButton*)button;
- (UIView*)sceneView:(DPThemeSceneView*)sceneView createComponent:(CGRect)frame
attributes:(NSDictionary*)attrs;

@end

@interface DPThemeSceneView : UIImageView
@property (nonatomic, strong) DPThemeScene *scene;
@property (nonatomic, strong) id<DPThemeSceneViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame scene:(DPThemeScene*)scene;
- (UIView*)createComponent:(CGRect)frame attributes:(NSDictionary*)attrs;
- (BOOL)didButtonPress:(DPButton*)button;

@end

NS_ASSUME_NONNULL_END
