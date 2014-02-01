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
@property (nonatomic, strong) NSMutableDictionary *valueMap;
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

- (void)populateValues
{
    self.valueMap = [NSMutableDictionary dictionary];
    self.selectedMedCells = [NSMutableDictionary dictionary];
    [self.currentMeds enumerateObjectsUsingBlock:^(Medication *med, NSUInteger index, BOOL *stop) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:index inSection:2];
        [self.selectedMedCells setObject:[NSNumber numberWithBool:NO] forKey:path];
    }];

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
    if (self.isEditMode && nil != self.managedObject)
    {
        SideEffects *effects = (SideEffects *)self.managedObject;
        [self.valueMap setObject:effects.SideEffect forKey:kSideEffect];
        NSInteger index = [self.seriousnessArray indexOfObject:effects.seriousness];
        if (NSNotFound != index)
        {
            self.seriousnessControl.selectedSegmentIndex = index;
        }
        self.date = effects.SideEffectDate;
        if (0 < self.currentMeds && 0 < effects.Name.length)
        {
            NSArray *names = [effects.Name componentsSeparatedByString:@","];
            [self.currentMeds enumerateObjectsUsingBlock:^(Medication *med, NSUInteger index, BOOL *stop) {
                if ([names containsObject:med.Name])
                {
                    [self.selectedMedCells setObject:[NSNumber numberWithBool:YES]
                                              forKey:[NSIndexPath indexPathForRow:index inSection:2]];
                }
            }];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self populateValues];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    __block NSMutableString *medNames = [NSMutableString string];
    [self.selectedMedCells enumerateKeysAndObjectsUsingBlock:^(NSIndexPath *key, NSNumber *checked, BOOL *stop) {
        if ([checked boolValue])
        {
            if (0 < medNames.length)
            {
                [medNames appendString:@","];
            }
            Medication *med = [self.currentMeds objectAtIndex:key.row];
            [medNames appendString:med.Name];
        }
    }];
    if (0 == medNames.length)
    {
        if (0 < self.currentMeds.count)
        {
            Medication *med = [self.currentMeds objectAtIndex:0];
            effects.Name = med.Name;
        }
    }
    else
    {
        effects.Name = medNames;
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
    else if (1 == indexPath.section)
    {
        return self.tableView.rowHeight;
    }
    else
    {
        return 60;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return ([self hasInlineDatePicker] ? 2 : 1);
    }
    else if (1 == section)
    {
        return self.editMenu.count;
    }
    else
    {
        return self.currentMeds.count;
    }
}


- (NSString *)identifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    if (0 == indexPath.section)
    {
        identifier = [NSString stringWithFormat:kBaseDateCellRowIdentifier];
        if ([self hasInlineDatePicker])
        {
            identifier = [NSString stringWithFormat:@"DatePickerCell"];
        }
    }
    else if(1 == indexPath.section)
    {
        identifier = [NSString stringWithFormat:@"SideEffectCell%d", indexPath.row];
    }
    else
    {
        identifier = [NSString stringWithFormat:@"CurrentMedCell%d", indexPath.row];
    }
    return identifier;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self identifierForIndexPath:indexPath];
    
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
    }
    else if (1 == indexPath.section)
    {
        NSString *text = [self.editMenu objectAtIndex:indexPath.row];
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
    else
    {
        Medication *current = (Medication *)[self.currentMeds objectAtIndex:indexPath.row];
        [self configureMedCell:cell med:current indexPath:indexPath];
    }
    return cell;
}

- (void)configureTableCell:(UITableViewCell *)cell title:(NSString *)title indexPath:(NSIndexPath *)indexPath hasNumericalInput:(BOOL)hasNumericalInput
{
    [super configureTableCell:cell title:title indexPath:indexPath hasNumericalInput:hasNumericalInput];
    NSString *value = [self.valueMap objectForKey:kSideEffect];
    NSNumber *taggedViewNumber = [self tagNumberForIndex:indexPath.row segment:0];
    UITextField *textField = [self.textViews objectForKey:taggedViewNumber];
    if (nil != textField && nil != value)
    {
        textField.text = value;
        textField.textColor = [UIColor blackColor];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [super textFieldDidEndEditing:textField];
    if (nil == textField.text || [textField.text isEqualToString:@""])
    {
        return;
    }
    [self.valueMap setObject:textField.text forKey:kSideEffect];
}

- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (1 == indexPath.section)
    {
        if (indexPath.row == self.linkIndexPath.row)
        {
            EffectsSelectionTableViewController *controller = [[EffectsSelectionTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            controller.effectsDataSource = self;
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
    else if (2 == indexPath.section)
    {
        BOOL checkedValue = [[self.selectedMedCells objectForKey:indexPath] boolValue];
        BOOL checkedUnchecked = !checkedValue;
        [self.selectedMedCells setObject:[NSNumber numberWithBool:checkedUnchecked] forKey:indexPath];
        cell.accessoryType = checkedUnchecked ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
        
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
    if (1 == section)
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
    if (1 != section)
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
    else
    {
        if ([checked boolValue])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
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
