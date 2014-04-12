//
//  OtherMedsCollectionViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/04/2014.
//
//

#import "OtherMedsCollectionViewController.h"
#import "CoreDataManager.h"
#import "BaseCollectionViewCell.h"
#import "OtherMedication+Handling.h"
#import "EditOtherMedsTableViewController.h"
#define kOtherMedsCollectionCellIdentifier @"OtherMedsCollectionCellIdentifier"

@interface OtherMedsCollectionViewController ()
@property (nonatomic, strong) NSArray *meds;
@end

@implementation OtherMedsCollectionViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	self.meds = [NSArray array]; //init with empty array
	[self setTitleViewWithTitle:NSLocalizedString(@"Other Medication", nil)];
	[self.collectionView registerClass:[BaseCollectionViewCell class]
	        forCellWithReuseIdentifier:kOtherMedsCollectionCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
	if (nil == self.customPopoverController)
	{
		EditOtherMedsTableViewController *editController = [[EditOtherMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
		editController.preferredContentSize = CGSizeMake(320, 568);
		editController.customPopOverDelegate = self;
		UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
		[self presentPopoverWithController:editNavCtrl fromBarButton:(UIBarButtonItem *)sender];
	}
	else
	{
		[self hidePopover];
	}
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.meds.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	OtherMedication *med = [self.meds objectAtIndex:indexPath.row];
	BaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kOtherMedsCollectionCellIdentifier
	                                                                         forIndexPath:indexPath];
	if (nil != med)
	{
		[cell setManagedObject:med];
	}

	[cell addDateToTitle:med.StartDate];
//	ResultsView_iPad *hivResults = [ResultsView_iPad viewForResults:results
//	                                                    resultsType:HIVResultsType
//	                                                          frame:CGRectMake(0, 40, 150, 50)];
//
//	ResultsView_iPad *bloods = [ResultsView_iPad viewForResults:results
//	                                                resultsType:BloodResultsType
//	                                                      frame:CGRectMake(0, 90, 150, 20)];
//
//	ResultsView_iPad *other = [ResultsView_iPad viewForResults:results
//	                                               resultsType:OtherResultsType
//	                                                     frame:CGRectMake(0, 115, 150, 20)];
//
//	[cell.contentView addSubview:hivResults];
//	[cell.contentView addSubview:bloods];
//	[cell.contentView addSubview:other];
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self hidePopover];
	OtherMedication *med = [self.meds objectAtIndex:indexPath.row];
	EditOtherMedsTableViewController *editController = [[EditOtherMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:med hasNumericalInput:NO];
	editController.preferredContentSize = CGSizeMake(320, 568);
	editController.customPopOverDelegate = self;
	//	UICollectionViewCell *cell = [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	[self presentPopoverWithController:editNavCtrl
	                          fromRect:CGRectMake(self.view.frame.size.width / 2 - 160, 10, 320, 50)];
}

- (void)reloadSQLData:(NSNotification *)notification
{
	NSLog(@"OtherMedsCollectionViewController with name %@", notification.name);
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kOtherMedication predicate:nil sortTerm:kStartDate ascending:NO completion: ^(NSArray *array, NSError *error) {
	    if (nil == array)
	    {
	        UIAlertView *errorAlert = [[UIAlertView alloc]
	                                   initWithTitle:@"Error"
	                                                message:@"Error loading data"
	                                               delegate:nil
	                                      cancelButtonTitle:@"Cancel"
	                                      otherButtonTitles:nil];
	        [errorAlert show];
		}
	    else
	    {
	        self.meds = nil;
	        self.meds = array;
	        NSLog(@"we have %lu meds returned", (unsigned long)self.meds.count);
	        dispatch_async(dispatch_get_main_queue(), ^{
	            [self.collectionView reloadData];
			});
		}
	}];
}

- (void)startAnimation:(NSNotification *)notification
{
}

- (void)stopAnimation:(NSNotification *)notification
{
}

- (void)handleError:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{
}

@end