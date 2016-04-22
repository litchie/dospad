//
//  MfiGameControllerHandler.m
//  
//
//  Created by Yoshi Sugawara on 4/1/16.
//
//

#import "MfiGameControllerHandler.h"

@interface MfiGameControllerHandler()
@property (nonatomic,copy) void (^controllerCallbackSetup)(GCController *gameController);
@property (nonatomic,copy) void (^controllerDisconnectedCallback)(void);
@end

@implementation MfiGameControllerHandler

-(void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GCControllerDidConnectNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GCControllerDidDisconnectNotification
                                                  object:nil];
}

- (void)discoverController:(void (^)(GCController *gameController))controllerCallbackSetup disconnectedCallback:(void (^)(void))controllerDisconnectedCallback{
    self.controllerCallbackSetup = controllerCallbackSetup;
    self.controllerDisconnectedCallback = controllerDisconnectedCallback;
    
    if ([self hasControllerConnected]) {
        NSLog(@"Already have a controller connected!");
        [self foundController];
    } else {
        [self startDiscovery];
    }
}

-(void) startDiscovery {
    [GCController startWirelessControllerDiscoveryWithCompletionHandler:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(foundController)
                                                 name:GCControllerDidConnectNotification
                                               object:nil];
}

- (void) stopDiscovery {
    NSLog(@"Stopping controller discovery...");
    [GCController stopWirelessControllerDiscovery];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GCControllerDidConnectNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:GCControllerDidDisconnectNotification
                                                  object:nil];
}

- (void)foundController {
    NSLog(@"Found a controller!");
    if (self.controllerCallbackSetup) {
        self.controllerCallbackSetup([[GCController controllers] firstObject]);
    }
    [self stopDiscovery];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(controllerDisconnected)
                                                 name:GCControllerDidDisconnectNotification
                                               object:nil];
}


- (void)controllerDisconnected {
    
    if (self.controllerDisconnectedCallback){
        self.controllerDisconnectedCallback();
    }
    [self startDiscovery];
}

- (BOOL)hasControllerConnected {
    return [[GCController controllers] count] > 0;
}

-(GCController*) getController {
    // just return the first one for now
    if ( [self hasControllerConnected] ) {
        return [[GCController controllers] firstObject];
    }
    return nil;
}

@end
