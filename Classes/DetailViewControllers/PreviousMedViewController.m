//
//  PreviousMedViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 08/09/2012.
//
//

#import "PreviousMedViewController.h"
#import "SQLDataTableController.h"
#import "GeneralSettings.h"
#import "PreviousMedication.h"
#import "HIVMedListCell.h"
#import "iStayHealthyAppDelegate.h"
#import "NSArray-Set.h"

@interface PreviousMedViewController ()
@property (nonatomic, strong) SQLDataTableController *dataController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, assign) BOOL hasReloadedData;
- (void)registerObservers;
- (void)setUpData;
- (NSString *)getStringFromName:(NSString *)name;
- (void)postNotification;
@end

@implementation PreviousMedViewController

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super initWithNibName:@"PreviousMedViewController" bundle:nil];
    if (self) {
        self.context = context;
    }
    return self;
    
}

- (void)postNotification
{
    NSNotification* refreshNotification =
    [NSNotification notificationWithName:@"RefetchAllDatabaseData"
                                  object:self
                                userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:refreshNotification];
    
    NSNotification* animateNotification = [NSNotification
                                           notificationWithName:@"startAnimation"
                                           object:self
                                           userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:animateNotification];
}

- (void)setUpData
{
	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = appDelegate.managedObjectContext;
    self.dataController = [[SQLDataTableController alloc] initForEntityType:kPreviousMedicationTable
                                                                     sortBy:@"endDate"
                                                                isAscending:NO
                                                                    context:self.context];
    
    NSArray *cleanPrevious = [self.dataController cleanedEntries];
    self.allPreviousMedications = [NSMutableArray arrayWithArray:cleanPrevious];
}

- (void)reloadData:(NSNotification *)note
{
    NSLog(@"reloadData");
    self.hasReloadedData = YES;
    if (nil != note)
    {
        NSArray *cleanPrevious = [self.dataController cleanedEntries];
        self.allPreviousMedications = [NSMutableArray arrayWithArray:cleanPrevious];
        [self.tableView reloadData];
    }
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:@"RefetchAllDatabaseData"
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerObservers];
    self.hasReloadedData = NO;
    [self setUpData];

	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                              target:self action:@selector(removeEntry:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


#if  defined(__IPHONE_5_1) || defined (__IPHONE_5_0)
- (void)viewDidUnload
{
    self.allPreviousMedications = nil;
    [super viewDidUnload];
}
#endif
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allPreviousMedications.count;
}

/**
 gets the string from the medname. This could contain a /
 */
- (NSString *)getStringFromName:(NSString *)name
{
    NSArray *stringArray = [name componentsSeparatedByString:@"/"];
    NSString *imageName = [(NSString *)[stringArray objectAtIndex:0]lowercaseString];
    NSArray *finalArray = [imageName componentsSeparatedByString:@" "];
    
    return [(NSString *)[finalArray objectAtIndex:0]lowercaseString];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"HIVMedListCell";
    HIVMedListCell *cell = (HIVMedListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"HIVMedListCell"
                                                        owner:self
                                                      options:nil];
    for (id currentObject in cellObjects)
    {
        if ([currentObject isKindOfClass:[HIVMedListCell class]])
        {
            cell = (HIVMedListCell *)currentObject;
            break;
        }
    }
    PreviousMedication *previousMed = (PreviousMedication *)[self.allPreviousMedications objectAtIndex:indexPath.row];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"dd MMM YYYY";
    NSString *startString = [formatter stringFromDate:previousMed.startDate];
    NSString *endString = [formatter stringFromDate:previousMed.endDate];
    cell.date.text = [NSString stringWithFormat:@"%@ - %@",startString, endString];
    cell.date.textColor = DARK_YELLOW;
    cell.name.text = previousMed.name;
    cell.content.text = previousMed.drug;
    NSString *imageName = [[self getStringFromName:previousMed.name] lowercaseString];
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
    cell.medImageView.image = [UIImage imageWithContentsOfFile:path];
    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (IBAction)removeEntry:(id)sender
{
    if (!self.tableView.editing)
    {
        [self.tableView setEditing:YES animated:YES];
    }
    else
    {
        [self.tableView setEditing:NO animated:YES];
    }    
}


/*
 */
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        PreviousMedication *previousMed = (PreviousMedication *)[self.allPreviousMedications objectAtIndex:indexPath.row];
        [self.allPreviousMedications removeObject:previousMed];
        NSManagedObjectContext *context = previousMed.managedObjectContext;
        [context deleteObject:previousMed];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        NSError *error = nil;
        if (![context save:&error])
        {
#ifdef APPDEBUG
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
            [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Saving", nil)
                                        message:NSLocalizedString(@"Save error message", nil)
                                       delegate:nil
                              cancelButtonTitle:@"Ok"
                              otherButtonTitles: nil]
             show];
        }
        
        [self postNotification];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}


@end
