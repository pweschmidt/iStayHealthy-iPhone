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
