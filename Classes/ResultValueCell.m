//
//  ResultValueCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 05/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ResultValueCell.h"

@implementation ResultValueCell
@synthesize title,valueField;
@synthesize _delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
#ifdef APPDEBUG
    NSLog(@"ResultValueCell initWithStyle");
#endif
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}
- (void)setDelegate:(id)viewControllerDelegate{
    self._delegate = viewControllerDelegate;
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

@end
