//
//  EditChartsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 22/12/2013.
//
//

#import "EditChartsTableViewController.h"
#import "UIFont+Standard.h"
#import "Utilities.h"

@interface EditChartsTableViewController ()
@property (nonatomic, strong) NSArray *results;
@property (nonatomic, strong) NSMutableArray *immutableIndexPaths;
@property (nonatomic, strong) NSMutableDictionary *mutableIndexPaths;
@property (nonatomic, strong) NSMutableArray *selectedItems;
@property (nonatomic, assign) BOOL settingsChanged;
@end

@implementation EditChartsTableViewController
- (id)initWithSelectedItems:(NSArray *)items
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (nil != self)
    {
        _selectedItems = [NSMutableArray arrayWithArray:items];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self populateValues];
    self.tableView.backgroundColor = DEFAULT_BACKGROUND;
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

- (void)populateValues
{
    self.results = [self dashboardTypes];
    self.immutableIndexPaths = [NSMutableArray array];
    self.mutableIndexPaths = [NSMutableDictionary dictionary];
    [self.results enumerateObjectsUsingBlock: ^(NSString *type, NSUInteger idx, BOOL *stop) {
         NSInteger section = 0;
         NSInteger row = idx;
         NSIndexPath *path = [NSIndexPath indexPathForRow:row inSection:section];
         if (![type isEqualToString:kCD4AndVL])
         {
             BOOL checked = NO;
             if (nil != self.selectedItems && [self.selectedItems containsObject:type])
             {
                 checked = YES;
             }
             [self.mutableIndexPaths setObject:[NSNumber numberWithBool:checked] forKey:path];
         }
     }];
}

- (void)popController
{
    if ([Utilities isIPad])
    {
        if (nil != self.customPopOverDelegate)
        {
            __strong id <PWESPopoverDelegate> strongPopoverDelegate = self.customPopOverDelegate;
            if ([strongPopoverDelegate respondsToSelector:@selector(hidePopover)])
            {
                [strongPopoverDelegate hidePopover];
            }
        }
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
    __strong id <ChartSelector> strongSelector = self.chartSelector;
    if (![self.selectedItems containsObject:kCD4AndVL])
    {
        [self.selectedItems addObject:kCD4AndVL];

    }
    if (nil != strongSelector && [strongSelector respondsToSelector:@selector(selectedCharts:)])
    {
        [self.chartSelector selectedCharts:self.selectedItems];
        NSData *archivedSelector = [NSKeyedArchiver archivedDataWithRootObject:self.selectedItems];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:archivedSelector forKey:kDashboardTypes];
        [defaults synchronize];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Dashboard", nil)
                                                        message:NSLocalizedString(@"Your dashboard settings changed", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"Ok", nil)
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self popController];
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
    NSString *identifier = [NSString stringWithFormat:@"cell%ld", (long) indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString *attributeName = [self.results objectAtIndex:indexPath.row];
    cell.textLabel.text = NSLocalizedString(attributeName, nil);
    cell.textLabel.font = [UIFont fontWithType:Standard size:standard];
    cell.textLabel.textColor = TEXTCOLOUR;

    if ([attributeName isEqualToString:kCD4AndVL])
    {
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.immutableIndexPaths addObject:indexPath];
    }
    else if ([self.selectedItems containsObject:attributeName])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    return cell;
}

- (void)deselect:(id)sender
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

- (NSArray *)dashboardTypes
{
    NSArray *types = @[kCD4AndVL, kCD4PercentAndVL,
                       kGlucose, kTotalCholesterol, kTriglyceride,
                       kHDL, kLDL, kCholesterolRatio, kHemoglobulin,
                       kWhiteBloodCells, kRedBloodCells, kPlatelet,
                       kWeight, kBMI, kSystole, kCardiacRiskFactor, kLiverAlanineTransaminase,
                       kLiverAspartateTransaminase,
                       kLiverAlkalinePhosphatase,
                       kLiverGammaGlutamylTranspeptidase];

    return types;
}

@end
