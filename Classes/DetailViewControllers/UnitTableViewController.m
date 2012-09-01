//
//  UnitTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/08/2012.
//
//

#import "UnitTableViewController.h"
#import "GeneralSettings.h"
#import "UnitCell.h"

@interface UnitTableViewController ()

@end

@implementation UnitTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"UnitCell";
    UnitCell *unitCell = (UnitCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == unitCell)
    {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"UnitCell"
                                                            owner:self
                                                          options:nil];
        for (id currentObject in cellObjects)
        {
            if ([currentObject isKindOfClass:[UnitCell class]])
            {
                unitCell = (UnitCell *)currentObject;
                break;
            }
        }
    }
    unitCell.unitTitle.textColor = TEXTCOLOUR;
    unitCell.tag = indexPath.row;
    switch (indexPath.row)
    {
        case 0:
            unitCell.unitTitle.text = NSLocalizedString(@"Cholesterol", @"unit for sugar/cholesterol");
            [unitCell.segControl setTitle:@"mmol/L" forSegmentAtIndex:0];
            [unitCell.segControl setTitle:@"mg/dL" forSegmentAtIndex:1];
            break;
        case 1:
            unitCell.unitTitle.text = NSLocalizedString(@"Blood sugar", @"unit for sugar/cholesterol");
            [unitCell.segControl setTitle:@"mmol/L" forSegmentAtIndex:0];
            [unitCell.segControl setTitle:@"mg/dL" forSegmentAtIndex:1];
            break;
        case 2:
            unitCell.unitTitle.text = NSLocalizedString(@"Weight", @"weight unit");
            [unitCell.segControl setTitle:@"kg" forSegmentAtIndex:0];
            [unitCell.segControl setTitle:@"lb" forSegmentAtIndex:1];
            break;
    }
        
    return unitCell;
}


@end
