//
//  DropBoxBackupViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 13/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DBRestClient;

@interface DropBoxBackupViewController : UITableViewController{
    NSString *iStayHealthyPath;
    DBRestClient* restClient;   
    IBOutlet UIActivityIndicatorView *activityIndicator;
    BOOL dropBoxFileExists;
    BOOL isBackup;
}
@property (nonatomic, retain) NSString *iStayHealthyPath;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
- (NSString *)dropBoxFileTmpPath;
- (NSString *)uploadFileTmpPath;
- (void)backup;
- (void)restore;
@end
