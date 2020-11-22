//
// KeyboardSpy.h
//
// Listening on external keyboard input.
// SDL has an implementation but that's tightly coupled with the
// screen view, and it's not a great solution for iDOS.
//
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KeyboardSpy : UIView<UIKeyInput>
@property (nonatomic, assign) BOOL active;
@end

NS_ASSUME_NONNULL_END
