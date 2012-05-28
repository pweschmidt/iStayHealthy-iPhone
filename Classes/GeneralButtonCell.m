//
//  GeneralButtonCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 06/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GeneralButtonCell.h"

@implementation GeneralButtonCell
@synthesize medButton, procButton, clinicButton;
@synthesize generalButtonCellDelegate=_generalButtonCellDelegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setDelegate:(id)viewControllerDelegate{
    self.generalButtonCellDelegate = viewControllerDelegate;
}

- (IBAction)selectMed:(id)sender{
    [self.generalButtonCellDelegate loadOtherMedicationDetailViewController];
}

- (IBAction)selectProcedure:(id)sender{
    [self.generalButtonCellDelegate loadProcedureAddViewController];
}

- (IBAction)selectClinic:(id)sender{
    [self.generalButtonCellDelegate loadClinicAddViewController];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
