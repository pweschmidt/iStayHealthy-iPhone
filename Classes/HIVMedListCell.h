//
//  HIVMedListCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 11/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HIVMedListCell : UITableViewCell{
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *date;
    IBOutlet UILabel *name;
    IBOutlet UILabel *content;
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *date;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *content;

@end
