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
@interface iStayHealthyTableViewController : UITableViewController <UIAlertViewDelegate, NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSArray *allMeds;
@property (nonatomic, strong) NSArray *allMissedMeds;
@property (nonatomic, strong) NSArray *allSideEffects;
@property (nonatomic, strong) NSArray *allResults;
@property (nonatomic, strong) NSArray *allResultsInReverseOrder;
@property (nonatomic, strong) NSArray *allContacts;
@property (nonatomic, strong) NSArray *allPills;
@property (nonatomic, strong) NSArray *allProcedures;
@property (nonatomic, strong) NSArray *allPreviousMedications;
@property (nonatomic, strong) NSArray *allWellnes;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) iStayHealthyRecord *masterRecord;
@property (nonatomic, strong) StatusViewControllerLandscape *landscapeController;
@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;
@property BOOL isShowingLandscape;
@property BOOL hasReloadedData;
//- (void)setUpMasterRecord;
- (IBAction)loadWebView:(id)sender;
- (IBAction)loadAd:(id)sender;
- (void)setUpData;
- (void)loadURL;
- (void)gotoPOZ;
- (void)reloadData:(NSNotification*)note;
- (void)start;
@end
