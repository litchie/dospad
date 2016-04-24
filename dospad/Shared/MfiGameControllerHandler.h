//
//  MfiGameControllerHandler.h
//  
//
//  Created by Yoshi Sugawara on 4/1/16.
//
//

#import <Foundation/Foundation.h>
#import <GameController/GameController.h>

@interface MfiGameControllerHandler : NSObject

- (void)discoverController:(void (^)(GCController *gameController))controllerCallbackSetup disconnectedCallback:(void (^)(void))controllerDisconnectedCallback;

@end
