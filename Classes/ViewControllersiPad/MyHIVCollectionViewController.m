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
#import "EditPreviousMedsTableViewController.h"

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
	if (nil == self.customPopoverController)
	{
		EditHIVMedsTableViewController *editController = [[EditHIVMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
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
	if (0 == indexPath.section)
	{
		Medication *med = [self.currentMeds objectAtIndex:indexPath.row];
		if (nil != med)
		{
			[cell setManagedObject:med];
		}
		[cell addDateToTitle:med.StartDate];
	}
	else
	{
		PreviousMedication *previousMed = [self.previousMeds objectAtIndex:indexPath.row];
		if (nil != previousMed)
		{
			[cell setManagedObject:previousMed];
		}
		[cell addDateToTitle:previousMed.startDate];
	}
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self hidePopover];
	UINavigationController *editNavCtrl = nil;
	if (0 == indexPath.section)
	{
		Medication *med = [self.currentMeds objectAtIndex:indexPath.row];
		EditHIVMedsTableViewController *editController = [[EditHIVMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:med hasNumericalInput:NO];
		editController.preferredContentSize = CGSizeMake(320, 568);
		editController.customPopOverDelegate = self;
		editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	}
	else
	{
		PreviousMedication *med = [self.previousMeds objectAtIndex:indexPath.row];
		EditPreviousMedsTableViewController *editController = [[EditPreviousMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:med hasNumericalInput:NO];
		editController.preferredContentSize = CGSizeMake(320, 568);
		editController.customPopOverDelegate = self;
		editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	}
	[self presentPopoverWithController:editNavCtrl
	                          fromRect:CGRectMake(self.view.frame.size.width / 2 - 160, 10, 320, 50)];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
	NSLog(@"MyHIVCollectionViewController:reloadSQLData with name %@", notification.name);
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:YES completion: ^(NSArray *array, NSError *error) {
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
	        self.currentMeds = array;
	        [[CoreDataManager sharedInstance] fetchDataForEntityName:kPreviousMedication predicate:nil sortTerm:kEndDateLowerCase ascending:YES completion: ^(NSArray *prevarray, NSError *error) {
	            if (nil == prevarray)
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
	                self.previousMeds = prevarray;
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
