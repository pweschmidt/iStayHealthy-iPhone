//
//  ClinicAddressCollectionViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/04/2014.
//
//

#import "ClinicAddressCollectionViewController.h"
#import "CoreDataManager.h"
#import "BaseCollectionViewCell.h"
#import "Contacts+Handling.h"
#import "EditContactsTableViewController.h"
#import "UIFont+Standard.h"
#import "MedView_iPad.h"

#define kClinicsCollectionCellIdentifier @"ClinicsCollectionCellIdentifier"

@interface ClinicAddressCollectionViewController ()
@property (nonatomic, strong) NSArray *clinics;
@end


@implementation ClinicAddressCollectionViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.clinics = [NSArray array];
	[self setTitleViewWithTitle:NSLocalizedString(@"Clinics", nil)];
	[self.collectionView registerClass:[BaseCollectionViewCell class]
	        forCellWithReuseIdentifier:kClinicsCollectionCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
	EditContactsTableViewController *editController = [[EditContactsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
	editController.preferredContentSize = CGSizeMake(320, 568);
	////		editController.customPopOverDelegate = self;
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:editNavCtrl animated:YES completion:nil];
//	if (nil == self.customPopoverController)
//	{
//		EditContactsTableViewController *editController = [[EditContactsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
//		editController.preferredContentSize = CGSizeMake(320, 568);
////		editController.customPopOverDelegate = self;
//		UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
//		editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
//		[self presentViewController:editNavCtrl animated:YES completion:nil];
//	}
//	else
//	{
//		[self hidePopover];
//	}
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.clinics.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Contacts *contact = [self.clinics objectAtIndex:indexPath.row];
	BaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kClinicsCollectionCellIdentifier
	                                                                         forIndexPath:indexPath];
	if (nil != contact)
	{
		[cell setManagedObject:contact];
	}
	[cell addTitle:contact.ClinicName];
	MedView_iPad *view = [MedView_iPad viewForContacts:contact frame:CGRectMake(0, 2, 150, 130)];
	[cell addView:view];

	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	Contacts *clinic = [self.clinics objectAtIndex:indexPath.row];
	EditContactsTableViewController *editController = [[EditContactsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:clinic hasNumericalInput:NO];
	editController.preferredContentSize = CGSizeMake(320, 568);
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:editNavCtrl animated:YES completion:nil];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
	[self startAnimation:notification];
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kContacts predicate:nil sortTerm:kClinicName ascending:NO completion: ^(NSArray *array, NSError *error) {
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
	        self.clinics = nil;
	        self.clinics = [NSArray arrayWithArray:array];
#ifdef APPDEBUG
	        NSLog(@"we have %lu clinics returned", (unsigned long)self.clinics.count);
#endif
	        dispatch_async(dispatch_get_main_queue(), ^{
	            [self stopAnimation:notification];
	            [self.collectionView reloadData];
			});
		}
	}];
}

- (void)handleStoreChanged:(NSNotification *)notification
{
	[self reloadSQLData:notification];
}

@end
