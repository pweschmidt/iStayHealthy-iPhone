//
//  MyHIVCollectionViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/04/2014.
//
//

#import "MyHIVCollectionViewController.h"
#import "CoreDataManager.h"
#import "BaseCollectionViewCell.h"
#import "Medication+Handling.h"
#import "PreviousMedication+Handling.h"
#import "EditHIVMedsTableViewController.h"
#import "EditCurrentHIVMedsTableViewController.h"
#import "EditPreviousMedsTableViewController.h"
#import "Utilities.h"
#import "MedView_iPad.h"

#define kHIVCollectionCellIdentifier @"HIVCollectionCellIdentifier"


@interface MyHIVCollectionViewController ()
@property (nonatomic, strong) NSArray *currentMeds;
@property (nonatomic, strong) NSArray *previousMeds;
@end

@implementation MyHIVCollectionViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.currentMeds = [NSArray array]; //init with empty array
	self.previousMeds = [NSArray array];
	[self setTitleViewWithTitle:NSLocalizedString(@"HIV Medications", nil)];
	[self.collectionView registerClass:[BaseCollectionViewCell class]
	        forCellWithReuseIdentifier:kHIVCollectionCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
	EditHIVMedsTableViewController *editController = [[EditHIVMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
	editController.preferredContentSize = CGSizeMake(320, 568);
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:editNavCtrl animated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	if (0 == section)
	{
		return self.currentMeds.count;
	}
	else
	{
		return self.previousMeds.count;
	}
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	BaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHIVCollectionCellIdentifier
	                                                                         forIndexPath:indexPath];
	CGRect frame = CGRectMake(0, 2, 150, 130);
	if (0 == indexPath.section)
	{
		Medication *med = [self.currentMeds objectAtIndex:indexPath.row];
		if (nil != med)
		{
			[cell setManagedObject:med];
		}
		[cell addDateToTitle:med.StartDate];
		MedView_iPad *medView = [MedView_iPad viewForMedication:med frame:frame];
		[cell addView:medView];
	}
	else
	{
		PreviousMedication *previousMed = [self.previousMeds objectAtIndex:indexPath.row];
		if (nil != previousMed)
		{
			[cell setManagedObject:previousMed];
		}
		[cell addDateToTitle:previousMed.endDate];
		MedView_iPad *medView = [MedView_iPad viewForPreviousMedication:previousMed frame:frame];
		[cell addView:medView];
	}
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	UINavigationController *editNavCtrl = nil;
	if (0 == indexPath.section)
	{
		Medication *med = [self.currentMeds objectAtIndex:indexPath.row];
		EditCurrentHIVMedsTableViewController *editController = [[EditCurrentHIVMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:med hasNumericalInput:NO];
		editController.preferredContentSize = CGSizeMake(320, 568);
		editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	}
	else
	{
		PreviousMedication *med = [self.previousMeds objectAtIndex:indexPath.row];
		EditPreviousMedsTableViewController *editController = [[EditPreviousMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:med hasNumericalInput:NO];
		editController.preferredContentSize = CGSizeMake(320, 568);
		editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	}
	editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:editNavCtrl animated:YES completion:nil];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
	[self startAnimation:notification];
#ifdef APPDEBUG
	NSLog(@"MyHIVCollectionViewController:reloadSQLData with name %@", notification.name);
#endif
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:YES completion: ^(NSArray *array, NSError *error) {
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
	        self.currentMeds = array;
	        [[CoreDataManager sharedInstance] fetchDataForEntityName:kPreviousMedication predicate:nil sortTerm:kEndDateLowerCase ascending:YES completion: ^(NSArray *prevarray, NSError *error) {
	            if (nil == prevarray)
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
	                self.previousMeds = prevarray;
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
