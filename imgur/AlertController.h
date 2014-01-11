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
    AlertBackgroundView *__weak _alertBackgroundView;
    id<AlertControllerDelegate> __unsafe_unretained _delegate;
    NSSearchField *_searchField;
    NSTextField *__weak _textField;
}

@property (weak) IBOutlet AlertBackgroundView *alertBackgroundView;
@property (weak) IBOutlet NSTextField *textField;

@property (nonatomic, assign) BOOL hasActiveAlert;
@property (unsafe_unretained, nonatomic, readonly) id<AlertControllerDelegate> delegate;

- (id)initWithDelegate:(id<AlertControllerDelegate>)delegate;

- (void)openAlert;
- (void)closeAlert;
- (NSRect)statusRectForWindow:(NSWindow *)window;

@end
