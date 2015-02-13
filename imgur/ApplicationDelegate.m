#import "ApplicationDelegate.h"

@implementation ApplicationDelegate

@synthesize statusItemView = _statusItemView;

#pragma mark -

- (void)dealloc
{
    [[NSStatusBar systemStatusBar] removeStatusItem:self.statusItemView.statusItem];
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

#pragma mark - Public accessors

- (NSStatusItem *)statusItem
{
    return self.statusItemView.statusItem;
}

@end
