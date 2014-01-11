#import "StatusItemView.h"
#import "ScreenshotController.h"

@implementation StatusItemView

@synthesize statusItem = _statusItem;
@synthesize image = _image;
@synthesize alternateImage = _alternateImage;
@synthesize isHighlighted = _isHighlighted;
@synthesize action = _action;
@synthesize target = _target;

#pragma mark -


- (void)setMenu:(NSMenu *)menu {
    [menu setDelegate:self];
    [super setMenu:menu];
}


- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //register for drags
        NSArray *dragTypes = [NSArray arrayWithObjects:NSURLPboardType, NSFileContentsPboardType, NSFilenamesPboardType, nil];
        [self registerForDraggedTypes:dragTypes];
    }
    
    return self;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem
{
    CGFloat itemWidth = [statusItem length];
    CGFloat itemHeight = [[NSStatusBar systemStatusBar] thickness];
    NSRect itemRect = NSMakeRect(0.0, 0.0, itemWidth, itemHeight);
    self = [self initWithFrame:itemRect];
    
    if (self != nil)
    {
        _statusItem = [statusItem retain];
        _statusItem.view = self;
    }
    return self;
}

- (void)dealloc
{
    [_statusItem release];
    [_image release];
    [_alternateImage release];
    
    [super dealloc];
}

#pragma mark -

- (void)drawRect:(NSRect)dirtyRect
{
	[self.statusItem drawStatusBarBackgroundInRect:dirtyRect withHighlight:self.isHighlighted];
    
    NSImage *icon = self.isHighlighted ? self.alternateImage : self.image;
    NSSize iconSize = [icon size];
    NSRect bounds = self.bounds;
    CGFloat iconX = roundf((NSWidth(bounds) - iconSize.width) / 2);
    CGFloat iconY = roundf((NSHeight(bounds) - iconSize.height) / 2);
    NSPoint iconPoint = NSMakePoint(iconX, iconY);
    [icon drawAtPoint:iconPoint fromRect:bounds operation:NSCompositeSourceOver fraction:1.0];
}

#pragma mark -
#pragma mark Mouse tracking

- (void)mouseDown:(NSEvent *)theEvent
{
    NSMenu *menu = [super menu];
    [_statusItem popUpStatusItemMenu:menu];
    [NSApp sendAction:self.action to:self.target from:self];
}


- (void)menuWillOpen:(NSMenu *)menu {
    [self setHighlighted:YES];
    [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)menu {
    [self setHighlighted:NO];
    [self setNeedsDisplay:YES];
}



#pragma mark -
#pragma mark Accessors

- (void)setHighlighted:(BOOL)newFlag
{
    if (_isHighlighted == newFlag) return;
    _isHighlighted = newFlag;
    [self setNeedsDisplay:YES];
}

#pragma mark -

- (void)setImage:(NSImage *)newImage
{
    [newImage retain];
    [_image release];
    _image = newImage;
    [self setNeedsDisplay:YES];
}

- (void)setAlternateImage:(NSImage *)newImage
{
    [newImage retain];
    [_alternateImage release];
    _alternateImage = newImage;
    if (self.isHighlighted)
        [self setNeedsDisplay:YES];
}


//we want to copy the files
- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    if ([[sender draggingPasteboard] availableTypeFromArray:[NSArray arrayWithObject:NSFilenamesPboardType]]) {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

//perform the drag and log the files that are dropped
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender 
{
    NSPasteboard *pb = [sender draggingPasteboard];
    if([[pb pasteboardItems] count] != 1){
        return NO;
    }
    
    if([NSBitmapImageRep canInitWithPasteboard:pb]){
        NSURL *url = [NSURL URLFromPasteboard:pb];
        NSData *data = [[[NSData alloc] initWithContentsOfURL:url] autorelease];
        [[[ScreenshotController alloc] autorelease] uploadImage:data];
       
        return YES;
    }   
    
    return NO;
}

#pragma mark -

- (NSRect)globalRect
{
    NSRect frame = [self frame];
    frame.origin = [self.window convertBaseToScreen:frame.origin];
    return frame;
}

@end
