//
//  DPKeyboardManager.h
//  iDOS
//
//  Created by Chaoji Li on 2021/1/6.
//

#import <Foundation/Foundation.h>

@class DPKeyboardManager;

NS_ASSUME_NONNULL_BEGIN

@protocol DPKeyboardManagerDelegate

- (void)keyboardManager:(DPKeyboardManager*)manager scancode:(int)scancode  pressed:(BOOL)pressed;

@end


@interface DPKeyboardManager : NSObject
@property (nonatomic, strong) id<DPKeyboardManagerDelegate> delegate;
+(DPKeyboardManager*)defaultManager;
- (void)willResignActive;
@end

NS_ASSUME_NONNULL_END
