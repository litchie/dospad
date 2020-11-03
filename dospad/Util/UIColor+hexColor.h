//
//  UIColor+hexColor.h
//  Created by Chaoji Li on 2020/8/8.
//  Copyright © 2020 Chaoji Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (hexColor)

+ (UIColor*)hexColor:(NSString*)hexString;
- (NSString*)hexString;
@end

NS_ASSUME_NONNULL_END
