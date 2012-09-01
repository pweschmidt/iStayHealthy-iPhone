//
//  InfoDetailTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 16/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoDetailTableViewController : UITableViewController 
@property (nonatomic, strong) NSMutableArray *faqList;
@property (nonatomic, strong) IBOutlet UILabel *headerLabel;
@property (nonatomic, strong) IBOutlet UIButton *bannerButton;
@property (nonatomic, strong) IBOutlet UIButton *adButton;
- (IBAction) done:	(id) sender;
- (IBAction)loadWebView:(id)sender;
- (IBAction)loadAd:(id)sender;
- (void)gotoPOZ;
@end
