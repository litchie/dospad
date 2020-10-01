//
//  UIViewController+AlertViewController.h
//  TeX Writer
//
//  Created by Chaoji Li on 05/11/2017.
//  Copyright © 2017 Chaoji Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController(Alert)

- (void)alert:(NSString *)title;
- (void)alert:(NSString *)title message:(NSString*)msg;
- (void)alert:(NSString *)title message:(NSString *)message confirm:(void(^)(BOOL ok))completion;
- (void)alert:(NSString *)title message:(NSString *)message  options:(NSDictionary*)options prompt:(void(^)(NSString* text))completion;
- (void)alert:(NSString*) title message:(NSString*)message
    actions:(NSArray*)actions source:(id)source;
    
@end
