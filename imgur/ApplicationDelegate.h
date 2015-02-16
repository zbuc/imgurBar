#import "StatusItemView.h"

#define CLIENT_ID     @""

@interface ApplicationDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet NSMenu *menu;
    IBOutlet NSMenuItem *menuItem;
}

@property (nonatomic, readonly) StatusItemView *statusItemView;

@end
