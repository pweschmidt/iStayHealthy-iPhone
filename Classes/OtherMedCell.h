//
//  OtherMedCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 06/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OtherMedCell : UITableViewCell{
    IBOutlet UILabel *dateLabel;
    IBOutlet UILabel *nameLabel;
    IBOutlet UILabel *drugLabel;
}
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *drugLabel;
@end
