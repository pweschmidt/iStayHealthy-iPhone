//
//  MoreResultsCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 23/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoreResultsCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIView *colourCodeView;
@property (nonatomic, weak) IBOutlet UILabel *moreTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *hasMoreLabel;
@end