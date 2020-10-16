//
//  MfiGamepadMapperView.h
//  iDOS
//
//  Created by Chaoji Li on 2020/10/13.
//

#import <UIKit/UIKit.h>
#import "MfiGamepadConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@class MfiGamepadMapperView;

@protocol MfiGamepadMapperDelegate
- (void)mfiGamepadMapperDidClose:(MfiGamepadMapperView*)mapper;
@end

@interface MfiGamepadMapperView : UIView
@property (strong) id<MfiGamepadMapperDelegate> delegate;
- (id)initWithFrame:(CGRect)frame configuration:(MfiGamepadConfiguration*)config;
- (void)onKey:(int)code pressed:(BOOL)pressed;
- (void)onButton:(MfiGamepadButtonIndex)buttonIndex pressed:(BOOL)pressed atPlayer:(NSInteger)playerIndex;
- (void)onJoystickMoveWithX:(float)x y:(float)y atPlayer:(NSInteger)playerIndex;
- (void)update;
@end

NS_ASSUME_NONNULL_END
