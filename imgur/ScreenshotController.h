#import <Foundation/Foundation.h>

@interface ScreenshotController : NSObject
{
    
}

- (void)uploadImage:(NSData *)image cpmpletitionBlock:(void (^)(BOOL success, NSURL *url, NSError *error))block;

@end
