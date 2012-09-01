//
//  SideEffectListCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 11/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideEffectListCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *effect;
@property (nonatomic, strong) IBOutlet UILabel *date;
@property (nonatomic, strong) IBOutlet UILabel *drug;
@property (nonatomic, strong) IBOutlet UIImageView  *effectsImageView;
@end