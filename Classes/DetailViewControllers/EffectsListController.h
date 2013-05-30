//
//  EffectsListController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 30/05/2013.
//
//

#import <UIKit/UIKit.h>
#import "SideEffectsDetailTableViewController.h"
@interface EffectsListController : UITableViewController
@property (nonatomic, weak) id<EffectsSelector> selectorDelegate;
@end
