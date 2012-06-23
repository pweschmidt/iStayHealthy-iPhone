//
//  MoreBloodResultsViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 23/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultValueCell.h"
#import "MoreResultsViewController.h"


@interface MoreBloodResultsViewController : MoreResultsViewController <ResultValueCellDelegate>
- (id)initWithResults:(NSDictionary *)results;
@end

