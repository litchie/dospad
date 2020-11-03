//
//  DPGamepadButtonEditController.h
//  iDOS
//
//  Created by Chaoji Li on 2020/11/1.
//

#import <UIKit/UIKit.h>
#import "DPGamepad.h"
#import "DPGamepadConfiguration.h"

NS_ASSUME_NONNULL_BEGIN

@interface DPGamepadButtonEditor: UIViewController
@property DPGamepadButtonIndex buttonIndex;
@property (strong) DPGamepadConfiguration *gamepadConfig;
@property (strong) void (^completionHandler)(void);

@end

NS_ASSUME_NONNULL_END
