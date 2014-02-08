//
//  BaseViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/08/2013.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewControllerDelegate.h"
#import "ContainerViewControllerDelegate.h"
#import "UINavigationBar-Button.h"
@class CustomTableView;

@interface BaseViewController : UIViewController <BaseViewControllerDelegate, ContainerViewControllerDelegate>
{
    CGRect onScreenLeft;
    CGRect offScreenLeft;
    CGRect onScreenRight;
    CGRect offScreenRight;
    CGRect mainFrameCenter;
    CGRect mainFrameToRight;
    CGRect mainFrameToLeft;
}
@property (nonatomic, strong) CustomTableView * iPadHamburgerMenuView;
@property (nonatomic, strong) CustomTableView * iPadAddMenuView;
@property (nonatomic, strong) UIBarButtonItem * hamburgerMenuBarButton;
@property (nonatomic, strong) UIBarButtonItem * addMenuBarButton;
@property (nonatomic, strong) UIToolbar *iPadToolbar;
- (void)disableRightBarButtons;
- (void)configureIPadMenus;
- (void)settingsMenu;
- (void)addMenu;
- (void)addButtonPressed:(id)sender;
- (UIImage *)blankImage;
- (void)setTitleViewWithTitle:(NSString *)titleString;
- (void)goToPOZSite;

@end
