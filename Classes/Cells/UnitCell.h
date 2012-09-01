//
//  UnitCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 23/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnitCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *unitTitle;
@property (nonatomic, weak) IBOutlet UISegmentedControl *segControl;
@end
