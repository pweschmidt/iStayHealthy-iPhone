//
//  MoreOtherResultsViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 23/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultValueCell.h"
#import "PressureCell.h"
#import "MoreResultsViewController.h"


@interface MoreOtherResultsViewController : MoreResultsViewController <ResultValueCellDelegate, PressureCellDelegate>
@property (nonatomic, strong) PressureCell *bloodPressureCell;
@property NSInteger systoleTag;
@property NSInteger diastoleTag;
- (id)initWithResults:(NSDictionary *)results systoleTag:(NSInteger)tag diastoleTag:(NSInteger)tag;
@end

