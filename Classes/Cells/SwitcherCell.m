//
//  SwitcherCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 11/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SwitcherCell.h"

@implementation SwitcherCell
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
    self.switcherCellDelegate = viewControllerDelegate;    
}

- (IBAction)valueChanged:(id)sender
{
    [self.switcherCellDelegate setMissed:self.switcher.isOn];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
