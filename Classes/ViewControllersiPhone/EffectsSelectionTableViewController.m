//
//  EffectsSelectionTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/10/2013.
//
//

#import "EffectsSelectionTableViewController.h"
#import "GeneralSettings.h"
@interface EffectsSelectionTableViewController ()
@property (nonatomic, strong) NSMutableArray *sideEffectArray;
@property (nonatomic, strong) UITableViewCell *selectedCell;
@property (nonatomic, strong) NSString *selectedSideEffectLabel;
@end

@implementation EffectsSelectionTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = DEFAULT_BACKGROUND;
    NSString *effectsList = [[NSBundle mainBundle] pathForResource:@"SideEffects" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:effectsList];
    NSArray *list = [dict valueForKey:@"SideEffectArray"];
    NSArray *sortedList = [list
                           sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    self.sideEffectArray = [NSMutableArray arrayWithArray:sortedList];
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
    return self.sideEffectArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"Row%ld",(long)indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.textColor = TEXTCOLOUR;
    cell.textLabel.text = [self.sideEffectArray objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    if (cell == self.selectedCell)
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}


#pragma mark - Table view delegate
- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nil != self.selectedCell)
    {
        self.selectedCell.accessoryType = UITableViewCellAccessoryNone;
        self.selectedCell = nil;
    }
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
    if (self.effectsDataSource && [self.effectsDataSource respondsToSelector:@selector(selectedEffectFromList:)])
    {
        [self.effectsDataSource selectedEffectFromList:cell.textLabel.text];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
