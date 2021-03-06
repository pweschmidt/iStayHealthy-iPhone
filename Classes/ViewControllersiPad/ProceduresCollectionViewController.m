//
//  ProceduresCollectionViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/04/2014.
//
//

#import "ProceduresCollectionViewController.h"
#import "BaseCollectionViewCell.h"
#import "Procedures+Handling.h"
#import "EditProceduresTableViewController.h"
#import "UILabel+Standard.h"
#import "MedView_iPad.h"
#import "iStayHealthy-Swift.h"

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
    EditProceduresTableViewController *editController = [[EditProceduresTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];

    editController.preferredContentSize = CGSizeMake(320, 568);
    UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
    editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:editNavCtrl animated:YES completion:nil];
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

    MedView_iPad *view = [MedView_iPad viewForProcedures:procs frame:CGRectMake(0, 2, 150, 130)];
    [cell addView:view];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    Procedures *procs = [self.procedures objectAtIndex:indexPath.row];
    EditProceduresTableViewController *editController = [[EditProceduresTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:procs hasNumericalInput:NO];

    editController.preferredContentSize = CGSizeMake(320, 568);
    UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
    editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:editNavCtrl animated:YES completion:nil];
}

- (void)reloadSQLData:(NSNotification *)notification
{
    [self startAnimation:notification];
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
    [manager fetchData:kProcedures predicate:nil sortTerm:kDate ascending:NO completion: ^(NSArray *array, NSError *error) {
         if (nil == array)
         {
             [PWESAlertHandler.alertHandler
              showAlertViewWithCancelButton:NSLocalizedString(@"Error", nil)
              message:NSLocalizedString(@"Error loading data", nil)
              presentingController:self];
         }
         else
         {
             self.procedures = nil;
             self.procedures = array;
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
