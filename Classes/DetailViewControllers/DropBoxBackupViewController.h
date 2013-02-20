//
//  DropBoxBackupViewController.h
//  iStayHealthy
//
//  Created by peterschmidt on 13/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsDetailViewController.h"
@class DBRestClient;

@interface DropBoxBackupViewController : UITableViewController
//@property (nonatomic, weak) id<DropboxPostDelegate> postDelegate;
- (NSString *)dropBoxFileTmpPath;
- (NSString *)uploadFileTmpPath;
//- (id) initWithPostDelegate:(id<DropboxPostDelegate>)postDelegate;
@end
