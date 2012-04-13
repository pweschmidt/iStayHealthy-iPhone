//
//  iStayHealthyTableViewController.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/**
 this is the super class for all TableViewControllers, e.g. ResultsListViewController etc.
 */

#import <UIKit/UIKit.h>
@class iStayHealthyRecord;
@class StatusViewControllerLandscape;
@interface iStayHealthyTableViewController : UITableViewController <UIAlertViewDelegate, NSFetchedResultsControllerDelegate>{
	BOOL isShowingLandscapeView;
	NSFetchedResultsController *fetchedResultsController_;
	iStayHealthyRecord *masterRecord;
	StatusViewControllerLandscape *landscapeController;
    IBOutlet UIView *headerView;
    
	NSArray *allMeds;
    NSArray *allMissedMeds;
    NSArray *allSideEffects;
	NSArray *allResults;
    NSArray *allResultsInReverseOrder;
    NSArray *allPills;
    NSArray *allContacts;
    NSArray *allProcedures;

    
}
@property (nonatomic, retain) NSArray *allMeds;
@property (nonatomic, retain) NSArray *allMissedMeds;
@property (nonatomic, retain) NSArray *allSideEffects;
@property (nonatomic, retain) NSArray *allResults;
@property (nonatomic, retain) NSArray *allResultsInReverseOrder;
@property (nonatomic, retain) NSArray *allContacts;
@property (nonatomic, retain) NSArray *allPills;
@property (nonatomic, retain) NSArray *allProcedures;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) iStayHealthyRecord *masterRecord;
@property (nonatomic, retain) StatusViewControllerLandscape *landscapeController;
@property (nonatomic, retain) IBOutlet UIView *headerView;
- (void)setUpMasterRecord;
- (IBAction)loadWebView:(id)sender;
- (IBAction)loadAd:(id)sender;
- (void)setUpData;
- (void)loadURL;
- (void)gotoPOZ;
- (void)reloadData:(NSNotification*)note;
@end
