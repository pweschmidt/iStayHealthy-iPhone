//
//  ClinicAddressCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 09/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ClinicAddressCell.h"

@implementation ClinicAddressCell

- (void)setDelegate:(id)viewControllerDelegate
{
    self.clinicAddressCellDelegate = viewControllerDelegate;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.textColor = [UIColor blackColor];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.clinicAddressCellDelegate setValueString:textField.text withTag:self.tag];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range
                                                                  withString:string];
    if ([self.clinicAddressCellDelegate
         respondsToSelector:@selector(setValueString:withTag:)])
    {
        [self.clinicAddressCellDelegate setValueString:newString withTag:self.tag];
    }
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
