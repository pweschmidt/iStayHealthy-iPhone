//
//  BaseViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/08/2013.
//
//

#import <UIKit/UIKit.h>
#import "UINavigationBar-Button.h"
#import "PWESToolbarDelegate.h"
#import <MessageUI/MessageUI.h>

@protocol PWESContentMenuHandler;
@class CustomToolbar;

@interface BaseViewController : UIViewController <PWESToolbarDelegate, UIPopoverPresentationControllerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) UIBarButtonItem *hamburgerMenuBarButton;
@property (nonatomic, strong) UIBarButtonItem *addMenuBarButton;
@property (nonatomic, strong) CustomToolbar *customToolbar;

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIPopoverPresentationController *popoverController;
@property (nonatomic, strong) UILabel *activityLabel;
@property (nonatomic, assign) BOOL hasNavHeader;
@property (nonatomic, weak) id<PWESContentMenuHandler> menuHandler;
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
