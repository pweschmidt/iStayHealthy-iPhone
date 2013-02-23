//
//  OtherMedsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import "OtherMedsTableViewController.h"
#import "iStayHealthyAppDelegate.h"
#import "OtherMedCell.h"
#import "Utilities.h"
#import "GeneralSettings.h"
#import "OtherMedication.h"
#import "UINavigationBar-Button.h"
#import "OtherMedsDetailViewController.h"

@interface OtherMedsTableViewController ()
@property (nonatomic, strong) NSArray *allOtherMeds;
@property (nonatomic, strong) SQLDataTableController *dataController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic, assign) BOOL hasReloadedData;
- (void)registerObservers;
- (void)setUpData;
@end

@implementation OtherMedsTableViewController

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:@"RefetchAllDatabaseData"
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerObservers];
    self.hasReloadedData = NO;
    [self setUpData];
	self.formatter = [[NSDateFormatter alloc]init];
	self.formatter.dateFormat = @"dd MMM YYYY";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadDetailOtherMedsController)];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar)
    {
        [navBar addButtonWithTitle:@"Other Meds" target:self selector:@selector(gotoPOZ)];
    }
}

#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (void)viewDidUnload
{
    self.formatter = nil;
    [super viewDidUnload];
}
#endif

- (void)setUpData
{
	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = appDelegate.managedObjectContext;
    if (nil == self.dataController)
    {
        self.dataController = [[SQLDataTableController alloc] initForEntityType:kOtherMedicationTable
                                                                         sortBy:@"StartDate"
                                                                    isAscending:NO
                                                                        context:self.context];
    }
    
    self.allOtherMeds = [self.dataController cleanedEntries];
}


- (void)reloadData:(NSNotification*)note
{
    self.hasReloadedData = YES;
    if (nil != note)
    {
        [self setUpData];
        [self.tableView reloadData];
    }
    
}

- (void)loadDetailOtherMedsController
{
	OtherMedsDetailViewController *newMedsController = [[OtherMedsDetailViewController alloc] initWithContext:self.context];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newMedsController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];    
}

- (void)loadEditMedsControllerForId:(NSUInteger)rowId
{
    OtherMedication *otherMed = (OtherMedication *)[self.allOtherMeds objectAtIndex:rowId];
    OtherMedsDetailViewController *editMedsController = [[OtherMedsDetailViewController alloc] initWithOtherMedication:otherMed];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:editMedsController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
    
}

- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allOtherMeds.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifer = @"OtherMedCell";
    OtherMedCell *cell = (OtherMedCell *)[tableView dequeueReusableCellWithIdentifier:identifer];
    if(nil == cell)
    {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"OtherMedCell"
                                                            owner:self
                                                          options:nil];
        for (id currentObject in cellObjects)
        {
            if ([currentObject isKindOfClass:[OtherMedCell class]])
            {
                cell = (OtherMedCell *)currentObject;
                break;
            }
        }
    }
    OtherMedication *med = (OtherMedication *)[self.allOtherMeds objectAtIndex:indexPath.row];
    [[cell dateLabel]setText:[self.formatter stringFromDate:med.StartDate]];
    [[cell nameLabel]setText:med.Name];
    [[cell drugLabel]setText:[NSString stringWithFormat:@"%2.2f %@",[med.Dose floatValue], med.Unit]];
    
    tableView.separatorColor = [UIColor lightGrayColor];
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self loadEditMedsControllerForId:indexPath.row];
}

@end
