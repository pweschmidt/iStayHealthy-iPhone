//
//  DosageCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 10/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClinicAddressCell.h"


@interface DosageCell : ClinicAddressCell{
    IBOutlet UISegmentedControl *segmentedControl;
    NSString *unitName;
}
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) NSString *unitName;
- (void)setDelegate:(id)viewControllerDelegate;
- (IBAction)setUnit:(id)sender;
@end

