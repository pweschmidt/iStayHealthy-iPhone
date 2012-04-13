//
//  ClinicAddressCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 09/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ClinicAddressCell.h"

@implementation ClinicAddressCell
@synthesize title, valueField, _delegate;

- (void)setDelegate:(id)viewControllerDelegate{
    self._delegate = viewControllerDelegate;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    textField.textColor = [UIColor blackColor];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self._delegate setValueString:textField.text withTag:self.tag];
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
