//
//  MedSelectionCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 11/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MedSelectionCell : UITableViewCell{
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *name;
    IBOutlet UILabel *type;
    IBOutlet UILabel *content;
}
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *name;
@property (nonatomic, retain) IBOutlet UILabel *type;
@property (nonatomic, retain) IBOutlet UILabel *content;

@end
