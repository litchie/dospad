//
//  DPMouseManager.m
//  iDOS
//
//  Created by Chaoji Li on 2021/1/6.
//

#import "DPMouseManager.h"
#import <GameController/GameController.h>

static DPMouseManager *_manager;

@interface DPMouseManager ()
{
    
}

@end

@implementation DPMouseManager

+ (DPMouseManager*)defaultManager
{
    if (!_manager) {
        _manager = [[DPMouseManager alloc] init];
        
    }
    return _manager;
}

- (id)init
{
    self = [super init];
    
    if (@available(iOS 14.0, *)) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didConnect:)
                                                     name:GCMouseDidConnectNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDisconnect:)
                                                 name:GCMouseDidDisconnectNotification
                                               object:nil];
        if ([GCMouse current]) {
            [self addMouseHandler:[GCMouse current]];
        }
    }
    return self;
}

- (void)addMouseHandler:(GCMouse*)mouse
API_AVAILABLE(ios(14.0)){
         mouse.mouseInput.mouseMovedHandler = ^(GCMouseInput * _Nonnull mouse, float deltaX, float deltaY) {
            //NSLog(@"mouse move: %f %f\n", deltaX, deltaY);
            if (self.delegate) {
                [self.delegate mouseManager:self moveX:deltaX andY:deltaY];
            }
         };
         mouse.mouseInput.leftButton.pressedChangedHandler = ^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
            //NSLog(@"mouse left button=%d\n", pressed);
            if (self.delegate) {
                [self .delegate mouseManager:self button:0 pressed:pressed];
            }
         };
         mouse.mouseInput.rightButton.pressedChangedHandler = ^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
            //NSLog(@"mouse right button=%d\n", pressed);
            if (self.delegate) {
                [self .delegate mouseManager:self button:1 pressed:pressed];
            }
         };
}

 - (void)didConnect:(NSNotification *)note {
    NSLog(@"mouse connected");
     if (@available(iOS 14.0, *)) {
         GCMouse *mouse = note.object;
         [self addMouseHandler:mouse];

         
     } else {
         // Fallback on earlier versions
     }
 
 }
 
- (void)didDisconnect:(NSNotification *)note
{
    NSLog(@"mouse disconnected");
     if (@available(iOS 14.0, *)) {
         GCMouse *mouse = note.object;
     } else {
         // Fallback on earlier versions
     }
 
}


@end
