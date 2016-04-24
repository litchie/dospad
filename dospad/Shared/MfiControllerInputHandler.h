//
//  MfiControllerInputHandler.h
//  dospad
//
//  Created by Yoshi Sugawara on 4/17/16.
//
//

#import <Foundation/Foundation.h>
#import "KeyMapper.h"

@interface MfiControllerInputHandler : NSObject

@property (nonatomic, strong) KeyMapper *keyMapper;
@property (nonatomic, copy) void (^dismiss)();

-(void) startRemappingControlsForMfiControllerForKey:(SDL_scancode)key;
-(void) setupControllerInputsForController:(GCController*)controller;

@end
