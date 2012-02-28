#import "StatusItemView.h"
#import "AlertController.h"

@interface ApplicationDelegate : NSObject <NSApplicationDelegate, AlertControllerDelegate> {
    IBOutlet NSMenu *menu;
    IBOutlet NSMenuItem *menuItem;

@private;
    AlertController *_alertController;
    StatusItemView *statusItem;
    StatusItemView *_statusItemView;
}

@property (nonatomic, readonly) AlertController *alertController;
@property (nonatomic, readonly) StatusItemView *statusItem;
@property (nonatomic, readonly) StatusItemView *statusItemView;

- (void)toggleAlert;
- (void)flashAlert:(NSString *) text;

@end
