//
//  EditSideEffectsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "EditSideEffectsTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "Medication+Handling.h"
#import "Utilities.h"
#import "SideEffects+Handling.h"
#import "UILabel+Standard.h"
#import "EffectsSelectionTableViewController.h"

@interface EditSideEffectsTableViewController ()
{
    NSUInteger frequencyIndex;
    NSUInteger seriousnessIndex;
}
@property (nonatomic, strong) NSArray *editMenu;
@property (nonatomic, strong) NSArray *seriousnessArray;
@property (nonatomic, strong) NSArray *frequencyArray;
@property (nonatomic, strong) NSArray *currentMeds;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, strong) UISegmentedControl *seriousnessControl;
@property (nonatomic, strong) UISegmentedControl *frequencyControl;
@property (nonatomic, strong) NSIndexPath *linkIndexPath;
@property (nonatomic, strong) NSMutableDictionary *selectedMedCells;
- (void)changeFrequency:(id)sender;
- (void)changeSeriousness:(id)sender;

@end

@implementation EditSideEffectsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
        currentMeds:(NSArray *)currentMeds
      managedObject:(NSManagedObject *)managedObject
{
    self = [super initWithStyle:style
                  managedObject:managedObject
              hasNumericalInput:NO];
    if (nil != self)
    {
        if (nil == currentMeds)
        {
            _currentMeds = [NSArray array];
        }
        else
        {
            _currentMeds = currentMeds;
        }
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.editMenu = @[kSideEffect, kEffectsOther];
    self.seriousnessArray = @[kEffectsMinor, kEffectsMajor, kEffectsSerious];
    self.frequencyArray = @[kEffectsRarely, kEffectsSometimes, kEffectsOften, kEffectsAlways];
    self.seriousnessControl = [[UISegmentedControl alloc] initWithItems:self.seriousnessArray];
    self.frequencyControl = [[UISegmentedControl alloc] initWithItems:self.frequencyArray];
    [self.seriousnessControl addTarget:self
                                action:@selector(changeSeriousness:)
                      forControlEvents:UIControlEventValueChanged];
    [self.frequencyControl addTarget:self
                                action:@selector(changeFrequency:)
                      forControlEvents:UIControlEventValueChanged];
    seriousnessIndex = 0;
    frequencyIndex = 0;
    self.linkIndexPath = nil;
    self.seriousnessControl.selectedSegmentIndex = seriousnessIndex;
    self.frequencyControl.selectedSegmentIndex = frequencyIndex;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setDefaultValues
{
    if(!self.isEditMode)
    {
        return;
    }
}

- (void)save:(id)sender
{
    SideEffects *effects = nil;
    if (!self.isEditMode)
    {
        effects = [[CoreDataManager sharedInstance] managedObjectForEntityName:kSideEffects];
    }
    else
    {
        effects = (SideEffects *)self.managedObject;
    }
    effects.UID = [Utilities GUID];
    effects.SideEffectDate = self.date;
    if (0 < self.selectedMedCells.allKeys.count)
    {
        
    }
    if (nil != self.textViews && 0 < self.textViews.count)
    {
        NSNumber *firstNumber = (NSNumber *)[self.textViews.allKeys objectAtIndex:0];
        UITextField *field = [self.textViews objectForKey:firstNumber];
        effects.SideEffect = field.text;
    }
    effects.seriousness = [self.seriousnessArray objectAtIndex:seriousnessIndex];
    //effects.frequency = [self.frequencyArray objectAtIndex:frequencyIndex];
    NSError *error = nil;
    [[CoreDataManager sharedInstance] saveContext:&error];
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        return ([self indexPathHasPicker:indexPath] ? kBaseDateCellRowHeight : self.tableView.rowHeight);
    }
    else
    {
        return 60;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        if ([self hasInlineDatePicker])
        {
            // we have a date picker, so allow for it in the number of rows in this section
            NSInteger numRows = self.editMenu.count + 1;
            return ++numRows;
        }
        return self.editMenu.count + 1;
    }
    else
    {
        return self.currentMeds.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            identifier = [NSString stringWithFormat:kBaseDateCellRowIdentifier];
        }
        else
        {
            if ([self hasInlineDatePicker])
            {
                identifier = [NSString stringWithFormat:@"DatePickerCell"];
            }
            else
            {
                identifier = [NSString stringWithFormat:@"SideEffectCell%d",indexPath.row];
            }
        }
    }
    else
    {
        identifier = [NSString stringWithFormat:@"CurrentMedCell%d", indexPath.row];
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (0 == indexPath.section)
    {
        if (0 == indexPath.row)
        {
            [self configureDateCell:cell indexPath:indexPath dateType:DateOnly];
        }
        else
        {
            if ([self hasInlineDatePicker])
            {
//                [self configureDatePickerCell:cell indexPath:indexPath];
            }
            else
            {
                NSUInteger titleIndex = (nil == self.datePickerIndexPath) ? indexPath.row - 1 : indexPath.row - 2;
                NSString *text = [self.editMenu objectAtIndex:titleIndex];
                NSString *localisedText = NSLocalizedString(text, nil);
                if ([text isEqualToString:kSideEffect])
                {
                    [self configureTableCell:cell
                                       title:localisedText
                                   indexPath:indexPath
                           hasNumericalInput:NO];
                }
                else
                {
                    [self configureLinkCell:cell
                                  indexPath:indexPath
                                      title:localisedText];
                }
            }
        }
    }
    else
    {
        Medication *current = (Medication *)[self.currentMeds objectAtIndex:indexPath.row];
        [self configureMedCell:cell med:current indexPath:indexPath];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        if (indexPath.row == self.linkIndexPath.row)
        {
            EffectsSelectionTableViewController *controller = [[EffectsSelectionTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            controller.effectsDataSource = self;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}

- (void)configureLinkCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath title:(NSString *)title
{
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.linkIndexPath = indexPath;
    UILabel *label = [UILabel standardLabel];
    label.text = title;
    label.frame = CGRectMake(20, 0, 200, self.tableView.rowHeight);
    [cell.contentView addSubview:label];
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 120;
    }
    else
    {
        return 10;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] init];
    if (0 < section)
    {
        footerView.backgroundColor = [UIColor clearColor];
        return footerView;
    }
    footerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 120);
    UILabel *label = [[UILabel alloc]
                      initWithFrame:CGRectMake(20, 10, tableView.bounds.size.width-40, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"How serious?", nil);
    label.textColor = TEXTCOLOUR;
    label.textAlignment = NSTextAlignmentJustified;
    label.font = [UIFont fontWithType:Standard size:standard];
    [footerView addSubview:label];
    self.seriousnessControl.frame = CGRectMake(20, 35, tableView.bounds.size.width-40, 25);
    [footerView addSubview:self.seriousnessControl];
    
    UILabel *frequencyLabel = [[UILabel alloc]
                               initWithFrame:CGRectMake(20, 65, tableView.bounds.size.width-40, 20)];
    frequencyLabel.backgroundColor = [UIColor clearColor];
    frequencyLabel.text = NSLocalizedString(@"How often?", nil);
    frequencyLabel.textColor = TEXTCOLOUR;
    frequencyLabel.textAlignment = NSTextAlignmentJustified;
    frequencyLabel.font = [UIFont fontWithType:Standard size:standard];
    
    [footerView addSubview:frequencyLabel];
    self.frequencyControl.frame = CGRectMake(20, 90, tableView.bounds.size.width-40, 25);
    [footerView addSubview:self.frequencyControl];
    return footerView;
}



- (void)changeFrequency:(id)sender
{
    if ([sender isKindOfClass:[UISegmentedControl class]])
    {
        UISegmentedControl *segmenter = (UISegmentedControl *)sender;
        frequencyIndex = segmenter.selectedSegmentIndex;
    }
}

- (void)changeSeriousness:(id)sender
{
    if ([sender isKindOfClass:[UISegmentedControl class]])
    {
        UISegmentedControl *segmenter = (UISegmentedControl *)sender;
        seriousnessIndex = segmenter.selectedSegmentIndex;
    }
}

- (void)configureMedCell:(UITableViewCell *)cell
                     med:(Medication *)med
               indexPath:(NSIndexPath *)indexPath
{
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    NSNumber *checked = [self.selectedMedCells objectForKey:indexPath];
    if (!checked)
    {
        [self.selectedMedCells setObject:(checked = [NSNumber numberWithBool:NO])
                                  forKey:indexPath];
    }
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor clearColor];
    imageView.frame = CGRectMake(20, 2, 55, 55);
    NSString *pathName = [Utilities imageNameFromMedName:med.Name];
    if (nil != pathName)
    {
        NSString *pillPath = [[NSBundle mainBundle]
                              pathForResource:[pathName lowercaseString] ofType:@"png"];
        imageView.image = [UIImage imageWithContentsOfFile:pillPath];
    }
    
    UILabel *label = [UILabel standardLabel];
    label.text = med.Name;
    label.frame = CGRectMake(80, 0, 180, self.tableView.rowHeight);
    
    [cell.contentView addSubview:imageView];
    [cell.contentView addSubview:label];
}

- (void)selectedEffectFromList:(NSString *)effect
{
    if (nil != self.textViews && 0 < self.textViews.count)
    {
        NSNumber *firstNumber = (NSNumber *)[self.textViews.allKeys objectAtIndex:0];
        UITextField *field = [self.textViews objectForKey:firstNumber];
        field.text = effect;
        field.textColor = [UIColor blackColor];
    }
    
}

@end
