//
//  DPThemeSceneView.h
//  iDOS
//
//  Created by Chaoji Li on 2020/10/28.
//

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
