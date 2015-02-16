#import <Cocoa/Cocoa.h>

@interface StatusItemView : NSView <NSMenuDelegate> {
@private
    NSImage *_image;
    NSImage *_alternateImage;
    NSStatusItem *_statusItem;
    BOOL _isHighlighted;
    SEL _action;
    id __unsafe_unretained _target;
}

- (id)initWithStatusItem:(NSStatusItem *)statusItem;

@property (nonatomic, readonly) NSStatusItem *statusItem;
@property (nonatomic, strong) NSImage *image;
@property (nonatomic, strong) NSImage *alternateImage;
@property (nonatomic, setter = setHighlighted:) BOOL isHighlighted;
@property (nonatomic) SEL action;
@property (nonatomic, unsafe_unretained) id target;

@end
