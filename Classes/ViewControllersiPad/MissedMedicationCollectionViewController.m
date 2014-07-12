//
//  MissedMedicationCollectionViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/04/2014.
//
//

#import "MissedMedicationCollectionViewController.h"
#import "CoreDataManager.h"
#import "BaseCollectionViewCell.h"
#import "MissedMedication+Handling.h"
#import "EditMissedMedsTableViewController.h"
#import "MedView_iPad.h"

#define kMissedCollectionCellIdentifier @"MissedCollectionCellIdentifier"

@interface MissedMedicationCollectionViewController ()
@property (nonatomic, strong) NSArray *missed;
@property (nonatomic, strong) NSArray *currentMeds;
@end

@implementation MissedMedicationCollectionViewController
- (void)viewDidLoad
{
	[super viewDidLoad];
	self.missed = [NSArray array];
	self.currentMeds = [NSArray array];
	[self setTitleViewWithTitle:NSLocalizedString(@"Missed Medication", nil)];
	[self.collectionView registerClass:[BaseCollectionViewCell class]
	        forCellWithReuseIdentifier:kMissedCollectionCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
	EditMissedMedsTableViewController *editController = [[EditMissedMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
	editController.preferredContentSize = CGSizeMake(320, 568);
	editController.customPopOverDelegate = self;
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:editNavCtrl animated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.missed.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	MissedMedication *med = [self.missed objectAtIndex:indexPath.row];
	BaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMissedCollectionCellIdentifier
	                                                                         forIndexPath:indexPath];
	if (nil != med)
	{
		[cell setManagedObject:med];
	}

	[cell addDateToTitle:med.MissedDate];
	MedView_iPad *view = [MedView_iPad viewForMissedMedication:med frame:CGRectMake(0, 2, 150, 130)];
	[cell addView:view];
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	MissedMedication *med = [self.missed objectAtIndex:indexPath.row];
	EditMissedMedsTableViewController *editController = [[EditMissedMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:med hasNumericalInput:NO];
	editController.preferredContentSize = CGSizeMake(320, 568);
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:editNavCtrl animated:YES completion:nil];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
	[self startAnimation:notification];
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kMissedMedication predicate:nil sortTerm:kMissedDate ascending:NO completion: ^(NSArray *array, NSError *error) {
	    if (nil == array)
	    {
	        UIAlertView *errorAlert = [[UIAlertView alloc]
	                                   initWithTitle:NSLocalizedString(@"Error", nil)
	                                                message:NSLocalizedString(@"Error loading data", nil)
	                                               delegate:nil
	                                      cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
	                                      otherButtonTitles:nil];
	        [errorAlert show];
		}
	    else
	    {
	        self.missed = nil;
	        self.missed = [NSArray arrayWithArray:array];
	        [[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:NO completion: ^(NSArray *medsarray, NSError *innererror) {
	            if (nil == medsarray)
	            {
	                UIAlertView *errorAlert = [[UIAlertView alloc]
	                                           initWithTitle:NSLocalizedString(@"Error", nil)
	                                                        message:NSLocalizedString(@"Error loading data", nil)
	                                                       delegate:nil
	                                              cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
	                                              otherButtonTitles:nil];
	                [errorAlert show];
				}
	            else
	            {
	                self.currentMeds = nil;
	                self.currentMeds = [NSArray arrayWithArray:medsarray];
	                dispatch_async(dispatch_get_main_queue(), ^{
	                    [self stopAnimation:notification];
	                    [self.collectionView reloadData];
					});
				}
			}];
		}
	}];
}

- (void)handleStoreChanged:(NSNotification *)notification
{
	[self reloadSQLData:notification];
}

@end
