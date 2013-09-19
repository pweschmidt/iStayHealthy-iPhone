//
//  ProceduresListTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 19/09/2013.
//
//

#import "ProceduresListTableViewController.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"
#import "Constants.h"
#import "CoreDataManager.h"

@interface ProceduresListTableViewController ()
@property (nonatomic, strong) NSArray *procedures;
@end

@implementation ProceduresListTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.procedures = [NSArray array];//init with empty array
    self.navigationItem.title = NSLocalizedString(@"Illness/Procedures", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.procedures.count;
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
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
    [[CoreDataManager sharedInstance] fetchDataForEntityName:kProcedures
                                                   predicate:nil
                                                    sortTerm:kDate
                                                   ascending:NO completion:^(NSArray *array, NSError *error) {
                                                       if (nil == array)
                                                       {
                                                           UIAlertView *errorAlert = [[UIAlertView alloc]
                                                                                      initWithTitle:@"Error"
                                                                                      message:@"Error loading data"
                                                                                      delegate:nil
                                                                                      cancelButtonTitle:@"Cancel"
                                                                                      otherButtonTitles:nil];
                                                           [errorAlert show];
                                                           
                                                       }
                                                       else
                                                       {
                                                           self.procedures = nil;
                                                           self.procedures = [NSArray arrayWithArray:array];
                                                           NSLog(@"we have %d other meds returned", self.procedures.count);
                                                           [self.tableView reloadData];
                                                       }
                                                   }];
}
- (void)startAnimation:(NSNotification *)notification
{
}
- (void)stopAnimation:(NSNotification *)notification
{
}
- (void)handleError:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{    
}


@end
