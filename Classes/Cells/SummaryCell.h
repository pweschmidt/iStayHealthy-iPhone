//
//  SummaryCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 11/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

enum  {
    upward = 0,
    downward = 1,
    neutral = 2
    }shapeIndicator;

@interface SummaryCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *result;
@property (nonatomic, strong) IBOutlet UILabel *change;
@property (nonatomic, strong) IBOutlet UIView *changeIndicatorView;
-(IBAction)indicator:(id)sender hasShape:(NSInteger)shapeIndex isGood:(BOOL)isGood;
@end
