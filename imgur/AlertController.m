#import "AlertController.h"
#import "AlertBackgroundView.h"
#import "StatusItemView.h"

#define OPEN_DURATION .15
#define CLOSE_DURATION .1

#define ALERT_HEIGHT 57
#define ALERT_WIDTH 331
#define MENU_ANIMATION_DURATION .1

#define MIDLINE -17

#pragma mark -

@implementation AlertController

@synthesize alertBackgroundView = _alertBackgroundView;
@synthesize delegate = _delegate;
@synthesize textField = _textField;

#pragma mark -

- (id)initWithDelegate:(id<AlertControllerDelegate>)delegate
{
    self = [super initWithWindowNibName:@"Alert"];
    if (self != nil)
    {
        _delegate = delegate;
    }
    return self;
}


#pragma mark -

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Make a fully skinned Alert
    NSPanel *Alert = (id)[self window];
    [Alert setAcceptsMouseMovedEvents:YES];
    [Alert setStyleMask:[Alert styleMask] ^ NSTitledWindowMask];
    [Alert setLevel:NSPopUpMenuWindowLevel];
    [Alert setOpaque:NO];
    [Alert setBackgroundColor:[NSColor clearColor]];
    
    // Resize Alert
    NSRect AlertRect = [[self window] frame];
    AlertRect.size.height = ALERT_HEIGHT;
    [[self window] setFrame:AlertRect display:NO];
}

#pragma mark - Public accessors

- (BOOL)hasActiveAlert
{
    return _hasActiveAlert;
}

- (void)setHasActiveAlert:(BOOL)flag
{
    if (_hasActiveAlert != flag)
    {
        _hasActiveAlert = flag;
        
        if (_hasActiveAlert)
        {
            [self openAlert];
        }
        else
        {
            [self closeAlert];
        }
    }
}

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification
{
    self.hasActiveAlert = NO;
}

- (void)windowDidResignKey:(NSNotification *)notification;
{
    if ([[self window] isVisible])
    {
        self.hasActiveAlert = NO;
    }
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSWindow *Alert = [self window];
    NSRect statusRect = [self statusRectForWindow:Alert];
    NSRect AlertRect = [Alert frame];
    
    CGFloat statusX = roundf(NSMidX(statusRect));
    CGFloat AlertX = statusX - NSMinX(AlertRect);
    
    self.alertBackgroundView.arrowX = AlertX;
    
    NSRect textRect = [self.textField frame];
    textRect.size.width = NSWidth([self.alertBackgroundView bounds]);
    textRect.origin.x = -MIDLINE;
    textRect.size.height = NSHeight([self.alertBackgroundView bounds]) - ARROW_HEIGHT;
    textRect.origin.y = MIDLINE;
    
    if (NSIsEmptyRect(textRect))
    {
        [self.textField setHidden:YES];
    }
    else
    {
        [self.textField setFrame:textRect];
        [self.textField setHidden:NO];
    }
}

#pragma mark - Keyboard

- (void)cancelOperation:(id)sender
{
    self.hasActiveAlert = NO;
}

#pragma mark - Public methods

- (NSRect)statusRectForWindow:(NSWindow *)window
{
    NSRect screenRect = [[window screen] frame];
    NSRect statusRect = NSZeroRect;
    
    StatusItemView *statusItemView = nil;
    if ([self.delegate respondsToSelector:@selector(statusItemViewForAlertController:)])
    {
        statusItemView = [self.delegate statusItemViewForAlertController:self];
    }

    if (statusItemView)
    {
        statusRect = statusItemView.globalRect;
        statusRect.origin.y = NSMinY(statusRect) - NSHeight(statusRect);
    }
    else
    {
        statusRect.size = NSMakeSize(NSSquareStatusItemLength, [[NSStatusBar systemStatusBar] thickness]);
        statusRect.origin.x = roundf((NSWidth(screenRect) - NSWidth(statusRect)) / 2);
        statusRect.origin.y = NSHeight(screenRect) - NSHeight(statusRect) * 2;
    }
    return statusRect;
}

- (void)openAlert
{
    NSWindow *Alert = [self window];
    
    NSRect screenRect = [[Alert screen] frame];
    NSRect statusRect = [self statusRectForWindow:Alert];
    
    NSRect AlertRect = [Alert frame];
    AlertRect.size.width = ALERT_WIDTH;
    AlertRect.origin.x = roundf(NSMidX(statusRect) - NSWidth(AlertRect) / 2);
    AlertRect.origin.y = NSMaxY(statusRect) - NSHeight(AlertRect);
    
    if (NSMaxX(AlertRect) > (NSMaxX(screenRect) - ARROW_HEIGHT))
        AlertRect.origin.x -= NSMaxX(AlertRect) - (NSMaxX(screenRect) - ARROW_HEIGHT);
    
    [NSApp activateIgnoringOtherApps:NO];
    [Alert setAlphaValue:0];
    [Alert setFrame:statusRect display:YES];
    [Alert makeKeyAndOrderFront:nil];
    
    NSTimeInterval openDuration = OPEN_DURATION;
    /*
    NSEvent *currentEvent = [NSApp currentEvent];
    if ([currentEvent type] == NSLeftMouseDown)
    {
        NSUInteger clearFlags = ([currentEvent modifierFlags] & NSDeviceIndependentModifierFlagsMask);
        BOOL shiftPressed = (clearFlags == NSShiftKeyMask);
        BOOL shiftOptionPressed = (clearFlags == (NSShiftKeyMask | NSAlternateKeyMask));
        if (shiftPressed || shiftOptionPressed)
        {
            openDuration *= 10;
            
            if (shiftOptionPressed)
                NSLog(@"Icon is at %@\n\tMenu is on screen %@\n\tWill be animated to %@",
                      NSStringFromRect(statusRect), NSStringFromRect(screenRect), NSStringFromRect(AlertRect));
        }
    }*/
    
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:openDuration];
    [[Alert animator] setFrame:AlertRect display:YES];
    [[Alert animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
}

- (void)closeAlert
{
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:CLOSE_DURATION];
    [[[self window] animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
    
    dispatch_after(dispatch_walltime(NULL, NSEC_PER_SEC * CLOSE_DURATION * 2), dispatch_get_main_queue(), ^{
        
        [self close];
    });
}

@end
