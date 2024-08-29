//
//  ThumbnailProvider.m
//  iDOSThumbnail
//
//  Created by Chaoji Li on 2020/9/28.
//

#import "ThumbnailProvider.h"
#import <UIKit/UIKit.h>

@implementation ThumbnailProvider

- (void)provideThumbnailForFileRequest:(QLFileThumbnailRequest *)request
	completionHandler:(void (^)(QLThumbnailReply * _Nullable, NSError * _Nullable))handler
{
    NSFileManager *fm = [NSFileManager defaultManager];
	NSFileCoordinator *fc = [[NSFileCoordinator alloc] init];
	[fc coordinateReadingItemAtURL:request.fileURL
		options:NSFileCoordinatorReadingWithoutChanges
		error:nil
		byAccessor:^(NSURL * _Nonnull newURL) {
			// If any of the images exists, simply use that image.
            for (NSString *name in @[@"icon.png", @"cover.png"]) {
                NSURL *url = [newURL URLByAppendingPathComponent:name];
                if ([fm fileExistsAtPath:url.path])
                {
                    handler([QLThumbnailReply replyWithImageFileURL:url], nil);
                    return;
                }
            }
			
			// If there is screenshot.png, draw it over the screen of app icon
			NSURL *url = [newURL URLByAppendingPathComponent:@"scrnshot.png"];
			if ([fm fileExistsAtPath:url.path])
			{
				[fc coordinateReadingItemAtURL:url
					options:NSFileCoordinatorReadingWithoutChanges
					error:nil
					byAccessor:^(NSURL * _Nonnull url) {
						CGSize size = request.maximumSize;
						handler([QLThumbnailReply replyWithContextSize:size
							currentContextDrawingBlock:^BOOL
							{
								// Draw the thumbnail here.
								CGRect rect = CGRectZero;
								rect.size = size;

								CGContextRef ctx = UIGraphicsGetCurrentContext();
								
								CGContextSetFillColorWithColor(ctx, [UIColor grayColor].CGColor);
								CGContextFillRect(ctx, rect);
								
								UIImage *x = [UIImage imageNamed:@"screenshot_bg"];
								[x drawInRect:rect];
								
								UIImage *img = [UIImage imageWithContentsOfFile:url.path];
								CGFloat w = rect.size.width;
								CGFloat h = rect.size.height;
								CGRect screenRect = CGRectMake(0.107*w, 0.164*h,0.781*w,0.586*h);
								[img drawInRect:screenRect];
								
								return YES;
							}], nil);
					}];
				return;
			}
			
			url = [NSBundle.mainBundle URLForResource:@"appicon-512" withExtension:@"png"];
			handler([QLThumbnailReply replyWithImageFileURL:url], nil);

		}];

}

@end
