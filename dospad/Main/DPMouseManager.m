/*
 *  Copyright (C) 2021-2024 Chaoji Li
 *
 *  DOSPAD is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

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
