//
//  LocalBackupController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/07/2014.
//
//

#import "LocalBackupController.h"
#import "iStayHealthy-Swift.h"
    //#import "CoreDataManager.h"
#import "UIFont+Standard.h"

@interface LocalBackupController ()

@end

@implementation LocalBackupController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = DEFAULT_BACKGROUND;
    [self setTitleViewWithTitle:NSLocalizedString(@"Local Backup/Restore", nil)];
    [self disableRightBarButtons];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger sections = 1;
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
    if ([manager storeIsiCloudEnabled])
    {
        sections = 2;
    }
//    BOOL hasImportData = [CoreDataManager sharedInstance].hasDataForImport;
//
//    if (hasImportData)
//    {
//        return 3;
//    }
    return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }

    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.textLabel.textColor = TEXTCOLOUR;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (0 == indexPath.section)
    {
        cell.textLabel.font = [UIFont fontWithType:Bold size:standard];
        cell.textLabel.text = NSLocalizedString(@"Restore locally", nil);
    }
    else if (1 == indexPath.section)
    {
        cell.textLabel.font = [UIFont fontWithType:Bold size:standard];
        cell.textLabel.text = NSLocalizedString(@"Disable iCloud", nil);
    }
//    else
//    {
//        cell.textLabel.font = [UIFont fontWithType:Standard size:standard];
//        cell.textLabel.text = NSLocalizedString(@"Import Data", nil);
//    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (0 == section)
    {
        return NSLocalizedString(@"Get stored data set - if available", nil);
    }
    else if (1 == section)
    {
        return NSLocalizedString(@"Disable iCloud for iStayHealthy", nil);
    }
    else
    {
        return NSLocalizedString(@"There are data to import.", nil);
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
        [manager loadDataFromBackupFile:^(BOOL success, NSError *error) {
                             if (success)
                             {
                                 [[[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Restore Finished", nil)
                                             message:NSLocalizedString(@"Data were retrieved locally.", nil)
                                            delegate:nil
                                   cancelButtonTitle:@"OK" otherButtonTitles:nil]
                                  show];
                             }
                             else
                             {
                                 [[[UIAlertView alloc]
                                   initWithTitle:NSLocalizedString(@"Error restoring", nil)
                                             message:NSLocalizedString(@"There was an error when retrieving data locally.", nil)
                                            delegate:nil
                                   cancelButtonTitle:@"OK" otherButtonTitles:nil]
                                  show];
                             }
            
        }];
    }
    else if (1 == indexPath.section) // disabling icloud
    {
        UIAlertView *warning = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DisableiCloud", nil) message:NSLocalizedString(@"Irreversible", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Proceed", nil), nil];
        [warning show];
    }
    [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:NSLocalizedString(@"Proceed", nil)])
    {
        PWESTransferDBViewController *transferController = [PWESTransferDBViewController new];
        [self.navigationController pushViewController:transferController animated:YES];
    }
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{
    [self reloadSQLData:notification];
}

@end
