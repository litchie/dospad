/*
    SDL - Simple DirectMedia Layer
    Copyright (C) 1997-2009 Sam Lantinga

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Lesser General Public
    License as published by the Free Software Foundation; either
    version 2.1 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with this library; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

    Sam Lantinga
    slouken@libsdl.org
*/
#include "SDL_config.h"

#include "SDL_video.h"
#include "SDL_mouse.h"
#include "../SDL_sysvideo.h"
#include "../SDL_pixels_c.h"
#include "../../events/SDL_events_c.h"

#include "SDL_uikitvideo.h"
#include "SDL_uikitevents.h"
#include "SDL_uikitwindow.h"
#import "SDL_uikitappdelegate.h"

#import "SDL_uikitopenglview.h"
#import "SDL_renderer_sw.h"

#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>

static int SetupWindowData(_THIS, SDL_Window *window, UIWindow *uiwindow, SDL_bool created) {

    SDL_WindowData *data;
        
    /* Allocate the window data */
    data = (SDL_WindowData *)SDL_malloc(sizeof(*data));
    if (!data) {
        SDL_OutOfMemory();
        return -1;
    }
    data->window = window;
    data->uiwindow = uiwindow;
    data->view = nil;

    /* Fill in the SDL window with the window data */
    {
        window->x = 0;
        window->y = 0;
#ifndef IPHONEOS // Respect user request
        window->w = (int)uiwindow.frame.size.width;
        window->h = (int)uiwindow.frame.size.height;
#endif
    }
    window->driverdata = data;
    
    window->flags &= ~SDL_WINDOW_RESIZABLE;        /* window is NEVER resizeable */
    window->flags |= SDL_WINDOW_OPENGL;            /* window is always OpenGL */
    window->flags |= SDL_WINDOW_FULLSCREEN;        /* window is always fullscreen */
    window->flags |= SDL_WINDOW_SHOWN;            /* only one window on iPod touch, always shown */
    window->flags |= SDL_WINDOW_INPUT_FOCUS;    /* always has input focus */    

#ifndef IPHONEOS
    /* SDL_WINDOW_BORDERLESS controls whether status bar is hidden */
    if (window->flags & SDL_WINDOW_BORDERLESS) {
        [UIApplication sharedApplication].statusBarHidden = YES;
    }
    else {
        [UIApplication sharedApplication].statusBarHidden = NO;
    }
#endif
    return 0;
    
}

int UIKit_CreateWindow(_THIS, SDL_Window *window)
{
    __block volatile int done = 0;
    __block volatile int ret = 1;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *uiwindow = (UIWindow*)[SDLUIKitDelegate sharedAppDelegate].window;

        if (SetupWindowData(_this, window, uiwindow, SDL_TRUE) < 0) {
            assert(0);
            ret = -1;
        }
        
        // This saves the main window in the app delegate so event callbacks can do stuff on the window.
        // This assumes a single window application design and needs to be fixed for multiple windows.
        [SDLUIKitDelegate sharedAppDelegate].sdl_window = window;
        done = 1;
    });
    while (!done)
        usleep(100);
    return ret;
}

void UIKit_DestroyWindow(_THIS, SDL_Window * window) {
    /* don't worry, the delegate will automatically release the window */
    __block volatile int done = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        SDL_WindowData *data = (SDL_WindowData *)window->driverdata;
        if (data) {
            SDL_free( window->driverdata );
        }

        /* this will also destroy the window */
        [SDLUIKitDelegate sharedAppDelegate].sdl_window = NULL;
        done = 1;
    });
    while (!done) usleep(100);
}

#ifdef IPHONEOS
void UIKit_SetWindowSize(_THIS, SDL_Window * window) {
    SDL_WindowData *data = (SDL_WindowData *)window->driverdata;
    __block volatile int done = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (data && data->view) {
            [data->view resize:CGSizeMake(window->w, window->h)];
        }
        done = 1;
    });
    while (!done) usleep(10);
}

void UIKit_SetWindowTitle(_THIS, SDL_Window * window) {
    __block volatile int done = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SDLUIKitDelegate sharedAppDelegate] setWindowTitle:window->title];
        done = 1;
    });
    while (!done) usleep(10);
}
#endif

/* vi: set ts=4 sw=4 expandtab: */
