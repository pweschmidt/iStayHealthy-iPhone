//
//  SeinfeldCalendarViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 21/09/2013.
//
//

#import "SeinfeldCalendarViewController.h"

@interface SeinfeldCalendarViewController ()

@end

@implementation SeinfeldCalendarViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Medication Diary", nil);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
}
- (void)startAnimation:(NSNotification *)notification
{
}
- (void)stopAnimation:(NSNotification *)notification
{
}
- (void)handleError:(NSNotification *)notification
{
}

- (void)handleStoreChanged:(NSNotification *)notification
{
}

@end
