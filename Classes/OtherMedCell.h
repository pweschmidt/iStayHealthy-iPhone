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
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;
@property (nonatomic, strong) IBOutlet UILabel *drugLabel;
@end
