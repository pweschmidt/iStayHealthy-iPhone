//
//  InformationTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 21/09/2013.
//
//

#import "InformationTableViewController.h"
// #import "ContentContainerViewController.h"
// #import "ContentNavigationController.h"
#import "UILabel+Standard.h"
#import "Utilities.h"
#import "IconsTableViewController.h"
#import "HelpViewController.h"
#import "iStayHealthy-Swift.h"
// #import "WebViewController.h"

@interface InformationTableViewController ()

@end

@implementation InformationTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super init];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundColor = DEFAULT_BACKGROUND;
    [self setTitleViewWithTitle:NSLocalizedString(@"Information", nil)];
//    [self disableRightBarButtons];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                              target:self action:@selector(done:)];
}

- (void)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return 3;
    }
    return 4;
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
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    CGRect frame = CGRectMake(CGRectGetMinX(cell.bounds) + 20.0, CGRectGetMinY(cell.bounds) + 12.0, 180.0, 22.0);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.textColor = TEXTCOLOUR;
    label.textAlignment = NSTextAlignmentLeft;
    label.font = [UIFont systemFontOfSize:15.0];
    if (0 == indexPath.section)
    {
        switch (indexPath.row)
        {
            case 0:
                label.text = NSLocalizedString(@"Disclaimer", nil);
                label.font = [UIFont boldSystemFontOfSize:15];
                break;
            case 1:
                label.text = NSLocalizedString(kManageData, nil);
                break;
            case 2:
                label.text = NSLocalizedString(@"What do the icons mean?", nil);
                break;
        }
    }
    else
    {
        switch (indexPath.row)
        {
            case 0:
                label.text = NSLocalizedString(@"General Info", nil);
                break;

            case 1:
                label.text = NSLocalizedString(@"Testing", nil);
                break;

            case 2:
                label.text = NSLocalizedString(@"Prevention", nil);
                break;

            case 3:
                label.text = NSLocalizedString(@"HIV Drugs", nil);
                break;
        }
    }
    [cell addSubview:label];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *urlString = nil;
    NSString *title = nil;

    if (0 == indexPath.section)
    {
        switch (indexPath.row)
        {
            case 0:
                urlString = @"http://www.istayhealthy.uk.com/get-started/disclaimer";
                title = NSLocalizedString(@"Disclaimer", nil);
                break;
            case 1:
            {
                PWESDataRecoveryHelpViewController *helpController = [[PWESDataRecoveryHelpViewController alloc] initWithStyle:UITableViewStyleGrouped];
//                HelpViewController *helpController = [[HelpViewController alloc] init];
                [self.navigationController pushViewController:helpController animated:YES];
            }
            break;
            case 2:
            {
                IconsTableViewController *iconsController = [[IconsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
                [self.navigationController pushViewController:iconsController animated:YES];
            }
            break;
        }
    }
    else
    {
        switch (indexPath.row)
        {
            case 0:
                urlString = [Utilities generalInfoURLFromLocale];
                title = NSLocalizedString(@"General Info", nil);
                break;

            case 1:
                urlString = [Utilities testingInfoURLFromLocale];
                title = NSLocalizedString(@"Testing", nil);
                break;

            case 2:
                urlString = [Utilities preventionURLFromLocale];
                title = NSLocalizedString(@"Prevention", nil);
                break;

            case 3:
                urlString = [Utilities medListURLFromLocale];
                title = NSLocalizedString(@"HIV Drugs", nil);
                break;
        }
    }

    if (nil != urlString && nil != title)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
//		WebViewController *webViewController = [[WebViewController alloc]initWithURLString:urlString withTitle:title];
//
//		[self.navigationController pushViewController:webViewController animated:YES];
    }
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{
    [self reloadSQLData:notification];
}

@end
