#import "StatusItemView.h"

#define CLIENT_ID     @""

@interface ApplicationDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSMenu *menu;
    IBOutlet NSMenuItem *menuItem;

@private;
    StatusItemView *statusItem;
    StatusItemView *_statusItemView;
}

@property (weak, nonatomic, readonly) StatusItemView *statusItem;
@property (nonatomic, readonly) StatusItemView *statusItemView;

@end
