#import "ApplicationDelegate.h"
#import "ScreenshotController.h"

@implementation ApplicationDelegate

static NSString *kDefaultsScreenshotUploadingKey = @"defaultsScreenshotUploadingKey";

#pragma mark -

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItemView.statusItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    // Install icon into the menu bar
    NSStatusItem *stockStatusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    _statusItemView = [[StatusItemView alloc] initWithStatusItem:stockStatusItem];
    [_statusItemView setImage:[NSImage imageNamed:@"Status"]];
    [_statusItemView setAlternateImage:[NSImage imageNamed:@"Status_invert"]];
    [_statusItemView setMenu:menu];
    
    [self _updateScreenshotMenuItem];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{    
    return NSTerminateNow;
}

#pragma mark - Public accessors

- (NSStatusItem *)statusItem
{
    return self.statusItemView.statusItem;
}

#pragma mark - Screenshots

- (void)screenshotMenuItemAction:(id)sender
{
    BOOL isScreenshotUploadingEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsScreenshotUploadingKey];
    isScreenshotUploadingEnabled = !isScreenshotUploadingEnabled;
    [[NSUserDefaults standardUserDefaults] setBool:isScreenshotUploadingEnabled forKey:kDefaultsScreenshotUploadingKey];
    [self _updateScreenshotMenuItem];
}

- (void)metadataQueryUpdated:(NSNotification*)note
{
    NSArray *items = note.userInfo[NSMetadataQueryUpdateAddedItemsKey];
    
    for (NSMetadataItem *item in items)
    {
        NSString *imagePath = [item valueForKey:NSMetadataItemPathKey];
        NSData *data = [[NSData alloc] initWithContentsOfFile:imagePath];
        
        [[ScreenshotController alloc] uploadImage:data cpmpletitionBlock:^(BOOL success, NSURL *url, NSError *error) {
            if (success)
            {
                // set so you can paste it
                NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
                [pasteBoard declareTypes:@[NSStringPboardType] owner:nil];
                [pasteBoard setString:url.absoluteString forType:NSStringPboardType];
                
                BOOL finished = [[NSWorkspace sharedWorkspace] openURL:url];
                
                if(finished) {
                    NSUserNotification *notification = [[NSUserNotification alloc] init];
                    notification.title = @"Image uploaded!";
                    notification.informativeText = @"Link copied to clipboard";
                    notification.contentImage = [[NSImage alloc] initWithData:data];
                    [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
                    
                    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:&error];
                }
            }
            else
            {
                NSUserNotification *notification = [[NSUserNotification alloc] init];
                notification.title = @"Error image uploading";
                notification.informativeText = error.localizedDescription;
                [[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
            }
        }];
    }
}

- (void)_updateScreenshotMenuItem
{
    BOOL isScreenshotUploadingEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsScreenshotUploadingKey];
    
    if (isScreenshotUploadingEnabled)
    {
        if (!_metadataQuery)
        {
            _metadataQuery = [[NSMetadataQuery alloc] init];
            [_metadataQuery setDelegate:self];
            [_metadataQuery setPredicate:[NSPredicate predicateWithFormat:@"kMDItemIsScreenCapture = 1"]];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(metadataQueryUpdated:) name:NSMetadataQueryDidUpdateNotification object:_metadataQuery];
        
        [_metadataQuery startQuery];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [_metadataQuery stopQuery];
    }
    
    [screenshotsMenuItem setState:isScreenshotUploadingEnabled];
}

@end
