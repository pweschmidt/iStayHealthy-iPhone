//
//  ProcedureCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 06/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProcedureCell : UITableViewCell{
    IBOutlet UILabel *dateLabel;
    IBOutlet UILabel *procLabel;
    IBOutlet UILabel *illnessLabel;
}
@property (nonatomic, retain) IBOutlet UILabel *dateLabel;
@property (nonatomic, retain) IBOutlet UILabel *procLabel;
@property (nonatomic, retain) IBOutlet UILabel *illnessLabel;
@end
