//
//  GeneralButtonCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 06/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GeneralButtonCell.h"

@implementation GeneralButtonCell
@synthesize medButton, procButton, clinicButton, _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setDelegate:(id)viewControllerDelegate{
    self._delegate = viewControllerDelegate;
}

- (IBAction)selectMed:(id)sender{
    [self._delegate loadOtherMedicationDetailViewController];
}

- (IBAction)selectProcedure:(id)sender{
    [self._delegate loadProcedureAddViewController];
}

- (IBAction)selectClinic:(id)sender{
    [self._delegate loadClinicAddViewController];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)dealloc{
    [super dealloc];
}

@end
