//
//  ProceduresCollectionViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/04/2014.
//
//

#import "ProceduresCollectionViewController.h"
#import "CoreDataManager.h"
#import "BaseCollectionViewCell.h"
#import "Procedures+Handling.h"
#import "EditProceduresTableViewController.h"

#define kProceduresCollectionCellIdentifier @"ProceduresCollectionCellIdentifier"

@interface ProceduresCollectionViewController ()
@property (nonatomic, strong) NSArray *procedures;
@end

@implementation ProceduresCollectionViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	self.procedures = [NSArray array];
	[self setTitleViewWithTitle:NSLocalizedString(@"Illness", nil)];
	[self.collectionView registerClass:[BaseCollectionViewCell class]
	        forCellWithReuseIdentifier:kProceduresCollectionCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
	if (nil == self.customPopoverController)
	{
		EditProceduresTableViewController *editController = [[EditProceduresTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
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
	return self.procedures.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	Procedures *procs = [self.procedures objectAtIndex:indexPath.row];
	BaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kProceduresCollectionCellIdentifier
	                                                                         forIndexPath:indexPath];
	if (nil != procs)
	{
		[cell setManagedObject:procs];
	}

	[cell addDateToTitle:procs.Date];
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	[self hidePopover];
	Procedures *procs = [self.procedures objectAtIndex:indexPath.row];
	EditProceduresTableViewController *editController = [[EditProceduresTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:procs hasNumericalInput:NO];
	editController.preferredContentSize = CGSizeMake(320, 568);
	editController.customPopOverDelegate = self;
	//	UICollectionViewCell *cell = [self collectionView:collectionView cellForItemAtIndexPath:indexPath];
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	[self presentPopoverWithController:editNavCtrl
	                          fromRect:CGRectMake(self.view.frame.size.width / 2 - 160, 10, 320, 50)];
}

- (void)reloadSQLData:(NSNotification *)notification
{
	NSLog(@"ProceduresCollectionViewController with name %@", notification.name);
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kProcedures predicate:nil sortTerm:kDate ascending:NO completion: ^(NSArray *array, NSError *error) {
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
	        self.procedures = nil;
	        self.procedures = array;
	        NSLog(@"we have %lu procedures returned", (unsigned long)self.procedures.count);
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