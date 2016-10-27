//
//  PWESSeinfeldCollectionViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/05/2014.
//
//

#import "PWESSeinfeldCollectionViewController.h"
// #import "CoreDataManager.h"
#import "BaseCollectionViewCell.h"
#import "SeinfeldCalendar.h"
#import "SeinfeldCalendarEntry.h"
#import "EditSeinfeldCalendarTableViewController.h"
#import "EditMissedMedsTableViewController.h"
#import "PWESCalendar.h"
#import "PWESSeinfeldMonth.h"
#import "PWESMonthlyView.h"
#import "PWESSeinfeldCalendarReusableView.h"
#import "iStayHealthy-Swift.h"

#define kCalendarCollectionCellIdentifier   @"CalendarCollectionCellIdentifier"
#define kCalendarCollectionHeaderIdentifier @"HeaderIdentifier"
@interface PWESSeinfeldCollectionViewController ()
@property (nonatomic, strong) NSArray *calendars;
@property (nonatomic, strong) NSArray *currentMeds;
@property (nonatomic, strong) SeinfeldCalendar *currentCalendar;
@property (nonatomic, strong) SeinfeldCalendar *lastCalendar;
@property (nonatomic, strong) NSArray *months;

@end

@implementation PWESSeinfeldCollectionViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.months = [NSArray array];

//	self.results = [NSArray array]; //init with empty array
    [self setTitleViewWithTitle:NSLocalizedString(@"Medication Diary", nil)];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(320, 200);
    layout.sectionInset = UIEdgeInsetsMake(10, 0, 20, 0);
    layout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width - 40, 74);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;

    self.collectionView.collectionViewLayout = layout;
    self.collectionViewLayout = layout;
    [self.collectionViewLayout invalidateLayout];

    [self.collectionView registerClass:[BaseCollectionViewCell class]
            forCellWithReuseIdentifier:kCalendarCollectionCellIdentifier];

    [self.collectionView registerClass:[PWESSeinfeldCalendarReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCalendarCollectionHeaderIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
    EditSeinfeldCalendarTableViewController *editController = [[EditSeinfeldCalendarTableViewController alloc] initWithStyle:UITableViewStyleGrouped calendars:self.calendars];

    editController.preferredContentSize = CGSizeMake(320, 568);
    editController.customPopOverDelegate = self;
    editController.resultsDelegate = self;
    UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
    editNavCtrl.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:editNavCtrl animated:YES completion:nil];
}

- (void)configureCollectionView
{
    if (nil == self.currentCalendar)
    {
        return;
    }
    NSInteger months = [[PWESCalendar sharedInstance] monthsBetweenStartDate:self.currentCalendar.startDate
                                                                     endDate:self.currentCalendar.endDate];
    NSMutableArray *monthArray = [NSMutableArray arrayWithCapacity:months];
    for (NSInteger month = 0; month < months; ++month)
    {
        PWESSeinfeldMonth *seinfeldMonth = [PWESSeinfeldMonth monthFromStartDate:self.currentCalendar.startDate
                                                                      monthIndex:month
                                                                  numberOfMonths:months];
        [monthArray addObject:seinfeldMonth];
    }
    self.months = monthArray;
    dispatch_async(dispatch_get_main_queue(), ^{
                       [self.collectionView reloadData];
                   });
//	[self.collectionView.collectionViewLayout invalidateLayout];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.months.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger monthIndex = indexPath.row;
    BaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCalendarCollectionCellIdentifier forIndexPath:indexPath];

    [cell clear];
    [cell transparentBackground];

    PWESSeinfeldMonth *seinfeld = [self.months objectAtIndex:monthIndex];
    PWESMonthlyView *month = [PWESMonthlyView monthlyViewForCalendar:self.currentCalendar
                                                       seinfeldMonth:seinfeld
                                                               frame:cell.contentView.bounds];
    month.resultsDelegate = self;
    [cell.contentView addSubview:month];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view = nil;

    if (UICollectionElementKindSectionHeader == kind)
    {
        PWESSeinfeldCalendarReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCalendarCollectionHeaderIdentifier forIndexPath:indexPath];
        if (nil == self.currentCalendar)
        {
            [headerView showEmptyLabel];
        }
        else
        {
            [headerView showCalendarInHeader:self.lastCalendar];
        }
        view = headerView;
    }

    return view;
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];

    [manager fetchData:kSeinfeldCalendar predicate:nil sortTerm:kEndDateLowerCase ascending:NO completion: ^(NSArray *array, NSError *error) {
         if (nil == array)
         {
             UIAlertView *errorAlert = [[UIAlertView alloc]
                                        initWithTitle:@"Error"
                                                  message:@"Error loading data"
                                                 delegate:nil
                                        cancelButtonTitle:@"Cancel"
                                        otherButtonTitles:nil];
             [errorAlert show];
         }
         else
         {
             self.calendars = nil;
             self.lastCalendar = nil;
             self.calendars = [NSArray arrayWithArray:array];
             for (SeinfeldCalendar * calendar in array)
             {
                 if (![calendar.isCompleted boolValue])
                 {
                     self.currentCalendar = calendar;
                     break;
                 }
                 else
                 {
                     if (nil == self.lastCalendar)
                     {
                         self.lastCalendar = calendar;
                     }
                 }
             }
             [self configureCollectionView];
             [manager fetchData:kMedication predicate:nil sortTerm:kStartDate ascending:NO completion: ^(NSArray *medsarray, NSError *innererror) {
                  if (nil == medsarray)
                  {
                      UIAlertView *errorAlert = [[UIAlertView alloc]
                                                 initWithTitle:@"Error"
                                                           message:@"Error loading data"
                                                          delegate:nil
                                                 cancelButtonTitle:@"Cancel"
                                                 otherButtonTitles:nil];
                      [errorAlert show];
                  }
                  else
                  {
                      self.currentMeds = nil;
                      self.currentMeds = medsarray;
                  }
              }];
         }
     }];
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
    [self reloadSQLData:notification];
}

