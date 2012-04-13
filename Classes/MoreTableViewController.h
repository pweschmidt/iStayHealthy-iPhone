//
//  MoreTableViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 08/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "iStayHealthyTableViewController.h"

@interface MoreTableViewController : iStayHealthyTableViewController{
    
}
- (void)loadGeneralMedController:(id)sender;
- (void)loadSettingsController:(id)sender;
- (void)loadProcedureController:(id)sender;
- (void)loadClinicController:(id)sender;
@end
