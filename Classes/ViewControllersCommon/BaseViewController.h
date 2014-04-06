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
@class CustomToolbar;

@interface BaseViewController : UIViewController <PWESPopoverDelegate, UIPopoverControllerDelegate>
@property (nonatomic, strong) UIBarButtonItem *hamburgerMenuBarButton;
@property (nonatomic, strong) UIBarButtonItem *addMenuBarButton;
@property (nonatomic, strong) CustomToolbar *iPadToolbar;
@property (nonatomic, strong) UIPopoverController *customPopoverController;
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
@end
