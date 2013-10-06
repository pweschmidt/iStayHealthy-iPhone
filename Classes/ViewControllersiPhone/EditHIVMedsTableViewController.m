//
//  EditHIVMedsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/08/2013.
//
//

#import "EditHIVMedsTableViewController.h"
#import "UITableViewCell+Extras.h"
#import "NSDate+Extras.h"
#import "CoreDataManager.h"
#import "Constants.h"
#import "GeneralSettings.h"
#import "Medication+Handling.h"
#import "Utilities.h"

@interface EditHIVMedsTableViewController ()
@property (nonatomic, strong) NSArray *combiTablets;
@property (nonatomic, strong) NSArray *proteaseInhibitors;
@property (nonatomic, strong) NSArray *nRTInihibtors;
@property (nonatomic, strong) NSArray *nNRTInhibitors;
@property (nonatomic, strong) NSArray *integraseInhibitors;
@property (nonatomic, strong) NSArray *entryInhibitors;
@property (nonatomic, strong) NSMutableDictionary *stateDictionary;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, assign) BOOL isInitialLoad;
@end

@implementation EditHIVMedsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	self.stateDictionary = [NSMutableDictionary dictionary];
    if (self.isEditMode)
    {
        self.navigationItem.title = NSLocalizedString(@"Edit HIV Drugs", nil);
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"Add HIV Drugs", nil);
    }
    UIBarButtonItem *save = [[UIBarButtonItem alloc]
                            initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                            target:self action:@selector(save:)];
    UIBarButtonItem *reload = [[UIBarButtonItem alloc]
                               initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(reloadMedications:)];
    
	self.navigationItem.rightBarButtonItems = @[save, reload];
    [self loadDrugs];
}

- (void)setDefaultValues
{
    ///not used here
}

- (void)save:(id)sender
{
    __block NSMutableArray *selectedMeds = [NSMutableArray array];
    NSArray *keys = self.stateDictionary.allKeys;
    [keys enumerateObjectsUsingBlock:^(NSNumber *key, NSUInteger index, BOOL *stop) {
        BOOL isSelected = [[self.stateDictionary objectForKey:key] boolValue];
        if (isSelected)
        {
            NSUInteger cellKey = [key unsignedIntegerValue];
        }
        
    }];
    
    if (0 == selectedMeds.count)
    {
        return;
    }
    
    Medication *med = nil;
    if (self.isEditMode)
    {
        med = (Medication *)self.managedObject;
    }
    else
    {
        med = [[CoreDataManager sharedInstance] managedObjectForEntityName:kMedication];
    }
    med.UID = [Utilities GUID];
    med.StartDate = self.date;
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContextAndWait:&error];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)reloadMedications:(id)sender
{
    
}

- (void)loadDrugs
{
    NSString *combipath = [[NSBundle mainBundle] pathForResource:@"CombiMeds" ofType:@"plist"];
    NSArray *tmp1 = [[NSArray alloc]initWithContentsOfFile:combipath];
    self.combiTablets = tmp1;
    
    NSString *nrtiPath = [[NSBundle mainBundle] pathForResource:@"NRTI" ofType:@"plist"];
    NSArray *tmp2 = [[NSArray alloc]initWithContentsOfFile:nrtiPath];
    self.nRTInihibtors = tmp2;
    
    NSString *proteasePath = [[NSBundle mainBundle] pathForResource:@"ProteaseInhibitors" ofType:@"plist"];
    NSArray *tmp3 = [[NSArray alloc]initWithContentsOfFile:proteasePath];
    self.proteaseInhibitors = tmp3;
    
    NSString *nnrtiPath = [[NSBundle mainBundle] pathForResource:@"NNRTI" ofType:@"plist"];
    NSArray *tmp4 = [[NSArray alloc]initWithContentsOfFile:nnrtiPath];
    self.nNRTInhibitors = tmp4;
    
    NSString *entryPath = [[NSBundle mainBundle] pathForResource:@"EntryInhibitors" ofType:@"plist"];
    NSArray *tmp5 = [[NSArray alloc]initWithContentsOfFile:entryPath];
    self.entryInhibitors = tmp5;
    
    NSString *integrasePath = [[NSBundle mainBundle] pathForResource:@"IntegraseInhibitors" ofType:@"plist"];
    NSArray *tmp6 = [[NSArray alloc]initWithContentsOfFile:integrasePath];
    self.integraseInhibitors = tmp6;
    
    self.startDate = [NSDate date];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 1;
    switch (section)
    {
        case 0:
        {
            if ([self hasInlineDatePicker])
            {
                rows = 2;
            }
        }
            break;
        case 1:
            rows = [self.combiTablets count];
            break;
        case 2:
            rows = [self.entryInhibitors count];
            break;
        case 3:
            rows = [self.integraseInhibitors count];
            break;
        case 4:
            rows = [self.nNRTInhibitors count];
            break;
        case 5:
            rows = [self.nRTInihibtors count];
            break;
        case 6:
            rows = [self.proteaseInhibitors count];
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    NSString *identifier = [self cellIdentifierForIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
    }
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            [cell configureCellWithDate:self.startDate];
        }
        else if ([self hasInlineDatePicker])
        {
            [self configureDateCell:cell indexPath:indexPath dateType:DateOnly];
        }
    }
    else
    {
        [self configureMedicationCell:cell indexPath:indexPath];
    }
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *text = @"";
    switch (section)
    {
        case 1:
            text = NSLocalizedString(@"Combination Tablets",nil);
            break;
        case 2:
            text = NSLocalizedString(@"Fusion/Entry Inhibitors",nil);
            break;
        case 3:
            text = NSLocalizedString(@"Integrase Inhibitors",nil);
            break;
        case 4:
            text = NSLocalizedString(@"non-Nucleoside Reverse Transcriptase Inhibitors",nil);
            break;
        case 5:
            text = NSLocalizedString(@"Nucleos(t)ide Reverse Transcriptase Inhibitors",nil);
            break;
        case 6:
            text = NSLocalizedString(@"Protease Inhibitors",nil);
            break;
    }
    return text;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if ([self indexPathHasPicker:indexPath])
        {
            return kBaseDateCellRowHeight;
        }
        else
        {
            return self.tableView.rowHeight;
        }
    }
    return 60.0;
}

- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]
                                  animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
    else
    {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSNumber *key = [self cellKeyForIndexPath:indexPath];
        BOOL keyValue = [[self.stateDictionary objectForKey:key] boolValue];
        BOOL isChecked = !keyValue;
        NSNumber *checked = [NSNumber numberWithBool:isChecked];
        [self.stateDictionary setObject:checked forKey:key];
        cell.accessoryType = isChecked ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
    }
    
}

#pragma mark - configuring the med cells
- (void)configureMedicationCell:(UITableViewCell *)cell
                      indexPath:(NSIndexPath *)indexPath
{
    NSNumber *cellKey = [self cellKeyForIndexPath:indexPath];
    NSArray *description = [self medDescriptionForIndexPath:indexPath];
    
    NSNumber * checked = [self.stateDictionary objectForKey:cellKey];
    if (!checked)
    {
        [self.stateDictionary setObject:(checked = [NSNumber numberWithBool:NO]) forKey:cellKey];
    }
    cell.accessoryType = checked.boolValue ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;


    NSString *imageName = [description objectAtIndex:3];
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.frame = CGRectMake(20, 3, 55, 55);
    imageView.image = [UIImage imageWithContentsOfFile:path];
    
    UILabel *typeLabel = [[UILabel alloc] init];
    typeLabel.backgroundColor = [UIColor clearColor];
    typeLabel.frame = CGRectMake(83, 0, 200, 21);
    typeLabel.font = [UIFont italicSystemFontOfSize:12];
    typeLabel.textColor = [UIColor darkGrayColor];
    typeLabel.text = [description objectAtIndex:2];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.frame = CGRectMake(83, 20, 200, 21);
    nameLabel.font = [UIFont systemFontOfSize:17];
    nameLabel.textColor = TEXTCOLOUR;
    nameLabel.text = [description objectAtIndex:1];
    
    UILabel *drugLabel = [[UILabel alloc] init];
    drugLabel.backgroundColor = [UIColor clearColor];
    drugLabel.frame = CGRectMake(83, 40, 200, 21);
    drugLabel.font = [UIFont italicSystemFontOfSize:12];
    drugLabel.textColor = [UIColor redColor];
    drugLabel.text = [description objectAtIndex:0];
    
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:typeLabel];
    [cell.contentView addSubview:nameLabel];
    [cell.contentView addSubview:drugLabel];
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            return kBaseDateCellRowIdentifier;
        }
        else
        {
            return @"DatePickerCell";
        }
    }
    else
    {
        NSNumber *cellKey = [self cellKeyForIndexPath:indexPath];
        NSUInteger key = [cellKey unsignedIntegerValue];
        return [NSString stringWithFormat:@"MedicationCell %d",key];
    }
}

- (NSNumber *)cellKeyForIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger rowKey = 0;
    switch (indexPath.section)
    {
        case 1:
            rowKey = indexPath.row;
            break;
        case 2:
            rowKey = 100 + indexPath.row;
            break;
        case 3:
            rowKey = 1000 + indexPath.row;
            break;
        case 4:
            rowKey = 10000 + indexPath.row;
            break;
        case 5:
            rowKey = 100000 + indexPath.row;
            break;
        case 6:
            rowKey = 1000000 + indexPath.row;
            break;
    }
    return [NSNumber numberWithUnsignedInteger:rowKey];
}

- (NSArray *)medDescriptionForIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        return nil;
    }
    NSArray * descriptionArray = nil;
    switch (indexPath.section)
    {
        case 1:
            descriptionArray = (NSArray *)[self.combiTablets objectAtIndex:indexPath.row];
            break;
        case 2:
            descriptionArray = (NSArray *)[self.entryInhibitors objectAtIndex:indexPath.row];
            break;
        case 3:
            descriptionArray = (NSArray *)[self.integraseInhibitors objectAtIndex:indexPath.row];
            break;
        case 4:
            descriptionArray = (NSArray *)[self.nNRTInhibitors objectAtIndex:indexPath.row];
            break;
        case 5:
            descriptionArray = (NSArray *)[self.nRTInihibtors objectAtIndex:indexPath.row];
            break;
        case 6:
            descriptionArray = (NSArray *)[self.proteaseInhibitors objectAtIndex:indexPath.row];
            break;
    }
    return descriptionArray;
}

@end
