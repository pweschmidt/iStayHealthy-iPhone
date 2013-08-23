//
//  BaseTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/08/2013.
//
//

#import "BaseViewController.h"
#import "BaseViewControllerDelegate.h"
#import "ContainerViewControllerDelegate.h"
@class CustomTableView;

@interface BaseTableViewController : UITableViewController <BaseViewControllerDelegate, ContainerViewControllerDelegate>
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
- (void)configureIPadMenus;
- (void)settingsMenu;
- (void)addMenu;
@end
