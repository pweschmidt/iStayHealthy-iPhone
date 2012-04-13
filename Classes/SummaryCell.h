//
//  SummaryCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 11/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SummaryCell : UITableViewCell{
    IBOutlet UILabel *title;
    IBOutlet UILabel *result;
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *change;
}
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *result;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *change;

@end
