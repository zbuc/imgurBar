#import "StatusItemView.h"
#import "AlertController.h"

#define API_KEY     @""

@interface ApplicationDelegate : NSObject <NSApplicationDelegate, AlertControllerDelegate> {
    IBOutlet NSMenu *menu;
    IBOutlet NSMenuItem *menuItem;

@private;
    AlertController *_alertController;
    StatusItemView *statusItem;
    StatusItemView *_statusItemView;
}

@property (weak, nonatomic, readonly) AlertController *alertController;
@property (weak, nonatomic, readonly) StatusItemView *statusItem;
@property (nonatomic, readonly) StatusItemView *statusItemView;

- (void)toggleAlert;
- (void)flashAlert:(NSString *) text;

@end
