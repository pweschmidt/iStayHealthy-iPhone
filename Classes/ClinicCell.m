//
//  ClinicCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 06/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ClinicCell.h"

@implementation ClinicCell
@synthesize clinicCell;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
@end
