//
//  IconsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 31/07/2014.
//
//

#import "IconsTableViewController.h"
#import "UIFont+Standard.h"
#import "UILabel+Standard.h"

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
    NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSUInteger imageViewTag = indexPath.row + indexPath.section * 10 + 100;
    NSUInteger labelTag = imageViewTag + 1000;
    UIImageView *imageView = nil;
    UILabel *standardLabel = nil;

    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier :CellIdentifier];
        imageView = [[UIImageView alloc] init];
        imageView.tag = imageViewTag;
        standardLabel = [UILabel standardLabel];
        standardLabel.frame = CGRectMake(70.f, 0, cell.contentView.frame.size.width - 80.0f, cell.contentView.frame.size.height);
        standardLabel.tag = labelTag;
        [cell.contentView addSubview:imageView];
        [cell.contentView addSubview:standardLabel];
    }
    else
    {
        imageView = (UIImageView *) [cell.contentView viewWithTag:imageViewTag];
        standardLabel = (UILabel *) [cell.contentView viewWithTag:labelTag];
    }

    cell.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    switch (indexPath.section)
    {
        case 0:
            imageView.frame = CGRectMake(20, 2, 40, 40);
            imageView.image = [mainIcons() objectAtIndex:indexPath.row];
            standardLabel.text = [mainIconText() objectAtIndex:indexPath.row];
            break;

        case 1:
            imageView.frame = CGRectMake(20, 11, 22, 22);
            imageView.image = [navIcons() objectAtIndex:indexPath.row];
            standardLabel.text = [navIconText() objectAtIndex:indexPath.row];
            break;

        case 2:
            imageView.frame = CGRectMake(20, 11, 22, 22);
            imageView.image = [toolbarIcons() objectAtIndex:indexPath.row];
            standardLabel.text = [toolbarIconText() objectAtIndex:indexPath.row];
            break;
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
