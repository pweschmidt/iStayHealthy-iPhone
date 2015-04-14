//
//  IconsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/07/2014.
//
//

#import "IconsTableViewController.h"
#import "UIFont+Standard.h"

static NSArray * mainIcons()
{
    return @[[UIImage imageNamed:@"charts.png"],
             [UIImage imageNamed:@"results.png"],
             [UIImage imageNamed:@"combi.png"],
             [UIImage imageNamed:@"missed.png"],
             [UIImage imageNamed:@"sideeffects.png"],
             [UIImage imageNamed:@"diary.png"],
             [UIImage imageNamed:@"alarm.png"],
             [UIImage imageNamed:@"cross.png"],
             [UIImage imageNamed:@"hospital.png"],
             [UIImage imageNamed:@"procedure.png"]];
}

static NSArray * mainIconText()
{
    return @[NSLocalizedString(@"Charts", nil),
             NSLocalizedString(@"Results", nil),
             NSLocalizedString(@"HIV Medications", nil),
             NSLocalizedString(@"Missed Meds", nil),
             NSLocalizedString(@"Side Effects", nil),
             NSLocalizedString(@"Medication Diary", nil),
             NSLocalizedString(@"Alerts", nil),
             NSLocalizedString(@"Other Medication", nil),
             NSLocalizedString(@"Clinics", nil),
             NSLocalizedString(@"Procedures", nil)];
}

static NSArray * navIcons()
{
    return @[[UIImage imageNamed:@"cancel.png"],
             [UIImage imageNamed:@"charts-barbutton"]];
}

static NSArray * navIconText()
{
    return @[NSLocalizedString(@"Close View", nil),
             NSLocalizedString(@"Select Charts", nil)];
}

static NSArray * toolbarIcons()
{
    return @[[UIImage imageNamed:@"lock.png"],
             [UIImage imageNamed:@"settings.png"],
             [UIImage imageNamed:@"dropbox.png"],
             [UIImage imageNamed:@"feedback.png"],
             [UIImage imageNamed:@"info.png"]];
}

static NSArray * toolbarIconText()
{
    return @[NSLocalizedString(@"Password", nil),
             NSLocalizedString(@"Local Backup/Restore", nil),
             NSLocalizedString(@"Dropbox", nil),
             NSLocalizedString(@"Feedback", nil),
             NSLocalizedString(@"General Info", nil)];
}

@interface IconsTableViewController ()

@end

@implementation IconsTableViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = DEFAULT_BACKGROUND;
    self.navigationItem.title = NSLocalizedString(@"Show Icons", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;

    switch (section)
    {
        case 0:
            rows = mainIcons().count;
            break;

        case 1:
            rows = navIcons().count;
            break;

        case 2:
            rows = toolbarIcons().count;
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier :CellIdentifier];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    UIImage *image = nil;
    NSString *text = nil;
    switch (indexPath.section)
    {
        case 0:
            image = [mainIcons() objectAtIndex:indexPath.row];
            text = [mainIconText() objectAtIndex:indexPath.row];
            break;

        case 1:
            image = [navIcons() objectAtIndex:indexPath.row];
            text = [navIconText() objectAtIndex:indexPath.row];
            break;

        case 2:
            image = [toolbarIcons() objectAtIndex:indexPath.row];
            text = [toolbarIconText() objectAtIndex:indexPath.row];
            break;
    }

    cell.textLabel.textColor = TEXTCOLOUR;
    cell.textLabel.font = [UIFont fontWithType:Standard size:standard];
    if (nil != text)
    {
        cell.textLabel.text = text;
    }
    if (nil != image)
    {
        cell.imageView.image = image;
    }


    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *string = @"";

    switch (section)
    {
        case 0:
            string = NSLocalizedString(@"Main Features", nil);
            break;

        case 1:
            string = NSLocalizedString(@"Top Navigation Bar", nil);
            break;

        case 2:
            string = NSLocalizedString(@"Bottom Toolbar", nil);
            break;
    }

    return string;
}

@end
