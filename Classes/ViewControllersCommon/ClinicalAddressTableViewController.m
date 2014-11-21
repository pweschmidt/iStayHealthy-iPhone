//
//  ClinicalAddressTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/09/2013.
//
//

#import "ClinicalAddressTableViewController.h"
//#import "ContentContainerViewController.h"
//#import "ContentNavigationController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "Contacts+Handling.h"
#import "EditContactsTableViewController.h"
#import "UILabel+Standard.h"

@interface ClinicalAddressTableViewController ()
@property (nonatomic, strong) NSArray *clinics;
@end

@implementation ClinicalAddressTableViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	self.clinics = [NSArray array]; //init with empty array
	[self setTitleViewWithTitle:NSLocalizedString(@"Clinics", nil)];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
	EditContactsTableViewController *controller = [[EditContactsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:NO];
	[self.navigationController pushViewController:controller animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.clinics.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (nil == cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[self configureCell:cell indexPath:indexPath];
	return cell;
}

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
	NSArray *subviews = cell.contentView.subviews;
	[subviews enumerateObjectsUsingBlock: ^(UIView *view, NSUInteger index, BOOL *stop) {
	    [view removeFromSuperview];
	}];
	Contacts *contact = (Contacts *)[self.clinics objectAtIndex:indexPath.row];
	CGFloat rowHeight = [self tableView:self.tableView estimatedHeightForRowAtIndexPath:indexPath] - 2;
	UILabel *name = [UILabel standardLabel];
	name.text = contact.ClinicName;
	name.frame = CGRectMake(20 + rowHeight + 10, 1, 170, rowHeight);

	UIImageView *medImageView = [[UIImageView alloc] init];
	medImageView.frame = CGRectMake(20, 1, rowHeight, rowHeight);
	medImageView.backgroundColor = [UIColor clearColor];
	medImageView.image = [UIImage imageNamed:@"hospital.png"];


	[cell.contentView addSubview:name];
	[cell.contentView addSubview:medImageView];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (UITableViewCellEditingStyleDelete == editingStyle)
	{
		self.markedIndexPath = indexPath;
		self.markedObject = [self.clinics objectAtIndex:indexPath.row];
		[self showDeleteAlertView];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	Contacts *contact = (Contacts *)[self.clinics objectAtIndex:indexPath.row];
	EditContactsTableViewController *controller = [[EditContactsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:contact hasNumericalInput:NO];
	[self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
	[self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kContacts predicate:nil sortTerm:kClinicName ascending:NO completion: ^(NSArray *array, NSError *error) {
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
	        self.clinics = nil;
	        self.clinics = [NSArray arrayWithArray:array];
#ifdef APPDEBUG
	        NSLog(@"we have %lu clinics returned", (unsigned long)self.clinics.count);
#endif
	        [self.tableView reloadData];
		}
	}];
}

- (void)handleStoreChanged:(NSNotification *)notification
{
	[self reloadSQLData:notification];
}

@end
