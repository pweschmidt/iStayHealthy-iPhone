//
//  MoreTableViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 08/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "MoreTableViewController.h"
#import "GeneralSettings.h"
#import "GeneralMedicalTableViewController.h"
#import "ToolsTableViewController.h"
#import "ProcedureTableViewController.h"
#import "ClinicTableViewController.h"

@implementation MoreTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
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
    self.tableView.backgroundColor = DEFAULT_BACKGROUND;

}

- (void)viewDidUnload
{
    [super viewDidUnload];
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
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 90.0;
}

/**
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.backgroundColor = DEFAULT_BACKGROUND;
    if (0 == indexPath.row) {
        CGRect crossFrame = CGRectMake(CGRectGetMinX(cell.bounds)+40, CGRectGetMinY(cell.bounds)+7, 55.0, 55.0);
        UIButton *crossButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [crossButton setFrame:crossFrame];
        [crossButton setBackgroundImage:[UIImage imageNamed:@"redcross-small.png"] forState:UIControlStateNormal];
        CGRect crossTextFrame = CGRectMake(CGRectGetMinX(cell.bounds)+30, CGRectGetMinY(cell.bounds)+67, 75.0, 10.0);
        [crossButton addTarget:self action:@selector(loadGeneralMedController:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *crossLabel = [[[UILabel alloc]initWithFrame:crossTextFrame]autorelease];
        crossLabel.text = NSLocalizedString(@"Other Meds", @"Other Meds");
        crossLabel.textColor = [UIColor darkGrayColor];
        crossLabel.textAlignment = UITextAlignmentCenter;
        crossLabel.font = [UIFont boldSystemFontOfSize:10.0];
        crossLabel.backgroundColor = DEFAULT_BACKGROUND;
        
        CGRect clinicFrame = CGRectMake(CGRectGetMinX(cell.bounds)+225, CGRectGetMinY(cell.bounds)+7, 55.0, 55.0);
        UIButton *clinicButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [clinicButton setFrame:clinicFrame];
        [clinicButton setBackgroundImage:[UIImage imageNamed:@"clinic.png"] forState:UIControlStateNormal];
        CGRect clinicTextFrame = CGRectMake(CGRectGetMinX(cell.bounds)+215, CGRectGetMinY(cell.bounds)+67, 75.0, 10.0);
        [clinicButton addTarget:self action:@selector(loadClinicController:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *clinicLabel = [[[UILabel alloc]initWithFrame:clinicTextFrame]autorelease];
        clinicLabel.text = NSLocalizedString(@"Contacts", @"Contacts");
        clinicLabel.textColor = [UIColor darkGrayColor];
        clinicLabel.textAlignment = UITextAlignmentCenter;
        clinicLabel.font = [UIFont boldSystemFontOfSize:10.0];
        clinicLabel.backgroundColor = DEFAULT_BACKGROUND;
        
        
        [cell addSubview:crossButton];
        [cell addSubview:crossLabel]; 
        [cell addSubview:clinicButton];
        [cell addSubview:clinicLabel];
//            [crossButton release];
    }
    else{
        CGRect appointmentFrame = CGRectMake(CGRectGetMinX(cell.bounds)+40, CGRectGetMinY(cell.bounds)+7, 55.0, 55.0);
        UIButton *appointmentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [appointmentButton setFrame:appointmentFrame];
        [appointmentButton setBackgroundImage:[UIImage imageNamed:@"procedure.png"] forState:UIControlStateNormal];
        CGRect appTextFrame = CGRectMake(CGRectGetMinX(cell.bounds)+30, CGRectGetMinY(cell.bounds)+67, 75.0, 10.0);
        [appointmentButton addTarget:self action:@selector(loadProcedureController:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *appointmentLabel = [[[UILabel alloc]initWithFrame:appTextFrame]autorelease];
        appointmentLabel.text = NSLocalizedString(@"Illness", @"Illness");
        appointmentLabel.textColor = [UIColor darkGrayColor];
        appointmentLabel.textAlignment = UITextAlignmentCenter;
        appointmentLabel.font = [UIFont boldSystemFontOfSize:10.0];
        appointmentLabel.backgroundColor = DEFAULT_BACKGROUND;
        
        CGRect toolsFrame = CGRectMake(CGRectGetMinX(cell.bounds)+225, CGRectGetMinY(cell.bounds)+7, 55.0, 55.0);
        UIButton *toolsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [toolsButton setFrame:toolsFrame];
        [toolsButton setBackgroundImage:[UIImage imageNamed:@"lock.png"] forState:UIControlStateNormal];
        CGRect toolsTextFrame = CGRectMake(CGRectGetMinX(cell.bounds)+215, CGRectGetMinY(cell.bounds)+67, 75.0, 10.0);
        [toolsButton addTarget:self action:@selector(loadSettingsController:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *toolsLabel = [[[UILabel alloc]initWithFrame:toolsTextFrame]autorelease];
        toolsLabel.text = NSLocalizedString(@"Password", @"Password");
        toolsLabel.textColor = [UIColor darkGrayColor];
        toolsLabel.textAlignment = UITextAlignmentCenter;
        toolsLabel.font = [UIFont boldSystemFontOfSize:10.0];
        toolsLabel.backgroundColor = DEFAULT_BACKGROUND;
        
        
        [cell addSubview:appointmentButton];
        [cell addSubview:appointmentLabel]; 
        [cell addSubview:toolsButton];
        [cell addSubview:toolsLabel];        
    }
        
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - Button Actions
- (void)loadGeneralMedController:(id)sender{
    GeneralMedicalTableViewController *medViewController =
    [[[GeneralMedicalTableViewController alloc] initWithNibName:@"GeneralMedicalTableViewController" bundle:nil]autorelease];
	UINavigationController *navigationController = [[[UINavigationController alloc] initWithRootViewController:medViewController]autorelease];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
}

- (void)loadSettingsController:(id)sender{
    ToolsTableViewController *toolsController =
    [[[ToolsTableViewController alloc] initWithNibName:@"ToolsTableViewController" bundle:nil]autorelease];
    UINavigationController *navigationController = [[[UINavigationController alloc]
                                                    initWithRootViewController:toolsController]autorelease];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
}


- (void)loadProcedureController:(id)sender{
    ProcedureTableViewController *plannerController = 
    [[[ProcedureTableViewController alloc]initWithNibName:@"ProcedureTableViewController" bundle:nil]autorelease];
    UINavigationController *navigationController = 
    [[[UINavigationController alloc]initWithRootViewController:plannerController]autorelease];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
}

- (void)loadClinicController:(id)sender{
    ClinicTableViewController *clinicController = 
    [[[ClinicTableViewController alloc]initWithNibName:@"ClinicTableViewController" bundle:nil]autorelease];
    UINavigationController *navigationController = 
    [[[UINavigationController alloc]initWithRootViewController:clinicController]autorelease];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
}


@end
