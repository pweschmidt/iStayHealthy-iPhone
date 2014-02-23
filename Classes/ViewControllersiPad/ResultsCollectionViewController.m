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


#define kResultsCollectionCellIdentifier @"ResultsCollectionCellIdentifier"

@interface ResultsCollectionViewController ()
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) UIPopoverController *resultsPopoverController;
@end

@implementation ResultsCollectionViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	self.results = [NSArray array]; //init with empty array
	[self setTitleViewWithTitle:NSLocalizedString(@"Results", nil)];
	[self.collectionView registerClass:[BaseCollectionViewCell class]
	        forCellWithReuseIdentifier:kResultsCollectionCellIdentifier];
	self.resultsPopoverController = nil;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
	if (nil == self.resultsPopoverController)
	{
		EditResultsTableViewController *editController = [[EditResultsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:YES];
		editController.preferredContentSize = CGSizeMake(320, 568);
		UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
		self.resultsPopoverController = [[UIPopoverController alloc] initWithContentViewController:editNavCtrl];
		[self.resultsPopoverController presentPopoverFromBarButtonItem:(UIBarButtonItem *)sender permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	}
	else
	{
		[self.resultsPopoverController dismissPopoverAnimated:YES];
		self.resultsPopoverController = nil;
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

	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}

- (void)reloadSQLData:(NSNotification *)notification
{
	NSLog(@"ResultsListTableViewController:reloadSQLData with name %@", notification.name);
	[[CoreDataManager sharedInstance] fetchDataForEntityName:@"Results" predicate:nil sortTerm:@"ResultsDate" ascending:NO completion: ^(NSArray *array, NSError *error) {
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
	        NSLog(@"we have %d results returned", self.results.count);
	        [self.collectionView reloadData];
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
