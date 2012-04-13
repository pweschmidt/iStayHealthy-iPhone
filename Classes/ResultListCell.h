//
//  ResultListCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 05/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultListCell : UITableViewCell{
    IBOutlet UILabel *dateLabel;
    IBOutlet UILabel *cd4Title;
    IBOutlet UILabel *cd4PercentTitle;
    IBOutlet UILabel *vlTitle;
    IBOutlet UILabel *cd4Value;
    IBOutlet UILabel *cd4PercentValue;
    IBOutlet UILabel *vlValue;
}
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *cd4Title;
@property (nonatomic, retain) IBOutlet UILabel *cd4PercentTitle;
@property (nonatomic, retain) IBOutlet UILabel *vlTitle;
@property (nonatomic, retain) IBOutlet UILabel *cd4Value;
@property (nonatomic, retain) IBOutlet UILabel *cd4PercentValue;
@property (nonatomic, retain) IBOutlet UILabel *vlValue;
- (void)setCD4:(NSNumber *)value;
- (void)setCD4Percent:(NSNumber *)value;
- (void)setViralLoad:(NSNumber *)value;
@end
