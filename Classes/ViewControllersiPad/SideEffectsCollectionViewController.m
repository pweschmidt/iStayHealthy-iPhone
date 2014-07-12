//
//  SideEffectsCollectionViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/04/2014.
//
//

#import "SideEffectsCollectionViewController.h"
#import "CoreDataManager.h"
#import "BaseCollectionViewCell.h"
#import "SideEffects+Handling.h"
#import "EditSideEffectsTableViewController.h"
#import "MedView_iPad.h"

#define kSideEffectsCollectionCellIdentifier @"SideEffectsCollectionCellIdentifier"

@interface SideEffectsCollectionViewController ()
@property (nonatomic, strong) NSArray *effects;
@property (nonatomic, strong) NSArray *currentMeds;
@end

@implementation SideEffectsCollectionViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setTitleViewWithTitle:NSLocalizedString(@"Side Effects", nil)];
	self.effects = [NSArray array];
	self.currentMeds = [NSArray array];
	[self.collectionView registerClass:[BaseCollectionViewCell class]
	        forCellWithReuseIdentifier:kSideEffectsCollectionCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
	EditSideEffectsTableViewController *editController = [[EditSideEffectsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
	editController.preferredContentSize = CGSizeMake(320, 568);
	editController.customPopOverDelegate = self;
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:editNavCtrl animated:YES completion:nil];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
	return self.effects.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
	return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	SideEffects *effect = [self.effects objectAtIndex:indexPath.row];
	BaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSideEffectsCollectionCellIdentifier
	                                                                         forIndexPath:indexPath];
	if (nil != effect)
	{
		[cell setManagedObject:effect];
	}

	[cell addDateToTitle:effect.SideEffectDate];
	MedView_iPad *view = [MedView_iPad viewForSideEffects:effect frame:CGRectMake(0, 2, 150, 130)];
	[cell addView:view];
	return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
	SideEffects *effect = [self.effects objectAtIndex:indexPath.row];
	EditSideEffectsTableViewController *editController = [[EditSideEffectsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:effect hasNumericalInput:NO];
	editController.preferredContentSize = CGSizeMake(320, 568);
	UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
	editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
	[self presentViewController:editNavCtrl animated:YES completion:nil];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
	[self startAnimation:notification];
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kSideEffects predicate:nil sortTerm:kSideEffectDate ascending:NO completion: ^(NSArray *array, NSError *error) {
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
	        self.effects = nil;
	        self.effects = [NSArray arrayWithArray:array];
	        [[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:NO completion: ^(NSArray *medsarray, NSError *innererror) {
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
