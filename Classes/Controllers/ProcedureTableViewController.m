//
//  ProcedureTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import "ProcedureTableViewController.h"
#import "iStayHealthyAppDelegate.h"
#import "iStayHealthyRecord.h"
#import "GeneralSettings.h"
#import "Procedures.h"
#import "Utilities.h"
#import "ProcedureCell.h"
#import "ProcedureDetailViewController.h"
#import "UINavigationBar-Button.h"

@interface ProcedureTableViewController ()
@property (nonatomic, strong) NSDateFormatter * formatter;
@property (nonatomic, strong) NSArray *allProcedures;
@property (nonatomic, strong) SQLDataTableController *dataController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, assign) BOOL hasReloadedData;
- (void)registerObservers;
- (void)setUpData;
@end

@implementation ProcedureTableViewController

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
    if (nil == self.dataController)
    {
        self.dataController = [[SQLDataTableController alloc] initForEntityType:kProceduresTable
                                                                         sortBy:@"Date"
                                                                    isAscending:NO
                                                                        context:self.context];
    }
    
    self.allProcedures = [self.dataController cleanedEntries];
}

- (void)reloadData:(NSNotification *)note
{
    self.hasReloadedData = YES;
    if (nil != note)
    {
        [self setUpData];
        [self.tableView reloadData];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerObservers];
    self.hasReloadedData = NO;
    [self setUpData];
	self.formatter = [[NSDateFormatter alloc]init];
	self.formatter.dateFormat = @"dd MMM YYYY";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadDetailProcedureViewController)];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar)
    {
        [navBar addButtonWithTitle:@"Illness" target:self selector:@selector(gotoPOZ)];
    }
}

- (void)loadDetailProcedureViewController
{
    ProcedureDetailViewController *newProcController = [[ProcedureDetailViewController alloc]initWithContext:self.context];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newProcController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
    
}
- (void)loadEditProcedureViewControllerForId:(NSUInteger)rowId
{
    Procedures *proc = (Procedures *)[self.allProcedures objectAtIndex:rowId];
    ProcedureDetailViewController *newProcController = [[ProcedureDetailViewController alloc] initWithProcedure:proc];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newProcController];
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
    return self.allProcedures.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"ProcedureCell";
    ProcedureCell *cell = (ProcedureCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ProcedureCell" owner:self options:nil];
        for (id currentObject in cellObjects) {
            if ([currentObject isKindOfClass:[ProcedureCell class]]) {
                cell = (ProcedureCell *)currentObject;
                break;
            }
        }
    }
    Procedures *procs = (Procedures *)[self.allProcedures objectAtIndex:indexPath.row];
    NSString *procString = procs.Name;
    NSString *illString = procs.Illness;
    if ([procString isEqualToString:@""] && ![illString isEqualToString:@""]) {
        [[cell procLabel]setText:illString];
        [[cell illnessLabel]setText:@""];
    }
    if (![procString isEqualToString:@""] && [illString isEqualToString:@""]) {
        [[cell procLabel]setText:procString];
        [[cell illnessLabel]setText:@""];
    }
    if (![procString isEqualToString:@""] && ![illString isEqualToString:@""]) {
        [[cell procLabel]setText:procString];
        [[cell illnessLabel]setText:illString];
    }
    [[cell dateLabel]setText:[self.formatter stringFromDate:procs.Date]];
    tableView.separatorColor = [UIColor lightGrayColor];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self loadEditProcedureViewControllerForId:indexPath.row];
}

@end
