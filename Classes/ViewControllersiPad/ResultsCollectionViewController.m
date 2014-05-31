//
//  ResultsCollectionViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 22/02/2014.
//
//

#import "ResultsCollectionViewController.h"
#import "CoreDataManager.h"
#import "BaseCollectionViewCell.h"
#import "Results+Handling.h"
#import "EditResultsTableViewController.h"
#import "ResultsView-iPad.h"
//#import "Constants.h"

#define kResultsCollectionCellIdentifier @"ResultsCollectionCellIdentifier"

@interface ResultsCollectionViewController ()
@property (nonatomic, strong) NSArray *results;
@end

@implementation ResultsCollectionViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	self.results = [NSArray array]; //init with empty array
	[self setTitleViewWithTitle:NSLocalizedString(@"Results", nil)];
	[self.collectionView registerClass:[BaseCollectionViewCell class]
	        forCellWithReuseIdentifier:kResultsCollectionCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
	if (nil == self.customPopoverController)
	{
		EditResultsTableViewController *editController = [[EditResultsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:YES];
		editController.preferredContentSize = CGSizeMake(320, 568);
		editController.customPopOverDelegate = self;
		UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
		editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
		[self presentViewController:editNavCtrl animated:YES completion:nil];
//		[self presentPopoverWithController:editNavCtrl fromBarButton:(UIBarButtonItem *)sender];
	}
	else
	{
		[self hidePopover];
	}
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.results.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Results *results = [self.results objectAtIndex:indexPath.row];
	BaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kResultsCollectionCellIdentifier
	                                                                         forIndexPath:indexPath];
	if (nil != results)
	{
		[cell setManagedObject:results];
	}

	[cell addDateToTitle:results.ResultsDate];
	ResultsView_iPad *hivResults = [ResultsView_iPad viewForResults:results
	                                                    resultsType:HIVResultsType
	                                                          frame:CGRectMake(0, 40, 150, 50)];

	ResultsView_iPad *bloods = [ResultsView_iPad viewForResults:results
	                                                resultsType:BloodResultsType
	                                                      frame:CGRectMake(0, 90, 150, 20)];

	ResultsView_iPad *other = [ResultsView_iPad viewForResults:results
	                                               resultsType:OtherResultsType
	                                                     frame:CGRectMake(0, 115, 150, 20)];

	[cell.contentView addSubview:hivResults];
	[cell.contentView addSubview:bloods];
	[cell.contentView addSubview:other];
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self hidePopover];
	Results *results = [self.results objectAtIndex:indexPath.row];
	EditResultsTableViewController *editController = [[EditResultsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:results hasNumericalInput:YES];
	editController.preferredContentSize = CGSizeMake(320, 568);
	editController.customPopOverDelegate = self;
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:editNavCtrl animated:YES completion:nil];
//	[self presentPopoverWithController:editNavCtrl
//	                          fromRect:CGRectMake(self.view.frame.size.width / 2 - 160, 10, 320, 50)];
}

- (void)reloadSQLData:(NSNotification *)notification
{
	NSLog(@"ResultsCollectionViewController with name %@", notification.name);
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kResults predicate:nil sortTerm:kResultsDate ascending:NO completion: ^(NSArray *array, NSError *error) {
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
	        self.results = nil;
	        self.results = array;
	        NSLog(@"we have %lu results returned", (unsigned long)self.results.count);
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
