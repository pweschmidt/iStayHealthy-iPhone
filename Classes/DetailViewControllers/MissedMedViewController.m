//
//  MissedMedViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MissedMedViewController.h"
#import "iStayHealthyAppDelegate.h"
#import "Utilities.h"
#import "MissedMedication.h"
#import "NSArray-Set.h"
#import "GeneralSettings.h"
#import "SideEffectListCell.h"
#import "MissedMedsDetailTableViewController.h"

@interface MissedMedViewController ()
@property (nonatomic, strong) NSArray *allMissedMeds;
@property (nonatomic, strong) SQLDataTableController *dataController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, assign) BOOL hasReloadedData;
@property (nonatomic, strong) NSArray *medications;
- (void)registerObservers;
- (void)setUpData;
- (void)loadMissedMedsTableViewController;
@end

@implementation MissedMedViewController

- (id)initWithContext:(NSManagedObjectContext *)context medications:(NSArray *)medications
{
    self = [super initWithNibName:@"MissedMedViewController" bundle:nil];
    if (nil != self)
    {
        self.context = context;
        self.medications = medications;
    }
    return self;
}

- (void)registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadData:)
                                                 name:@"RefetchAllDatabaseData"
                                               object:nil];
}


- (void)setUpData
{
	iStayHealthyAppDelegate *appDelegate = (iStayHealthyAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.context = appDelegate.managedObjectContext;
    if (nil == self.dataController)
    {
        self.dataController = [[SQLDataTableController alloc] initForEntityType:kMissedMedicationTable
                                                                         sortBy:@"MissedDate"
                                                                    isAscending:NO
                                                                        context:self.context];
    }
    
    self.allMissedMeds = [self.dataController cleanedEntries];
}

- (void)reloadData:(NSNotification *)note
{
    self.hasReloadedData = YES;
    if (nil != note)
    {
        [self setUpData];
        [self.tableView reloadData];
    }
}


- (IBAction) done:				(id) sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self registerObservers];
    self.hasReloadedData = NO;
    [self setUpData];
	self.navigationItem.title = NSLocalizedString(@"Missed", @"Missed");
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                             target:self action:@selector(done:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadMissedMedsTableViewController)];
}

- (void)loadMissedMedsTableViewController
{
    if (nil == self.medications)
    {
        UIAlertView *noMedsAlert = [[UIAlertView alloc] initWithTitle:@"No Medication" message:@"No Meds available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noMedsAlert show];
        return;
    }
    if (0 == self.medications.count)
    {
        UIAlertView *noMedsAlert = [[UIAlertView alloc] initWithTitle:@"No Medication" message:@"No Meds available" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noMedsAlert show];
        return;
    }
    if (1 == self.medications.count)
    {
        Medication *med = [self.medications objectAtIndex:0];
        MissedMedsDetailTableViewController *newMissedController = [[MissedMedsDetailTableViewController alloc] initWithContext:self.context medicationName:med.Name];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newMissedController];
        UINavigationBar *navigationBar = [navigationController navigationBar];
        navigationBar.tintColor = [UIColor blackColor];
        [self presentModalViewController:navigationController animated:YES];
    }
    else
    {
        __block UIAlertView *medAlert = [[UIAlertView alloc] init];
        medAlert.title = NSLocalizedString(@"HIV Drugs", nil);
        medAlert.message = NSLocalizedString(@"Select From List", nil);
        medAlert.delegate = self;
        [self.medications enumerateObjectsUsingBlock:^(Medication *med, NSUInteger index, BOOL *stop){
            [medAlert addButtonWithTitle:med.Name];
        }];
        [medAlert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        [medAlert show];        
    }
    
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allMissedMeds count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}


/**
 gets the string from the medname. This could contain a / 
 */
- (NSString *)getStringFromName:(NSString *)name
{
    NSArray *stringArray = [name componentsSeparatedByString:@"/"];
    NSString *imageName = [(NSString *)[stringArray objectAtIndex:0]lowercaseString];
    return imageName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SideEffectListCell";
    SideEffectListCell *cell = (SideEffectListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SideEffectListCell" owner:self options:nil];
        for (id currentObject in cellObjects)
        {
            if ([currentObject isKindOfClass:[SideEffectListCell class]])
            {
                cell = (SideEffectListCell *)currentObject;
                break;
            }
        }  
    }
    MissedMedication *missed = (MissedMedication *)[self.allMissedMeds objectAtIndex:indexPath.row];
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	formatter.dateFormat = @"dd MMM YYYY";
    cell.date.text = [formatter stringFromDate:missed.MissedDate];
    cell.effect.text = missed.Name;
    cell.drug.text = missed.missedReason;
    cell.effectsImageView.image = [UIImage imageNamed:@"missed.png"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - Table view delegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MissedMedication *missed = (MissedMedication *)[self.allMissedMeds objectAtIndex:indexPath.row];
	MissedMedsDetailTableViewController *newMissedController = [[MissedMedsDetailTableViewController alloc] initWithMissedMedication:missed];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newMissedController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}

#pragma mark - AlertView delegate method
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if (nil != title)
    {
        if (![title isEqualToString:NSLocalizedString(@"Cancel", nil)] && ![title isEqualToString:@""])
        {
            MissedMedsDetailTableViewController *newMissedController = [[MissedMedsDetailTableViewController alloc] initWithContext:self.context medicationName:title];
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newMissedController];
            UINavigationBar *navigationBar = [navigationController navigationBar];
            navigationBar.tintColor = [UIColor blackColor];
            [self presentModalViewController:navigationController animated:YES];
        }
    }
}

@end
