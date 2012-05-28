//
//  ResultSegmentedCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 05/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultValueCell.h"

@interface ResultSegmentedCell : ResultValueCell{
    IBOutlet UILabel *query;
    IBOutlet UISwitch *switchControl;    
}
@property (nonatomic, strong) IBOutlet UILabel *query;
@property (nonatomic, strong) IBOutlet UISwitch *switchControl;    
- (void)setDelegate:(id)viewControllerDelegate;
- (IBAction)isUndetectable:(id)sender;
@end

