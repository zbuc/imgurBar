//#import "NSData-Base64Extensions.h"
#import "ScreenshotController.h"
#import "ApplicationDelegate.h"

@implementation ScreenshotController

- (void)uploadImage:(NSData *)image
{
    NSString *urlString = @"https://api.imgur.com/3/upload.json";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    [request setValue:[NSString stringWithFormat:@"Client-ID %@", CLIENT_ID] forHTTPHeaderField:@"Authorization"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];

    // file
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Disposition: attachment; name=\"image\"; filename=\".tiff\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[NSData dataWithData:image]];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // text parameter
    [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"key\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // close form
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // set request body
    [request setHTTPBody:body];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        NSDictionary *decodedResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        
        if ([decodedResponse[@"success"] boolValue] == YES)
        {
            NSString *imgurUrlString = [[decodedResponse valueForKey:@"data"] valueForKey:@"link"];
            NSURL *imgurUrl = [NSURL URLWithString:imgurUrlString];
            
            // set so you can paste it
            NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
            [pasteBoard declareTypes:@[NSStringPboardType] owner:nil];
            [pasteBoard setString:imgurUrlString forType:NSStringPboardType];
            
            BOOL finished = [[NSWorkspace sharedWorkspace] openURL:imgurUrl];
            
            if(finished){
                NSUserNotification *notification = [[NSUserNotification alloc] init];
                notification.title = @"Image uploaded!";
                notification.informativeText = @"copied to clipboard";
                notification.contentImage = [[NSImage alloc] initWithData:image];
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                NSLog(@"Notification delivered");
            }
        }
        else
        {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            notification.title = @"Error image uploading";
            notification.informativeText = decodedResponse[@"data"][@"error"];
            [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
        }
    }];
}


@end
