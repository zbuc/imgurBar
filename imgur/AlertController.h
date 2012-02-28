#import "AlertBackgroundView.h"
#import "StatusItemView.h"

@class AlertController;

@protocol AlertControllerDelegate <NSObject>

@optional

- (StatusItemView *)statusItemViewForAlertController:(AlertController *)controller;

@end

#pragma mark -

@interface AlertController : NSWindowController <NSWindowDelegate>
{
    BOOL _hasActiveAlert;
    AlertBackgroundView *_alertBackgroundView;
    id<AlertControllerDelegate> _delegate;
    NSSearchField *_searchField;
    NSTextField *_textField;
}

@property (assign) IBOutlet AlertBackgroundView *alertBackgroundView;
@property (assign) IBOutlet NSTextField *textField;

@property (nonatomic, assign) BOOL hasActiveAlert;
@property (nonatomic, readonly) id<AlertControllerDelegate> delegate;

- (id)initWithDelegate:(id<AlertControllerDelegate>)delegate;

- (void)openAlert;
- (void)closeAlert;
- (NSRect)statusRectForWindow:(NSWindow *)window;

@end
