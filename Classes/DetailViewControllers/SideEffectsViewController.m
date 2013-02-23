//
//  SideEffectsViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 19/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SideEffectsViewController.h"
#import "iStayHealthyAppDelegate.h"
#import "SideEffects.h"
#import "NSArray-Set.h"
#import "GeneralSettings.h"
#import "SideEffectListCell.h"
#import "SideEffectsDetailTableViewController.h"
#import "Utilities.h"

@interface SideEffectsViewController()
@property (nonatomic, strong) NSArray *allSideEffects;
@property (nonatomic, strong) NSArray *medications;
@property (nonatomic, strong) SQLDataTableController *dataController;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, assign) BOOL hasReloadedData;
- (void)setUpData;
- (void)loadSideEffectsController;
- (void)registerObservers;
@end

@implementation SideEffectsViewController

- (id)initWithContext:(NSManagedObjectContext *)context medications:(NSArray *)medications
{
    self = [super initWithNibName:@"SideEffectsViewController" bundle:nil];
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
        self.dataController = [[SQLDataTableController alloc] initForEntityType:kSideEffectsTable
                                                                         sortBy:@"SideEffectDate"
                                                                    isAscending:YES
                                                                        context:self.context];
    }
    
    self.allSideEffects = [self.dataController cleanedEntries];
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
	self.navigationItem.title = NSLocalizedString(@"Side Effects", @"Side Effects");
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] 
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone 
                                              target:self action:@selector(done:)];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadSideEffectsController)];
    self.tableView.rowHeight = 57.0;
}

- (void)loadSideEffectsController
{
    
	SideEffectsDetailTableViewController *newSideEffectController = [[SideEffectsDetailTableViewController alloc]
                                                                     initWithContext:self.context medications:self.medications];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newSideEffectController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
}

- (void)updateSideEffectTable
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.allSideEffects count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"SideEffectListCell";
    SideEffectListCell *cell = (SideEffectListCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"SideEffectListCell"
                                                            owner:self
                                                          options:nil];
        for (id currentObject in cellObjects)
        {
            if ([currentObject isKindOfClass:[SideEffectListCell class]])
            {
                cell = (SideEffectListCell *)currentObject;
                break;
            }
        }  
    }
    SideEffects *effect = (SideEffects *)[self.allSideEffects objectAtIndex:indexPath.row];
	NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
	formatter.dateFormat = @"dd MMM YYYY";
    [[cell date]setText:[formatter stringFromDate:effect.SideEffectDate]];
    [[cell effect]setText:effect.SideEffect];
    [[cell drug]setText:effect.Name];
    [[cell effectsImageView]setImage:[UIImage imageNamed:@"sideeffects.png"]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}


#pragma mark - Table view delegate



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SideEffects *effects = (SideEffects *)[self.allSideEffects objectAtIndex:indexPath.row];
	SideEffectsDetailTableViewController *newSideEffectController = [[SideEffectsDetailTableViewController alloc] initWithSideEffects:effects];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newSideEffectController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}



@end
