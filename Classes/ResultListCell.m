//
//  ResultListCell.m
//  iStayHealthy
//
//  Created by peterschmidt on 05/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ResultListCell.h"
#import "GeneralSettings.h"
@implementation ResultListCell
@synthesize dateLabel, cd4Title, cd4PercentTitle, vlTitle, cd4Value, cd4PercentValue, vlValue;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setCD4:(NSNumber *)value{
    int cd4 = [value intValue];
    self.cd4Value.text = [NSString stringWithFormat:@"%d",cd4];
	if (350 <= cd4) {
		self.cd4Value.textColor = DARK_GREEN;
	}
	else if (200 <= cd4 && 350 > cd4){
		self.cd4Value.textColor = DARK_YELLOW;
	}
	else if( 200 > cd4 && 0 < cd4){
		self.cd4Value.textColor = DARK_RED;
	}
    else{
        self.cd4Value.text = NSLocalizedString(@"n/a",nil);
        self.cd4Value.textColor = [UIColor lightGrayColor];
    }
    
}

- (void)setCD4Percent:(NSNumber *)value{
    float cd4Percent = [value floatValue];
    self.cd4PercentValue.text = [NSString stringWithFormat:@"%2.1f%%",cd4Percent];
    if (21.0 <= cd4Percent) {
        self.cd4PercentValue.textColor = DARK_GREEN;
    }
    else if (15.0 <= cd4Percent && 21.0 > cd4Percent) {
        self.cd4PercentValue.textColor = DARK_YELLOW;
    }
    else if(15.0 > cd4Percent && 0.0 < cd4Percent){
        self.cd4PercentValue.textColor = DARK_RED;
    }
    else{
        self.cd4PercentValue.text = NSLocalizedString(@"n/a",nil);
        self.cd4PercentValue.textColor = [UIColor lightGrayColor];
    }
    
    
}

- (void)setViralLoad:(NSNumber *)value{
    int vl = [value intValue];
	if (10 > vl && 0 <= vl) {
        self.vlValue.text = NSLocalizedString(@"undetectable",nil);
		self.vlValue.textColor = DARK_GREEN;
	}
    else if(0 > vl){
        self.vlValue.text = NSLocalizedString(@"n/a",nil);
        self.vlValue.textColor = [UIColor lightGrayColor];
    }
	else {
		self.vlValue.text = [NSString stringWithFormat:@"%d",vl];
		if (100000 <= vl && 500000 > vl) {
			self.vlValue.textColor = DARK_YELLOW;
		}
		if (500000 <= vl) {
			self.vlValue.textColor = DARK_RED;
		}
	}
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
