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
	if (nil == self.customPopoverController)
	{
		EditMissedMedsTableViewController *editController = [[EditMissedMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
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
	[self hidePopover];
	MissedMedication *med = [self.missed objectAtIndex:indexPath.row];
	EditMissedMedsTableViewController *editController = [[EditMissedMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:med hasNumericalInput:NO];
	editController.preferredContentSize = CGSizeMake(320, 568);
	editController.customPopOverDelegate = self;
	//	UICollectionViewCell *cell = [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	[self presentPopoverWithController:editNavCtrl
	                          fromRect:CGRectMake(self.view.frame.size.width / 2 - 160, 10, 320, 50)];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kMissedMedication predicate:nil sortTerm:kMissedDate ascending:NO completion: ^(NSArray *array, NSError *error) {
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
	        self.missed = nil;
	        self.missed = [NSArray arrayWithArray:array];
	        [[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:NO completion: ^(NSArray *medsarray, NSError *innererror) {
	            if (nil == medsarray)
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
	                self.currentMeds = nil;
	                self.currentMeds = [NSArray arrayWithArray:medsarray];
	                dispatch_async(dispatch_get_main_queue(), ^{
	                    [self.collectionView reloadData];
					});
				}
			}];
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
