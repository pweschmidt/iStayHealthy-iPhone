//
//  AlertListCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 10/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertListCell : UITableViewCell{
    IBOutlet UILabel *title;
    IBOutlet UILabel *text;
}
@property (nonatomic, retain) IBOutlet UILabel *title;
@property (nonatomic, retain) IBOutlet UILabel *text;

@end
