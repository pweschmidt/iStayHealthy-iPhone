//
//  SupplySelectorCell.h
//  iStayHealthy
//
//  Created by peterschmidt on 26/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditableTableCell.h"

@interface SupplySelectorCell : EditableTableCell{
	UISegmentedControl	*segmentedControl;
	UILabel				*segmentedLabel;
    
}
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UILabel *segmentedLabel;
- (void)setUpSegmentedControl;
- (void)setUpSegmentedLabel;

@end
