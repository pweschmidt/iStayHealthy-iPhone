//
//  FAQDetailCell.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FAQDetailCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UITextView *explanationView;
- (void)setUpExplanationView;
@end
