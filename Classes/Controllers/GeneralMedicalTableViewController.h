//
//  GeneralMedicalTableViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 08/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasicViewController.h"

@interface GeneralMedicalTableViewController : BasicViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end
