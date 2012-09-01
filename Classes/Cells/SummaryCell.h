//
//  SummaryCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 11/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *result;
@property (nonatomic, strong) IBOutlet UIImageView *summaryImageView;
@property (nonatomic, strong) IBOutlet UILabel *change;

@end
