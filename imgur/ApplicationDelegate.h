#import "StatusItemView.h"

#define CLIENT_ID     @""

@interface ApplicationDelegate : NSObject <NSApplicationDelegate, NSMetadataQueryDelegate> {
    IBOutlet NSMenu *menu;
    IBOutlet NSMenuItem *menuItem;
    IBOutlet NSMenuItem *screenshotsMenuItem;
    
    NSMetadataQuery *_metadataQuery;
}

@property (nonatomic, readonly) StatusItemView *statusItemView;

- (IBAction)screenshotMenuItemAction:(id)sender;

@end
