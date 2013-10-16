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
#import "UIFont+Standard.h"
#import "UINavigationBar-Button.h"
@class CustomTableView;

@interface BaseTableViewController : UITableViewController <BaseViewControllerDelegate, ContainerViewControllerDelegate, UIAlertViewDelegate>
{
    CGRect onScreenLeft;
    CGRect offScreenLeft;
    CGRect onScreenRight;
    CGRect offScreenRight;
    CGRect mainFrameCenter;
    CGRect mainFrameToRight;
    CGRect mainFrameToLeft;
}
@property (nonatomic, strong) CustomTableView *iPadHamburgerMenuView;
@property (nonatomic, strong) CustomTableView *iPadAddMenuView;
@property (nonatomic, strong) UIBarButtonItem *hamburgerMenuBarButton;
@property (nonatomic, strong) UIBarButtonItem *addMenuBarButton;
@property (nonatomic, strong) NSManagedObject *markedObject;
@property (nonatomic, strong) NSIndexPath     *markedIndexPath;
- (void)disableRightBarButtons;
- (void)configureIPadMenus;
- (void)settingsMenu;
- (void)addMenu;
- (void)addButtonPressed:(id)sender;
- (void)showDeleteAlertView;
- (void)removeSQLEntry;
- (void)setTitleViewWithTitle:(NSString *)titleString;
- (UIImage *)blankImage;
- (void)goToPOZSite;

@end
