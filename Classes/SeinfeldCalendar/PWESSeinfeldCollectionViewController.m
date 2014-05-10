//
//  PWESSeinfeldCollectionViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/05/2014.
//
//

#import "PWESSeinfeldCollectionViewController.h"
#import "CoreDataManager.h"
#import "BaseCollectionViewCell.h"
#import "SeinfeldCalendar.h"
#import "SeinfeldCalendarEntry.h"
#import "EditSeinfeldCalendarTableViewController.h"
#import "EditMissedMedsTableViewController.h"
#import "PWESCalendar.h"
#import "PWESSeinfeldMonth.h"
#import "PWESMonthlyView.h"

#define kCalendarCollectionCellIdentifier @"CalendarCollectionCellIdentifier"

@interface PWESSeinfeldCollectionViewController ()
@property (nonatomic, strong) NSArray *calendars;
@property (nonatomic, strong) NSArray *currentMeds;
@property (nonatomic, strong) SeinfeldCalendar *currentCalendar;
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
	layout.headerReferenceSize = CGSizeMake(self.view.bounds.size.width - 40, 64);
	layout.minimumInteritemSpacing = 20;
	layout.minimumLineSpacing = 20;

	self.collectionView.collectionViewLayout = layout;
	self.collectionViewLayout = layout;
	[self.collectionViewLayout invalidateLayout];

	[self.collectionView registerClass:[BaseCollectionViewCell class]
	        forCellWithReuseIdentifier:kCalendarCollectionCellIdentifier];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)addButtonPressed:(id)sender
{
	if (nil == self.customPopoverController)
	{
		EditSeinfeldCalendarTableViewController *editController = [[EditSeinfeldCalendarTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:YES];
		editController.preferredContentSize = CGSizeMake(320, 568);
		editController.customPopOverDelegate = self;
		UINavigationController *editNavCtrl = [[UINavigationController alloc] initWithRootViewController:editController];
		[self presentPopoverWithController:editNavCtrl fromBarButton:(UIBarButtonItem *)sender];
	}
	else
	{
		[self hidePopover];
	}
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
	[cell.contentView addSubview:month];
	return cell;
}

#pragma mark - override the notification handlers
- (void)reloadSQLData:(NSNotification *)notification
{
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kSeinfeldCalendar predicate:nil sortTerm:kStartDateLowerCase ascending:NO completion: ^(NSArray *array, NSError *error) {
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
	        self.calendars = [NSArray arrayWithArray:array];
	        for (SeinfeldCalendar * calendar in array)
	        {
	            if (NO == [calendar.isCompleted boolValue])
	            {
	                self.currentCalendar = calendar;
	                break;
				}
			}
	        [self configureCollectionView];
	        [[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:NO completion: ^(NSArray *medsarray, NSError *innererror) {
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
}

@end
