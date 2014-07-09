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
#import "MedView_iPad.h"

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
	EditOtherMedsTableViewController *editController = [[EditOtherMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
	editController.preferredContentSize = CGSizeMake(320, 568);
	editController.customPopOverDelegate = self;
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:editNavCtrl animated:YES completion:nil];
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
	MedView_iPad *view = [MedView_iPad viewForOtherMedication:med frame:CGRectMake(0, 2, 150, 130)];
	[cell addView:view];
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//	[self hidePopover];
	OtherMedication *med = [self.meds objectAtIndex:indexPath.row];
	EditOtherMedsTableViewController *editController = [[EditOtherMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:med hasNumericalInput:NO];
	editController.preferredContentSize = CGSizeMake(320, 568);
//	editController.customPopOverDelegate = self;
	//	UICollectionViewCell *cell = [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:editNavCtrl animated:YES completion:nil];
}

- (void)reloadSQLData:(NSNotification *)notification
{
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
	[self reloadSQLData:notification];
}

@end
