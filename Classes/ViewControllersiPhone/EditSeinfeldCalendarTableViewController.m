//
//  EditSeinfeldCalendarTableViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 03/01/2014.
//
//

#import "EditSeinfeldCalendarTableViewController.h"
#import "Constants.h"
#import "CoreDataManager.h"
#import "SeinfeldCalendar.h"

@interface EditSeinfeldCalendarTableViewController ()
@property (nonatomic, strong) UISegmentedControl *calendarSegmentControl;
@property (nonatomic, strong) NSArray *calendars;
@property (nonatomic, strong) NSMutableArray *completedCalendars;
@property (nonatomic, strong) SeinfeldCalendar *currentCalendar;
@property (nonatomic, assign) BOOL hasCalendarRunning;
@end

@implementation EditSeinfeldCalendarTableViewController

- (id)initWithStyle:(UITableViewStyle)style calendars:(NSArray *)calendars
{
    self = [super initWithStyle:style managedObject:nil hasNumericalInput:NO];
    if (nil != self)
    {
        _calendars = calendars;
        _currentCalendar = nil;
        _hasCalendarRunning = NO;
    }
    return self;
}

- (void)populateCalendars
{
    if (nil == self.calendars || 0 == self.calendars.count)
    {
        self.completedCalendars = [NSMutableArray array];
        return;
    }
    for (SeinfeldCalendar *calendar in self.calendars)
    {
        if (calendar.isCompleted)
        {
            [self.completedCalendars addObject:calendar];
        }
        else
        {
            self.currentCalendar = calendar;
            self.hasCalendarRunning = YES;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self populateCalendars];
    self.navigationItem.title = NSLocalizedString(@"Edit Med. Diary", nil);
    NSArray *menuTitles = @[@"1", @"2", @"3", @"4"];
    self.calendarSegmentControl = [[UISegmentedControl alloc] initWithItems:menuTitles];
    CGFloat width = self.tableView.bounds.size.width;
    CGFloat segmentWidth = width - 2 * 20;
    self.calendarSegmentControl.frame = CGRectMake(20, 3, segmentWidth, 30);
    self.calendarSegmentControl.tintColor = TINTCOLOUR;
    self.calendarSegmentControl.selectedSegmentIndex = 0;
    [self.calendarSegmentControl addTarget:self action:@selector(indexDidChangeForSegment) forControlEvents:UIControlEventValueChanged];
}

- (void)save:(id)sender
{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section)
    {
        return ([self indexPathHasPicker:indexPath] ? kBaseDateCellRowHeight : self.tableView.rowHeight);
    }
    else
    {
        return self.tableView.rowHeight;
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section)
    {
        return ([self hasInlineDatePicker] ? 2 : 1);
    }
    else
    {
        return self.completedCalendars.count;
    }
}

- (void)indexDidChangeForSegment
{
    
}
@end
