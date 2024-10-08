/*
 *  Copyright (C) 2017-2024 Chaoji Li
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


#import <UIKit/UIKit.h>

@interface UIViewController(Alert)

- (void)alert:(NSString *)title;
- (void)alert:(NSString *)title message:(NSString*)msg;
- (void)alert:(NSString *)title message:(NSString *)message confirm:(void(^)(BOOL ok))completion;
- (void)alert:(NSString *)title message:(NSString *)message  options:(NSDictionary*)options prompt:(void(^)(NSString* text))completion;
- (void)alert:(NSString*) title message:(NSString*)message
    actions:(NSArray*)actions source:(id)source;
    
@end
