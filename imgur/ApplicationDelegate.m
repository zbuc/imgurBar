#import "ApplicationDelegate.h"

#define ALERT_TIME 2.75

void *kContextActiveAlert = &kContextActiveAlert;

@implementation ApplicationDelegate

@synthesize statusItemView = _statusItemView;

#pragma mark -

- (void)dealloc
{    
    [_alertController removeObserver:self forKeyPath:@"hasActiveAlert"];
    [_alertController release];
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItemView.statusItem];
    [_statusItemView release];

    [super dealloc];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kContextActiveAlert)
    {
        //self.menubarController.hasActiveIcon = self.AlertController.hasActiveAlert;
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
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
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{    
    return NSTerminateNow;
}

- (void)toggleAlert
{
    self.alertController.hasActiveAlert = (self.alertController.hasActiveAlert ? NO : YES);
}

- (void)flashAlert:(NSString *)text
{
    [[[[self alertController] textField] cell] setTitle:text];
    [self toggleAlert];

    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * ALERT_TIME), dispatch_get_main_queue(), ^{
        [self toggleAlert];
    });
}

#pragma mark - Public accessors

- (NSStatusItem *)statusItem
{
    return self.statusItemView.statusItem;
}


- (AlertController *)alertController
{
    if (_alertController == nil)
    {
        _alertController = [[AlertController alloc] initWithDelegate:self];
        [_alertController addObserver:self forKeyPath:@"hasActiveAlert" options:NSKeyValueObservingOptionInitial context:kContextActiveAlert];
    }
    return _alertController;
}

#pragma mark - AlertControllerDelegate

- (StatusItemView *)statusItemViewForAlertController:(AlertController *)controller
{
    return self.statusItemView;
}


@end
