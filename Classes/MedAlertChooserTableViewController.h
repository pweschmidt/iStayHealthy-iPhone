//
//  MedAlertChooserTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 12/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iStayHealthyRecord;

@interface MedAlertChooserTableViewController : UITableViewController {
    iStayHealthyRecord *record;
}
@property (nonatomic, retain) iStayHealthyRecord *record;

@end
