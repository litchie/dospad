//
//  UINavigationController+AutoRotate.m
//  dospad
//
//  Created by Chaoji Li on 9/10/14.
//
//

#import "UINavigationController-AutoRotate.h"

@implementation UINavigationController(AutoRotate)

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return [self.topViewController supportedInterfaceOrientations];
}

@end
