//
//  BaseTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/08/2013.
//
//

#import "BaseTableViewController.h"
#import "CoreDataConstants.h"
#import <DropboxSDK/DropboxSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "Utilities.h"
#import "Menus.h"
#import "UILabel+Standard.h"
#import "iStayHealthy-Swift.h"

@interface BaseTableViewController ()
@property (nonatomic, assign) BOOL hamburgerMenuIsShown;
@property (nonatomic, assign) BOOL addMenuIsShown;
@end

@implementation BaseTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGRect frame = self.view.bounds;
    frame = CGRectMake(frame.origin.x, frame.origin.y + 64, frame.size.width, frame.size.height - 64);
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    tableView.backgroundColor = DEFAULT_BACKGROUND;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    self.markedObject = nil;
    self.markedIndexPath = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass of %@", NSStringFromSelector(_cmd), NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (void)deselect:(id)sender
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow]
                                  animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - handle rotations (iPad only)
- (BOOL)shouldAutorotate
{
    if ([Utilities isIPad])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    if ([Utilities isIPad])
    {
        return UIInterfaceOrientationMaskAll;
    }
    else
    {
        return UIInterfaceOrientationMaskPortrait;
    }
}

- (void)showDeleteAlertView
{
    PWESAlertAction *cancel = [[PWESAlertAction alloc] initWithAlertButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel action:nil];
    PWESAlertAction *delete = [[PWESAlertAction alloc] initWithAlertButtonTitle:NSLocalizedString(@"Yes", @"Yes") style:UIAlertActionStyleDestructive action:^{
        [self removeSQLEntry];
    }];
    
    [PWESAlertHandler.alertHandler showAlertView:NSLocalizedString(@"Delete?", @"Delete?") message:NSLocalizedString(@"Do you want to delete this entry?", @"Do you want to delete this entry?") presentingController:self actions:@[cancel, delete]];
    
}

- (void)removeSQLEntry
{
    if (nil == self.markedObject)
    {
        return;
    }
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
    NSError *error = nil;

    [manager removeManagedObject:self.markedObject error:&error];
    if (nil == error)
    {
        [manager saveContextAndReturnError:&error];
    }
    self.markedObject = nil;
    self.markedIndexPath = nil;
}

#pragma mark animation

- (void)createIndicatorsForHeaderView:(UIView *)headerView
{
    UILabel *label = [UILabel standardLabel];

    label.text = @"";
    label.frame = CGRectMake(80, 0, self.view.bounds.size.width - 100, 36);
    [headerView addSubview:label];
    self.tableActivityLabel = label;
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.hidesWhenStopped = YES;
    indicator.frame = CGRectMake(20, 0, 36, 36);
    [headerView addSubview:indicator];
    self.tableIndicatorView = indicator;
}

- (void)animateTableViewWithText:(NSString *)text
{
    if (nil != self.tableActivityLabel)
    {
        self.tableActivityLabel.text = text;
    }
    if (nil != self.tableIndicatorView && !self.tableIndicatorView.isAnimating)
    {
        [self.tableIndicatorView startAnimating];
    }
}

- (void)stopAnimateTableViewWithText:(NSString *)text
{
    if (nil != self.tableActivityLabel)
    {
        self.tableActivityLabel.text = @"";
    }
    if (nil != self.tableIndicatorView && self.tableIndicatorView.isAnimating)
    {
        [self.tableIndicatorView stopAnimating];
    }
}

@end
