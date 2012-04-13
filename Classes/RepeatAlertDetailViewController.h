//
//  RepeatAlertDetailViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EditableTableCell.h"

@protocol RepeatAlertDelegate;

@interface RepeatAlertDetailViewController : UITableViewController {
	id<RepeatAlertDelegate> delegate;
    EditableTableCell *lastSelectedCell;
	BOOL initialLoad;
}
@property (nonatomic, assign) id<RepeatAlertDelegate> delegate;
@property (nonatomic, retain) EditableTableCell *lastSelectedCell;
@end

@protocol RepeatAlertDelegate <NSObject>

- (void)setRepeatIntervalText:(NSString *)repeatText;

@end
