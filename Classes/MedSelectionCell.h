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
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *name;
@property (nonatomic, strong) IBOutlet UILabel *type;
@property (nonatomic, strong) IBOutlet UILabel *content;

@end
