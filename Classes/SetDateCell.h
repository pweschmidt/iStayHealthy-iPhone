//
//  SetDateCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 05/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetDateCell : UITableViewCell{
    IBOutlet UILabel *title;
    IBOutlet UILabel *value;
    BOOL hasChanged;
}
@property (nonatomic, strong) IBOutlet UILabel *title;
@property (nonatomic, strong) IBOutlet UILabel *value;
@end
