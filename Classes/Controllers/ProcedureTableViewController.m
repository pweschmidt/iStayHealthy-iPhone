//
//  ProcedureTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import "ProcedureTableViewController.h"
#import "iStayHealthyRecord.h"
#import "GeneralSettings.h"
#import "Procedures.h"
#import "Utilities.h"
#import "ProcedureCell.h"
#import "ProcedureDetailViewController.h"

@interface ProcedureTableViewController ()
@property (nonatomic, strong) NSDateFormatter * formatter;
@end

@implementation ProcedureTableViewController
@synthesize formatter = _formatter;
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
	self.formatter = [[NSDateFormatter alloc]init];
	self.formatter.dateFormat = @"dd MMM YYYY";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadDetailProcedureViewController)];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
}

- (void)loadDetailProcedureViewController
{
    ProcedureDetailViewController *newProcController = [[ProcedureDetailViewController alloc]initWithRecord:self.masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newProcController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
    
}
- (void)loadEditProcedureViewControllerForId:(NSUInteger)rowId
{
    Procedures *proc = (Procedures *)[self.allProcedures objectAtIndex:rowId];
    ProcedureDetailViewController *newProcController = [[ProcedureDetailViewController alloc] initWithProcedure:proc masterRecord:self.masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newProcController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
    
}
- (IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
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
