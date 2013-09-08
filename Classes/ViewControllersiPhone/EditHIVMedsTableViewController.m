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
#import "Constants.h"
#import "GeneralSettings.h"

@interface EditHIVMedsTableViewController ()
@property (nonatomic, strong) NSArray *combiTablets;
@property (nonatomic, strong) NSArray *proteaseInhibitors;
@property (nonatomic, strong) NSArray *nRTInihibtors;
@property (nonatomic, strong) NSArray *nNRTInhibitors;
@property (nonatomic, strong) NSArray *integraseInhibitors;
@property (nonatomic, strong) NSArray *entryInhibitors;
@property (nonatomic, strong) NSMutableDictionary *stateDictionary;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSArray * meds;
@property (nonatomic, assign) BOOL isInEditMode;
@property (nonatomic, assign) BOOL isInitialLoad;
@end

@implementation EditHIVMedsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        _meds  = nil;
        _isInEditMode = NO;
    }
    return self;
}

- (id)initWithStyle:(UITableViewStyle)style meds:(NSArray *)meds
{
    self = [super initWithStyle:style];
    if (self)
    {
        _meds  = meds;
        if (nil != meds)
        {
            _isInEditMode = YES;
        }
        else
        {
            _isInEditMode = NO;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isInEditMode)
    {
        self.navigationItem.title = NSLocalizedString(@"Edit HIV Drugs", nil);
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"Add HIV Drugs", nil);
    }
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                              target:self action:@selector(save:)];
    [self loadDrugs];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];

    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (0 == indexPath.section)
    {
        [cell configureCellWithDate:self.startDate];
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
    }
    else
    {
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSInteger rowKey = indexPath.row;
        NSInteger section = indexPath.section;
        switch (section)
        {
                rowKey = 100 + rowKey;
                break;
            case 3:
                rowKey = 1000 + rowKey;
                break;
            case 4:
                rowKey = 10000 + rowKey;
                break;
            case 5:
                rowKey = 100000 + rowKey;
                break;
            case 6:
                rowKey = 1000000 + rowKey;
                break;
        }
        NSString *key = [NSString stringWithFormat:@"%d",rowKey];
        BOOL isChecked = !([[self.stateDictionary objectForKey:key] boolValue]);
        NSNumber *checked = [NSNumber numberWithBool:isChecked];
        [self.stateDictionary setObject:checked forKey:key];
        
        // Update the cell accessory checkmark
        cell.accessoryType = isChecked ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
        
        
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
    }
    
}

#pragma mark - configuring the med cells
- (void)configureMedicationCell:(UITableViewCell *)cell
                      indexPath:(NSIndexPath *)indexPath
{
    NSString *cellKey = [self cellKeyForIndexPath:indexPath];
    NSArray *description = [self medDescriptionForIndexPath:indexPath];
    
    NSNumber * checked = [self.stateDictionary objectForKey:cellKey];
    if (!checked) [self.stateDictionary setObject:(checked = [NSNumber numberWithBool:NO]) forKey:cellKey];
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
        return @"SetDateCell";
    }
    else
    {
        return @"MedSelectionCell";
    }
}

- (NSString *)cellKeyForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 || indexPath.section == 1)
    {
        return [NSString stringWithFormat:@"%d", indexPath.row];
    }
    
    NSInteger multiplier = 1;
    for (NSInteger index = 0; index < indexPath.section; index++)
    {
        multiplier *= 10;
    }
    multiplier += indexPath.row;
    return [NSString stringWithFormat:@"%d",multiplier];
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
