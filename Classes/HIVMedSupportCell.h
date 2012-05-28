//
//  HIVMedSupportCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 11/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HIVMedSupportCell : UITableViewCell{
    IBOutlet UIImageView *imageView;
    IBOutlet UILabel *support;
    IBOutlet UILabel *count;
}
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *support;
@property (nonatomic, strong) IBOutlet UILabel *count;
@end
