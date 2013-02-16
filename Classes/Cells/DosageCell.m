//
//  DosageCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 10/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DosageCell.h"

@implementation DosageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)setDelegate:(id)viewControllerDelegate
{
    [super setDelegate:viewControllerDelegate];
}

- (IBAction)setUnit:(id)sender
{
    switch (self.segmentedControl.selectedSegmentIndex)
    {
        case 0:
            [super.clinicAddressCellDelegate setUnitString:@"[g]"];
            break;
        case 1:
            [super.clinicAddressCellDelegate setUnitString:@"[mg]"];
            break;
        case 2:
            [super.clinicAddressCellDelegate setUnitString:@"[ml]"];
            break;
        case 3:
            [super.clinicAddressCellDelegate setUnitString:@""];
            break;
    }
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
