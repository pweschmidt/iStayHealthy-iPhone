//
//  SideEffectsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 21/09/2013.
//
//

#import "SideEffectsTableViewController.h"
#import "ContentContainerViewController.h"
#import "ContentNavigationController.h"
#import "Constants.h"
#import "CoreDataManager.h"

@interface SideEffectsTableViewController ()
@property (nonatomic, strong) NSArray *effects;
@end

@implementation SideEffectsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.effects = [NSArray array];
    self.navigationItem.title = NSLocalizedString(@"Side Effects", nil);
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
    return self.effects.count;
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
    [[CoreDataManager sharedInstance] fetchDataForEntityName:kSideEffects
                                                   predicate:nil
                                                    sortTerm:kSideEffectDate
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
                                                           self.effects = nil;
                                                           self.effects = [NSArray arrayWithArray:array];
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