//
//  GeneralMedicalTableViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 08/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GeneralMedicalTableViewController.h"
#import "iStayHealthyRecord.h"
#import "GeneralSettings.h"
#import "NSArray-Set.h"
#import "OtherMedication.h"
#import "Contacts.h"
#import "Procedures.h"
#import "Utilities.h"
#import "ProcedureCell.h"
#import "ClinicCell.h"
#import "OtherMedCell.h"
#import "WebViewController.h"
#import "UINavigationBar-Button.h"

#import "ClinicsTableViewController.h"
#import "OtherMedsTableViewController.h"
#import "ProcedureTableViewController.h"

@interface GeneralMedicalTableViewController ()
- (void)loadClinicsController;
- (void)loadOtherMedsController;
- (void)loadProcedureController;
@end

@implementation GeneralMedicalTableViewController


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar) {
        [navBar addButtonWithTitle:@"General" target:self selector:@selector(gotoPOZ)];
    }
//	self.navigationItem.title = NSLocalizedString(@"General", @"General");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)loadClinicWebview:(NSString *)url withTitle:(NSString *)navTitle
{
    NSString *webURL = url;
    if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"])
    {
        webURL = [NSString stringWithFormat:@"http://%@",url];
    }
    
    
    WebViewController *webViewController = [[WebViewController alloc]initWithURLString:webURL withTitle:navTitle];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    UINavigationBar *navigationBar = [navigationController navigationBar];
    navigationBar.tintColor = [UIColor blackColor];
    [self presentModalViewController:navigationController animated:YES];
}




- (void)loadClinicsController
{
    ClinicsTableViewController *clinicController = [[ClinicsTableViewController alloc] initWithNibName:@"ClinicsTableViewController" bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:clinicController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];    
    
}
- (void)loadOtherMedsController
{
    OtherMedsTableViewController *medsController = [[OtherMedsTableViewController alloc] initWithNibName:@"OtherMedsTableViewController" bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:medsController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
    
}

- (void)loadProcedureController
{
    ProcedureTableViewController *procController = [[ProcedureTableViewController alloc] initWithNibName:@"ProcedureTableViewController" bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:procController];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"GeneralButtonCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
    }
    
    CGRect imageFrame = CGRectMake(20, 3, 55, 55);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:imageFrame];
    CGRect labelFrame = CGRectMake(80, 10, 200, 40);
    UILabel *labelView = [[UILabel alloc]initWithFrame:labelFrame];
    labelView.backgroundColor = [UIColor clearColor];
    labelView.font = [UIFont boldSystemFontOfSize:15];
    labelView.textColor = TEXTCOLOUR;
    switch (indexPath.section)
    {
        case 0:
            imageView.image = [UIImage imageNamed:@"redcross-small.png"];
            labelView.text = NSLocalizedString(@"Other Meds", nil);
            break;
        case 1:
            imageView.image = [UIImage imageNamed:@"procedure.png"];
            labelView.text = NSLocalizedString(@"Illness", nil);
            break;
        case 2:
            imageView.image = [UIImage imageNamed:@"clinic.png"];
            labelView.text = NSLocalizedString(@"Clinics", nil);
            break;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = DEFAULT_BACKGROUND;
    tableView.separatorColor = [UIColor clearColor];
    [cell addSubview:imageView];
    [cell addSubview:labelView];
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section = indexPath.section;
    switch (section)
    {
        case 0:
            [self loadOtherMedsController];
            break;
        case 1:
            [self loadProcedureController];
            break;
        case 2:
            [self loadClinicsController];
            break;
    }
}


@end
