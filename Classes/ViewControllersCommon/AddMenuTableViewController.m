//
//  AddMenuTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/08/2013.
//
//

#import "AddMenuTableViewController.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"
#import "EditResultsTableViewController.h"

@interface AddMenuTableViewController ()
@property (nonatomic, strong) NSArray * menus;
@end

@implementation AddMenuTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"New Items", nil);
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                             target:self action:@selector(cancel)];
    
    self.menus = @[NSLocalizedString(@"New Result", nil),
                   NSLocalizedString(@"New HIV Med", nil),
                   NSLocalizedString(@"New Other Med", nil),
                   NSLocalizedString(@"New Missed Med", nil),
                   NSLocalizedString(@"New Side Effects", nil),
                   NSLocalizedString(@"New Alert", nil),
                   NSLocalizedString(@"New Appointment", nil),
                   NSLocalizedString(@"New Procedure", nil),
                   NSLocalizedString(@"New Wellness", nil)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menus.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"AddEntryCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.menus objectAtIndex:indexPath.row];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            EditResultsTableViewController *resultsCtrl = [[EditResultsTableViewController alloc] init];
            [self.navigationController pushViewController:resultsCtrl animated:YES];
        }
            break;
    }
}

- (void)cancel
{
    [(ContentNavigationController *)self.parentViewController rewindToPreviousController];
}


@end
