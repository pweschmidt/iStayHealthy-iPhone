//
//  EditAlertsTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/09/2013.
//
//

#import "EditAlertsTableViewController.h"

@interface EditAlertsTableViewController ()
{
    NSUInteger frequencyIndex;
}
@property (nonatomic, strong) NSArray * editMenu;
@property (nonatomic, strong) NSArray * frequencyArray;
@property (nonatomic, strong) NSMutableArray *titleStrings;
@property (nonatomic, strong) UISegmentedControl *frequencyControl;
@property (nonatomic, strong) UILocalNotification *currentNotification;
- (void)changeFrequency:(id)sender;
@end

@implementation EditAlertsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
  localNotification:(UILocalNotification *)localNotification
{
    self = [super initWithStyle:style managedObject:nil hasNumericalInput:NO];
    if (nil != self)
    {
        _currentNotification = localNotification;
        self.isEditMode = (nil != localNotification);
    }
    return self;
}




- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.isEditMode)
    {
        self.navigationItem.title = NSLocalizedString(@"Edit Alert", nil);
    }
    else
    {
        self.navigationItem.title = NSLocalizedString(@"New Alert", nil);
    }
    self.editMenu = @[kAlertLabel];
    self.titleStrings = [NSMutableArray arrayWithCapacity:self.editMenu.count];
    self.frequencyArray = @[@"1", @"2", @"3", @"4"];
    self.frequencyControl = [[UISegmentedControl alloc] initWithItems:self.frequencyArray];
    self.frequencyControl.selectedSegmentIndex = 0;
    frequencyIndex = 1;
    [self.frequencyControl addTarget:self
                              action:@selector(changeFrequency:)
                    forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setDefaultValues
{
    
}

- (void)save:(id)sender
{
    NSTimeInterval timeInterval = 24.0/(double)frequencyIndex * 60.0 * 60.0;
    NSString *alertText = @"iStayHealthy Alert";
    if (0 < self.textViews.count)
    {
        alertText = [self.textViews objectForKey:[NSNumber numberWithInt:0]];
    }
    for (int alarmIndex = 0; alarmIndex < frequencyIndex; alarmIndex++)
    {
        NSTimeInterval addedSeconds = alarmIndex * timeInterval;
        NSDictionary *userDictionary = [NSDictionary dictionaryWithObject:alertText forKey:kAppNotificationKey];
        
        UILocalNotification *medAlert = [[UILocalNotification alloc]init];
        medAlert.fireDate = (0 == addedSeconds) ? self.date : [self.date dateByAddingTimeInterval:addedSeconds];
        medAlert.timeZone = [NSTimeZone localTimeZone];
        medAlert.repeatInterval = NSDayCalendarUnit;
        medAlert.userInfo = userDictionary;
        medAlert.alertBody = alertText;
        medAlert.alertAction = @"Show me";
        medAlert.soundName = UILocalNotificationDefaultSoundName;
        
        medAlert.applicationIconBadgeNumber = 1;
        [[UIApplication sharedApplication]scheduleLocalNotification:medAlert];
#ifdef APPDEBUG
        NSLog(@"NewAlertDetailViewController::save the alert setting is %@",medAlert);
#endif
    }
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)removeManagedObject
{
    if (!self.isEditMode)
    {
        return;
    }
    [[UIApplication sharedApplication] cancelLocalNotification:self.currentNotification];
    [self.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([self indexPathHasPicker:indexPath] ? kBaseDateCellRowHeight : self.tableView.rowHeight);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self hasInlineDatePicker])
    {
        // we have a date picker, so allow for it in the number of rows in this section
        NSInteger numRows = self.editMenu.count + 1;
        return ++numRows;
    }
    return self.editMenu.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = nil;
    if (0 == indexPath.row)
    {
        identifier = [NSString stringWithFormat:kBaseDateCellRowIdentifier];
    }
    else
    {
        if ([self hasInlineDatePicker])
        {
            identifier = [NSString stringWithFormat:@"DatePickerCell"];
        }
        else
        {
            identifier = [NSString stringWithFormat:@"AlertCell%d",indexPath.row];
        }
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
    }
    if (0 == indexPath.row)
    {
        [self configureDateCell:cell indexPath:indexPath dateType:TimeOnly];
    }
    else
    {
        if ([self hasInlineDatePicker])
        {
            [self configureDatePickerCell:cell indexPath:indexPath];
        }
        else
        {
            NSUInteger titleIndex = (nil == self.datePickerIndexPath) ? indexPath.row - 1 : indexPath.row - 2;
            NSString *localisedText = NSLocalizedString([self.editMenu objectAtIndex:titleIndex], nil);
            [self configureTableCell:cell
                               title:localisedText
                           indexPath:indexPath
                   hasNumericalInput:NO];
        }
        
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 55;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] init];
    footerView.frame = CGRectMake(0, 0, tableView.frame.size.width, 40);
    UILabel *label = [[UILabel alloc]
                      initWithFrame:CGRectMake(20, 10, tableView.bounds.size.width-40, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"Per Day", nil);
    label.textColor = TEXTCOLOUR;
    label.textAlignment = NSTextAlignmentJustified;
    label.font = [UIFont systemFontOfSize:15];
    [footerView addSubview:label];
    self.frequencyControl.frame = CGRectMake(20, 35, tableView.bounds.size.width-40, 25);
    [footerView addSubview:self.frequencyControl];
    return footerView;
}


- (void)changeFrequency:(id)sender
{
    if ([sender isKindOfClass:[UISegmentedControl class]])
    {
        UISegmentedControl *segmenter = (UISegmentedControl *)sender;
        frequencyIndex = segmenter.selectedSegmentIndex + 1;
    }
}

@end