#pragma mark PWESResultsDelegate methods
- (void)updateCalendarWithSuccess:(BOOL)success
{
    if (nil == self.currentMeds || 0 == self.currentMeds.count)
    {
        return;
    }
    if (success)
    {
        return;
    }
    if (nil == self.customPopoverController)
    {
        EditMissedMedsTableViewController *controller = [[EditMissedMedsTableViewController alloc] initWithStyle:UITableViewStyleGrouped currentMeds:self.currentMeds managedObject:nil];
        controller.preferredContentSize = CGSizeMake(320, 568);
        controller.customPopOverDelegate = self;
        UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentPopoverWithController:editNavCtrl
                                  fromRect:CGRectMake(self.view.frame.size.width / 2 - 160, 10, 320, 50)];
    }
    else
    {
        [self hidePopover];
    }
}

- (void)finishCalendarWithSuccess:(BOOL)success
{
    [self finishCalendarWithEndDate:self.currentCalendar.endDate];
}

- (void)finishCalendarWithEndDate:(NSDate *)endDate;
{
    [self completeCalendarWithEndDate:endDate];
    [self reloadSQLData:nil];
}

- (void)completeCalendarWithEndDate:(NSDate *)endDate
{
    SeinfeldCalendar *calendar = self.currentCalendar;
    NSSet *calendarEntries = calendar.entries;
    double totalCount = (double) calendarEntries.count;
    double days = (double) [[PWESCalendar sharedInstance] daysBetweenStartDate:calendar.startDate
                                                                       endDate:endDate];

    double totalDays = fabs(days);
    double fractionMonitored = totalCount / totalDays;

    __block NSUInteger counter = 0;

    [calendarEntries enumerateObjectsUsingBlock: ^(SeinfeldCalendarEntry *entry, BOOL *stop) {
         if (nil != entry.hasTakenMeds)
         {
             if ([entry.hasTakenMeds boolValue])
             {
                 counter++;
             }
         }
     }];

    double fractionTaken = counter / totalCount;
    double result = (fractionTaken * fractionMonitored) * 100.0;
    if (100.0 < result)
    {
        result = 100.0;
    }
    calendar.score = [NSNumber numberWithDouble:result];
    calendar.isCompleted = [NSNumber numberWithBool:YES];
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
    NSError *error = nil;
    [manager saveContextAndReturnError:&error];

    self.currentCalendar = nil;
}

- (void)removeCalendar
{
    self.currentCalendar = nil;
    [self reloadSQLData:nil];
}

@end
