//
//  ClinicsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import "ClinicsTableViewController.h"
#import "ClinicCell.h"
#import "Contacts.h"
#import "GeneralSettings.h"
#import "UINavigationBar-Button.h"
#import "ClinicsDetailViewController.h"

@interface ClinicsTableViewController ()

@end

@implementation ClinicsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadClinicDetailViewController)];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar)
    {
        [navBar addButtonWithTitle:@"Clinics" target:self selector:@selector(gotoPOZ)];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];    
}

- (void)loadClinicDetailViewController
{
    ClinicsDetailViewController *newClinicController = [[ClinicsDetailViewController alloc] initWithRecord:self.masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newClinicController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
    
}

- (void)loadClinicEditViewControllerForContactId:(NSUInteger) rowId
{
    Contacts *contacts = (Contacts *)[self.allContacts objectAtIndex:rowId];
    ClinicsDetailViewController *newClinicController = [[ClinicsDetailViewController alloc] initWithContacts:contacts masterRecord:self.masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newClinicController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allContacts.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"ClinicCell";
    ClinicCell *cell = (ClinicCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ClinicCell"
                                                            owner:self
                                                          options:nil];
        for (id currentObject in cellObjects) {
            if ([currentObject isKindOfClass:[ClinicCell class]])
            {
                cell = (ClinicCell *)currentObject;
                break;
            }
        }
    }
    Contacts *contact = (Contacts *)[self.allContacts objectAtIndex:indexPath.row];
    [[cell clinicCell]setText:contact.ClinicName];
    tableView.separatorColor = [UIColor lightGrayColor];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self loadClinicEditViewControllerForContactId:indexPath.row];
}

@end
