//
//  ClinicsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import "ClinicsTableViewController.h"
#import "iStayHealthyAppDelegate.h"
#import "ClinicCell.h"
#import "Contacts.h"
#import "GeneralSettings.h"
#import "UINavigationBar-Button.h"
#import "ClinicsDetailViewController.h"
#import "Utilities.h"

@interface ClinicsTableViewController ()
@property (nonatomic, strong) NSArray *allContacts;
@property (nonatomic, strong) SQLDataTableController *dataController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, assign) BOOL hasReloadedData;
- (void)registerObservers;
- (void)setUpData;
@end

@implementation ClinicsTableViewController

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:@"RefetchAllDatabaseData"
                                               object:nil];
}

- (void)setUpData
{
	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = appDelegate.managedObjectContext;
    self.dataController = [[SQLDataTableController alloc] initForEntityName:@"Contacts"
                                                                     sortBy:@"ClinicName"
                                                                isAscending:YES
                                                                    context:self.context];
    
    NSArray *contacts = [self.dataController entriesForEntity];
    self.allContacts = [self.dataController cleanEntriesForData:contacts table:kContactsTable];
}

- (void)reloadData:(NSNotification *)note
{
    NSLog(@"reloadData");
    self.hasReloadedData = YES;
    if (nil != note)
    {
        NSArray *contacts = [self.dataController entriesForEntity];
        self.allContacts = [self.dataController cleanEntriesForData:contacts table:kContactsTable];
        [self.tableView reloadData];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerObservers];
    self.hasReloadedData = NO;
    [self setUpData];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadClinicDetailViewController)];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar)
    {
        [navBar addButtonWithTitle:@"Clinics" target:self selector:@selector(gotoPOZ)];
    }
}

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];    
}

- (void)loadClinicDetailViewController
{
    ClinicsDetailViewController *newClinicController = [[ClinicsDetailViewController alloc] initWithContext:self.context];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newClinicController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
    
}

- (void)loadClinicEditViewControllerForContactId:(NSUInteger) rowId
{
    Contacts *contacts = (Contacts *)[self.allContacts objectAtIndex:rowId];
    ClinicsDetailViewController *newClinicController = [[ClinicsDetailViewController alloc] initWithContacts:contacts];
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
