//
//  BaseViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/08/2013.
//
//

#import <UIKit/UIKit.h>
#import "UINavigationBar-Button.h"
#import "PWESPopoverDelegate.h"
#import "PWESToolbarDelegate.h"
#import <MessageUI/MessageUI.h>
@class CustomToolbar;

@interface BaseViewController : UIViewController <PWESPopoverDelegate, PWESToolbarDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) UIBarButtonItem *hamburgerMenuBarButton;
@property (nonatomic, strong) UIBarButtonItem *addMenuBarButton;
@property (nonatomic, strong) CustomToolbar *customToolbar;
@property (nonatomic, strong) UIPopoverController *customPopoverController;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, assign) BOOL hasNavHeader;
- (id)initAsPopoverController;
- (void)disableRightBarButtons;
- (void)hamburgerMenu;
- (void)addButtonPressed:(id)sender;
- (UIImage *)blankImage;
- (void)setTitleViewWithTitle:(NSString *)titleString;
- (void)goToPOZSite;
- (void)registerObservers;
- (void)unregisterObservers;
- (void)reloadSQLData:(NSNotification *)notification;
- (void)startAnimation:(NSNotification *)notification;
- (void)stopAnimation:(NSNotification *)notification;
- (void)handleError:(NSNotification *)notification;
- (void)handleStoreChanged:(NSNotification *)notification;

- (void)animateViewWithText:(NSString *)text;
- (void)stopAnimateView;

@end
