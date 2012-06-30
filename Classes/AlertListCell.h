//
//  AlertListCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 10/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertListCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *text;
@property (nonatomic, weak) IBOutlet UILabel *timeLeftLabel;

@end
