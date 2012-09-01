//
//  OtherMedsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2012.
//
//

#import "OtherMedsTableViewController.h"
#import "OtherMedCell.h"
#import "Utilities.h"
#import "GeneralSettings.h"
#import "iStayHealthyRecord.h"
#import "OtherMedication.h"
#import "OtherMedsDetailViewController.h"

@interface OtherMedsTableViewController ()
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation OtherMedsTableViewController
@synthesize formatter = _formatter;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.formatter = [[NSDateFormatter alloc]init];
	self.formatter.dateFormat = @"dd MMM YYYY";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadDetailOtherMedsController)];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.formatter = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)loadDetailOtherMedsController
{
	OtherMedsDetailViewController *newMedsController = [[OtherMedsDetailViewController alloc] initWithRecord:masterRecord];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newMedsController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];    
}

- (void)loadEditMedsControllerForId:(NSUInteger)rowId
{
    OtherMedication *otherMed = (OtherMedication *)[self.allPills objectAtIndex:rowId];
    OtherMedsDetailViewController *editMedsController = [[OtherMedsDetailViewController alloc] initWithOtherMedication:otherMed withMasterRecord:masterRecord];
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
    return self.allPills.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifer = @"OtherMedCell";
    OtherMedCell *cell = (OtherMedCell *)[tableView dequeueReusableCellWithIdentifier:identifer];
    if(nil == cell){
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"OtherMedCell" owner:self options:nil];
        for (id currentObject in cellObjects) {
            if ([currentObject isKindOfClass:[OtherMedCell class]]) {
                cell = (OtherMedCell *)currentObject;
                break;
            }
        }
    }
    OtherMedication *med = (OtherMedication *)[self.allPills objectAtIndex:indexPath.row];
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
