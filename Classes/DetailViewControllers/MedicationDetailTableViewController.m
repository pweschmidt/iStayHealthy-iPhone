//
//  MedicationDetailTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 26/03/2011.
//  Copyright 2011 pweschmidt. All rights reserved.
//

#import "MedicationDetailTableViewController.h"
#import "iStayHealthyRecord.h"
#import "Medication.h"
#import "Utilities.h"
#import "MedSelectionCell.h"
#import "SetDateCell.h"
#import "GeneralSettings.h"

@implementation MedicationDetailTableViewController
@synthesize startDate = _startDate;
@synthesize record = _record;
@synthesize stateDictionary = _stateDictionary;
@synthesize dateCell = _dateCell;
@synthesize isInitialLoad = _isInitialLoad;
@synthesize combiTablets = _combiTablets;
@synthesize proteaseInhibitors = _proteaseInhibitors;
@synthesize nRTInihibtors = _nRTInihibtors;
@synthesize nNRTInhibitors = _nNRTInhibitors;
@synthesize integraseInhibitors = _integraseInhibitors;
@synthesize entryInhibitors = _entryInhibitors;

- (id)initWithRecord:(iStayHealthyRecord *)masterrecord
{
    self = [super initWithNibName:@"MedicationDetailTableViewController" bundle:nil];
    if (self)
    {
        self.record = masterrecord;
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
    return self;
}

/**
 dealloc
 */

- (void)viewDidUnload
{
    self.startDate = nil;
    self.combiTablets = nil;
    self.proteaseInhibitors = nil;
    self.nRTInihibtors = nil;
    self.nNRTInhibitors = nil;
    self.integraseInhibitors = nil;
    self.entryInhibitors = nil;
    self.stateDictionary = nil;
    self.dateCell = nil;
    [super viewDidUnload];    
}
/**
 didReceiveMemoryWarning
 */
- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle
/**
 viewDidLoad
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isInitialLoad = YES;
	self.stateDictionary = [NSMutableDictionary dictionary];
#ifdef APPDEBUG
	NSLog(@"MedicationDetailTableViewController: viewDidLoad ENTERING");
#endif
	self.navigationItem.title = NSLocalizedString(@"Add HIV Drugs",nil);
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
                                            target:self action:@selector(cancel:)];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] 
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
                                            target:self action:@selector(save:)];	
    
}

/**
 just before view is called. n
 @animated
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

/**
 asks for the start date for the medication, stores the selected meds in the database then dismisses the view
 @id sender
 */
- (IBAction) save: (id) sender
{
    for (NSString *key in self.stateDictionary)
    {
        NSNumber *checked = [self.stateDictionary objectForKey:key];
        BOOL isChecked = [checked boolValue];
        if (isChecked)
        {
#ifdef APPDEBUG
            NSLog(@"MedicationDetailTableViewController::save adding drug at index %d",[key intValue]);
#endif
            NSArray *medDescription = nil;
            int keyValue = [key intValue];
            if (100 > keyValue)
            {
                medDescription = (NSArray *)[self.combiTablets objectAtIndex:keyValue];
            }
            else if(100 <= keyValue && 1000>keyValue)
            {
                medDescription = (NSArray *)[self.entryInhibitors objectAtIndex:(keyValue - 100)];                
            }
            else if(1000 <= keyValue && 10000>keyValue)
            {
                medDescription = (NSArray *)[self.integraseInhibitors objectAtIndex:(keyValue - 1000)];
                
            }
            else if(10000 <= keyValue && 100000>keyValue)
            {
                medDescription = (NSArray *)[self.nNRTInhibitors objectAtIndex:(keyValue - 10000)];
                
            }
            else if(100000 <= keyValue && 1000000>keyValue)
            {
                medDescription = (NSArray *)[self.nRTInihibtors objectAtIndex:(keyValue - 100000)];
                
            }
            else if(1000000 <= keyValue)
            {
                medDescription = (NSArray *)[self.proteaseInhibitors objectAtIndex:(keyValue - 1000000)];                
            }
            
            NSManagedObjectContext *context = [self.record managedObjectContext];
            Medication *medication = [NSEntityDescription insertNewObjectForEntityForName:@"Medication" inManagedObjectContext:context];
            [self.record addMedicationsObject:medication];
            medication.Name = (NSString *)[medDescription objectAtIndex:1];
            medication.Drug = (NSString *)[medDescription objectAtIndex:0];
            medication.MedicationForm = (NSString *)[medDescription objectAtIndex:2];
            medication.StartDate = self.startDate;

            medication.UID = [Utilities GUID];
            self.record.UID = [Utilities GUID];
            NSError *error = nil;
            if (![context save:&error])
            {
#ifdef APPDEBUG
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
                abort();
            }
        }
        
    }
    
	[self dismissModalViewControllerAnimated:YES];    
}

/**
 no save: dismisses the view
 @id sender
 */
- (IBAction) cancel: (id) sender
{
	[self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark datepicker code
/**
 brings up a new view to change the date
 */
- (void)changeStartDate
{
    NSString *title = @"\n\n\n\n\n\n\n\n\n\n\n\n" ;	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set",nil), nil];
	[actionSheet showInView:self.view];
	
	
	UIDatePicker *datePicker = [[UIDatePicker alloc] init];
	datePicker.tag = 101;
	datePicker.datePickerMode = UIDatePickerModeDate;
	[actionSheet addSubview:datePicker];
}

/**
 sets the label and resultsdate to the one selected
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIDatePicker *datePicker = (UIDatePicker *)[actionSheet viewWithTag:101];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"dd MMM YY";
	
	NSString *timestamp = [formatter stringFromDate:datePicker.date];
	self.dateCell.value.text = timestamp;
	self.startDate = datePicker.date;
}



#pragma mark - Table view data source

/**
 1 section only
 @tableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

/**
 returns the number of cells (== list of available medications
 @tableView
 @section
 */

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

/**
 cell height is 65.0
 @tableView
 @indexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0;
}


/**
 loads/sets up the cells
 @tableView
 @indexPath
 @return UITableViewCell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"dd MMM YY";
        
        NSString *identifier = @"SetDateCell";
        SetDateCell *cell = (SetDateCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SetDateCell" owner:self options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[SetDateCell class]])
                {
                    cell = (SetDateCell *)currentObject;
                    break;
                }
            }  
        }
        [[cell value]setText:[formatter stringFromDate:self.startDate]];
        [cell setTag:indexPath.row];
        cell.labelImageView.image = [UIImage imageNamed:@"appointments.png"];
        self.dateCell = cell;
        return cell;
    }
    if( 1 == indexPath.section )
    {
        NSString *key = [NSString stringWithFormat:@"%d",indexPath.row];
        NSString *identifier = @"MedSelectionCell";
        MedSelectionCell *cell = (MedSelectionCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"MedSelectionCell" owner:self options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[MedSelectionCell class]])
                {
                    cell = (MedSelectionCell *)currentObject;
                    break;
                }
            }  
        }
        NSArray *medDescription = (NSArray *)[self.combiTablets objectAtIndex:indexPath.row];
        [[cell name]setText:(NSString *)[medDescription objectAtIndex:1]];
        [[cell content]setText:(NSString *)[medDescription objectAtIndex:0]];
        [[cell type]setText:(NSString *)[medDescription objectAtIndex:2]];
        NSString *name = (NSString *)[medDescription objectAtIndex:3];
        NSString *pillPath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
        [[cell medImageView]setImage:[UIImage imageWithContentsOfFile:pillPath]];
        
        NSNumber *checked = [self.stateDictionary objectForKey:key];
        if (!checked) [self.stateDictionary setObject:(checked = [NSNumber numberWithBool:NO]) forKey:key];
        cell.accessoryType = checked.boolValue ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
                
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    if( 2 == indexPath.section )
    {
        int row = 100 + indexPath.row;
        NSString *key = [NSString stringWithFormat:@"%d",row];
        NSString *identifier = @"MedSelectionCell";
        MedSelectionCell *cell = (MedSelectionCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"MedSelectionCell" owner:self options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[MedSelectionCell class]])
                {
                    cell = (MedSelectionCell *)currentObject;
                    break;
                }
            }  
        }
        NSArray *medDescription = (NSArray *)[self.entryInhibitors objectAtIndex:indexPath.row];
        [[cell name]setText:(NSString *)[medDescription objectAtIndex:1]];
        [[cell content]setText:(NSString *)[medDescription objectAtIndex:0]];
        [[cell type]setText:(NSString *)[medDescription objectAtIndex:2]];
        NSString *name = (NSString *)[medDescription objectAtIndex:3];
        NSString *pillPath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
        [[cell medImageView]setImage:[UIImage imageWithContentsOfFile:pillPath]];
        
        NSNumber *checked = [self.stateDictionary objectForKey:key];
        if (!checked) [self.stateDictionary setObject:(checked = [NSNumber numberWithBool:NO]) forKey:key];
        cell.accessoryType = checked.boolValue ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    if( 3 == indexPath.section )
    {
        int row = 1000 + indexPath.row;
        NSString *key = [NSString stringWithFormat:@"%d",row];
        NSString *identifier = @"MedSelectionCell";
        MedSelectionCell *cell = (MedSelectionCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"MedSelectionCell" owner:self options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[MedSelectionCell class]])
                {
                    cell = (MedSelectionCell *)currentObject;
                    break;
                }
            }  
        }
        NSArray *medDescription = (NSArray *)[self.integraseInhibitors objectAtIndex:indexPath.row];
        [[cell name]setText:(NSString *)[medDescription objectAtIndex:1]];
        [[cell content]setText:(NSString *)[medDescription objectAtIndex:0]];
        [[cell type]setText:(NSString *)[medDescription objectAtIndex:2]];
        NSString *name = (NSString *)[medDescription objectAtIndex:3];
        NSString *pillPath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
        [[cell medImageView]setImage:[UIImage imageWithContentsOfFile:pillPath]];
        
        NSNumber *checked = [self.stateDictionary objectForKey:key];
        if (!checked) [self.stateDictionary setObject:(checked = [NSNumber numberWithBool:NO]) forKey:key];
        cell.accessoryType = checked.boolValue ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    if( 4 == indexPath.section )
    {
        int row = 10000 + indexPath.row;
        NSString *key = [NSString stringWithFormat:@"%d",row];
        NSString *identifier = @"MedSelectionCell";
        MedSelectionCell *cell = (MedSelectionCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"MedSelectionCell" owner:self options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[MedSelectionCell class]])
                {
                    cell = (MedSelectionCell *)currentObject;
                    break;
                }
            }  
        }
        NSArray *medDescription = (NSArray *)[self.nNRTInhibitors objectAtIndex:indexPath.row];
        [[cell name]setText:(NSString *)[medDescription objectAtIndex:1]];
        [[cell content]setText:(NSString *)[medDescription objectAtIndex:0]];
        [[cell type]setText:(NSString *)[medDescription objectAtIndex:2]];
        NSString *name = (NSString *)[medDescription objectAtIndex:3];
        NSString *pillPath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
        [[cell medImageView]setImage:[UIImage imageWithContentsOfFile:pillPath]];
        
        NSNumber *checked = [self.stateDictionary objectForKey:key];
        if (!checked) [self.stateDictionary setObject:(checked = [NSNumber numberWithBool:NO]) forKey:key];
        cell.accessoryType = checked.boolValue ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    if( 5 == indexPath.section )
    {
        int row = 100000 + indexPath.row;
        NSString *key = [NSString stringWithFormat:@"%d",row];
        NSString *identifier = @"MedSelectionCell";
        MedSelectionCell *cell = (MedSelectionCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"MedSelectionCell" owner:self options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[MedSelectionCell class]])
                {
                    cell = (MedSelectionCell *)currentObject;
                    break;
                }
            }  
        }
        NSArray *medDescription = (NSArray *)[self.nRTInihibtors objectAtIndex:indexPath.row];
        [[cell name]setText:(NSString *)[medDescription objectAtIndex:1]];
        [[cell content]setText:(NSString *)[medDescription objectAtIndex:0]];
        [[cell type]setText:(NSString *)[medDescription objectAtIndex:2]];
        NSString *name = (NSString *)[medDescription objectAtIndex:3];
        NSString *pillPath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
        [[cell medImageView]setImage:[UIImage imageWithContentsOfFile:pillPath]];
        
        NSNumber *checked = [self.stateDictionary objectForKey:key];
        if (!checked) [self.stateDictionary setObject:(checked = [NSNumber numberWithBool:NO]) forKey:key];
        cell.accessoryType = checked.boolValue ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    if( 6 == indexPath.section )
    {
        int row = 1000000 + indexPath.row;
        NSString *key = [NSString stringWithFormat:@"%d",row];
        NSString *identifier = @"MedSelectionCell";
        MedSelectionCell *cell = (MedSelectionCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == cell)
        {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"MedSelectionCell" owner:self options:nil];
            for (id currentObject in cellObjects)
            {
                if ([currentObject isKindOfClass:[MedSelectionCell class]])
                {
                    cell = (MedSelectionCell *)currentObject;
                    break;
                }
            }  
        }
        NSArray *medDescription = (NSArray *)[self.proteaseInhibitors objectAtIndex:indexPath.row];
        [[cell name]setText:(NSString *)[medDescription objectAtIndex:1]];
        [[cell content]setText:(NSString *)[medDescription objectAtIndex:0]];
        [[cell type]setText:(NSString *)[medDescription objectAtIndex:2]];
        NSString *name = (NSString *)[medDescription objectAtIndex:3];
        NSString *pillPath = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
        [[cell medImageView]setImage:[UIImage imageWithContentsOfFile:pillPath]];
        
        NSNumber *checked = [self.stateDictionary objectForKey:key];
        if (!checked) [self.stateDictionary setObject:(checked = [NSNumber numberWithBool:NO]) forKey:key];
        cell.accessoryType = checked.boolValue ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
        
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        return cell;
    }
    
    return nil;    
}


#pragma mark - Table view delegate
/**
 sets the timing of the deselect
 @id
 */
- (void) deselect: (id) sender
{
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
	if (0 == indexPath.section)
    {
		[self changeStartDate];
    }
    else if(0 < indexPath.section && 7 > indexPath.section)
    {
        MedSelectionCell *cell = (MedSelectionCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        int rowKey = indexPath.row;
        int section = indexPath.section;
        switch (section)
        {
            case 2:
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
#ifdef APPDEBUG
        NSLog(@"MedicationDetailTableViewController::didSelectRowAtIndexPath selecting cell at row %d",indexPath.row);
        NSLog(@"MedicationDetailTableViewController::didSelectRowAtIndexPath reuseIdentifier == %@",key);
#endif
        
        // Created an inverted value and store it
        BOOL isChecked = !([[self.stateDictionary objectForKey:key] boolValue]);
        NSNumber *checked = [NSNumber numberWithBool:isChecked];
        [self.stateDictionary setObject:checked forKey:key];
        
        // Update the cell accessory checkmark
        cell.accessoryType = isChecked ? UITableViewCellAccessoryCheckmark :  UITableViewCellAccessoryNone;
        
        
        [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
    }
}

@end
