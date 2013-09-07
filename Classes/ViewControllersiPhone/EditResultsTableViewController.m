//
//  EditResultsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/08/2013.
//
//

#import "EditResultsTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "Results+Handling.h"
#import "Utilities.h"

@interface EditResultsTableViewController ()
{
    CGRect labelFrame;
    CGRect separatorFrame;
    CGRect textViewFrame;
}
@property (nonatomic, strong) NSArray * defaultValues;
@property (nonatomic, strong) NSArray * editResultsMenu;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, assign) BOOL isInEditMode;

@end

@implementation EditResultsTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    labelFrame = CGRectMake(20, 0, 115, 44);
    separatorFrame = CGRectMake(117, 4, 2, 40);
    textViewFrame = CGRectMake(120, 0, 150, 44);
    self.navigationItem.title = NSLocalizedString(@"New Result", nil);
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                             target:self action:@selector(save:)];
    self.editResultsMenu = @[kCD4,
                             kCD4Percent,
                             kViralLoad,
                             kHepCViralLoad,
                             kGlucose,
                             kTotalCholesterol,
                             kHDL,
                             kLDL,
                             kHemoglobulin,
                             kWhiteBloodCells,
                             kRedBloodCells,
                             kPlatelet,
                             kWeight,
                             kBloodPressure,
                             kCardiacRiskFactor];
    self.defaultValues = @[@"400-1500",
                           @"20.0 - 50.0",
                           @"10 - 10000000",
                           @"10 - 10000000"
                           @"4.0 - 7.0",
                           @"3.0 - 6.0",
                           @"1.0 - 2.2"
                           @"2.0 - 3.4",
                           @"1.8 - 2.7",
                           @"3.5 - 11",
                           @"11.5 - 14.5",
                           @"150 - 450",
                           @"Enter your weight",
                           @"120/80",
                           @"0.0 - 10.0"];
    
    
    
    self.titleStrings = [NSMutableArray arrayWithCapacity:self.editResultsMenu.count];
}

- (IBAction)save:(id)sender
{
    if (!self.isInEditMode)
    {
        Results * results = [[CoreDataManager sharedInstance]
                             managedObjectForEntityName:kResults];
        results.UID = [Utilities GUID];
        results.ResultsDate = [NSDate date];
        [self.titleStrings enumerateObjectsUsingBlock:^(UITextView *view, NSUInteger index, BOOL *stop) {
            NSString *valueString = view.text;
            NSString *type = [self.editResultsMenu objectAtIndex:index];
            [results addValueString:valueString type:type];
        }];
        
    }
    else
    {
        Results * results = (Results *)self.managedObject;
    }
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContext:&error];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.editResultsMenu.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"ResultsCell%d",indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (0 == indexPath.row)
    {
        [self configureDateCell:cell indexPath:indexPath];
    }
    else
    {
        NSString *text = NSLocalizedString([self.editResultsMenu objectAtIndex:indexPath.row], nil);
        [self configureTableCell:cell title:text indexPath:indexPath];
    }
    return cell;
}


@end
