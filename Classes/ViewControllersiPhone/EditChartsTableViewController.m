//
//  EditChartsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 22/12/2013.
//
//

#import "EditChartsTableViewController.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "GeneralSettings.h"
#import "UIFont+Standard.h"

@interface EditChartsTableViewController ()
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSMutableArray *immutableIndexPaths;
@property (nonatomic, strong) NSMutableDictionary *mutableIndexPaths;
@property (nonatomic, strong) NSMutableArray *selectedItems;
@property (nonatomic, assign) BOOL settingsChanged;
@end

@implementation EditChartsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = DEFAULT_BACKGROUND;
    NSDictionary *attributes = [[CoreDataManager sharedInstance] attributesForEntityName:kResults];
    self.results = attributes.allKeys;
    self.immutableIndexPaths = [NSMutableArray array];
    self.mutableIndexPaths = [NSMutableDictionary dictionary];
    self.selectedItems = [NSMutableArray arrayWithArray:@[kCD4,kViralLoad]];
    NSArray *barButtons = nil;
    UIButton *save = [UIButton buttonWithType:UIButtonTypeCustom];
    save.frame = CGRectMake(0, 0, 20, 20);
    save.backgroundColor = [UIColor clearColor];
    [save setBackgroundImage:[UIImage imageNamed:@"save.png"] forState:UIControlStateNormal];
    [save addTarget:self action:@selector(save:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithCustomView:save];
    barButtons = @[saveButton];
    self.navigationItem.rightBarButtonItems = barButtons;
    self.settingsChanged = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)save:(id)sender
{
    if (!self.settingsChanged)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No changes", nil)
                                                        message:NSLocalizedString(@"There are no changes to your settings", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    if (nil != self.chartSelector && [self.chartSelector respondsToSelector:@selector(selectedCharts:)])
    {
        [self.chartSelector selectedCharts:self.selectedItems];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Dashboard", nil)
                                                    message:NSLocalizedString(@"Your dashboard settings changed", nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"cell%d",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *attributeName = [self.results objectAtIndex:indexPath.row];
    cell.textLabel.text = NSLocalizedString(attributeName, nil);
    cell.textLabel.font = [UIFont fontWithType:Standard size:standard];
    cell.textLabel.textColor = TEXTCOLOUR;
    
    if ([attributeName isEqualToString:kCD4] || [attributeName isEqualToString:kViralLoad])
    {
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.immutableIndexPaths addObject:indexPath];
    }
    
    return cell;
}

- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]
                                  animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.immutableIndexPaths containsObject:indexPath])
    {
        return;
    }
    NSNumber *number = [self.mutableIndexPaths objectForKey:indexPath];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    NSString *attributeName = [self.results objectAtIndex:indexPath.row];
    if (nil != number)
    {
        BOOL checked = ![number boolValue];
        [self.mutableIndexPaths setObject:[NSNumber numberWithBool:checked] forKey:indexPath];
        cell.accessoryType = (checked) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        if (checked)
        {
            if (![self.selectedItems containsObject:attributeName])
            {
                [self.selectedItems addObject:attributeName];
            }
        }
        else
        {
            if ([self.selectedItems containsObject:attributeName])
            {
                [self.selectedItems removeObject:attributeName];
            }
        }
    }
    else
    {
        [self.mutableIndexPaths setObject:@(1) forKey:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [self.selectedItems addObject:attributeName];
    }
    if (!self.settingsChanged)
    {
        self.settingsChanged = YES;
    }
    [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
}

@end
