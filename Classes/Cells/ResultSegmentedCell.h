//
//  ResultSegmentedCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 05/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultValueCell.h"

@interface ResultSegmentedCell : ResultValueCell
@property (nonatomic, weak) IBOutlet UILabel *query;
@property (nonatomic, weak) IBOutlet UISwitch *switchControl;    
- (void)setDelegate:(id)viewControllerDelegate;
- (IBAction)isUndetectable:(id)sender;
@end

