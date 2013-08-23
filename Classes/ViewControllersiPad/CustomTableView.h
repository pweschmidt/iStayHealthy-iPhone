//
//  CustomTableView.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/08/2013.
//
//

#import <UIKit/UIKit.h>
#import "ContainerViewControllerDelegate.h"
#import "Constants.h"

@interface CustomTableView : UITableView <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, weak) id<ContainerViewControllerDelegate> containerDelegate;
@property (nonatomic, strong, readonly) NSArray * menuItems;
+ (CustomTableView *)customTableViewWithMenus:(NSArray *)menus
                                        frame:(CGRect)frame
                                         type:(MenuType)type;
@end
