//
//  DashboardViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 18/09/2013.
//
//

#import "DashboardViewController.h"
#import "Constants.h"
#import "Results.h"
#import "Medication.h"
#import "PWESDashboardView.h"
#import "PWESDataManager.h"
#import "PWESDataNTuple.h"
#import "PWESResultsTypes.h"
#import "CoreDataManager.h"
#import "Utilities.h"
//#import "EditResultsTableViewController.h"
#import "EditChartsTableViewController.h"

#define kDashboardScrollViewTag 1001

@interface DashboardViewController ()
{
	CGRect scrollFrame;
	CGRect pageFrame;
}
@property (nonatomic, assign) BOOL pageControlUsed;
@property (nonatomic, strong) NSMutableArray *dashboardTypes;
@property (nonatomic, strong) NSArray *selectedItems;
@end

@implementation DashboardViewController


- (void)viewDidLoad
{
	[super viewDidLoad];
	[self setTitleViewWithTitle:NSLocalizedString(@"Charts", nil)];
	[self configureScrollView];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *archivedData = [defaults objectForKey:kDashboardTypes];
	NSMutableArray *selected = nil;
	if (nil != archivedData)
	{
		selected = [NSKeyedUnarchiver unarchiveObjectWithData:archivedData];
	}
	else
	{
		selected = (NSMutableArray *)@[kCD4AndVL,
		                               kCD4PercentAndVL,
		                               kGlucose,
		                               kTotalCholesterol,
		                               kHDL,
		                               kSystole,
		                               kWeight,
		                               kCardiacRiskFactor];
	}
	[self selectedCharts:selected];
	[self resetPageController];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(addButtonPressed:)];
}

- (void)addButtonPressed:(id)sender
{
	EditChartsTableViewController *controller = [[EditChartsTableViewController alloc]
	                                             initWithSelectedItems:self.selectedItems];
	controller.chartSelector = self;
	if ([Utilities isIPad])
	{
		controller.preferredContentSize = CGSizeMake(320, 568);
		controller.customPopOverDelegate = self;
		UINavigationController *navController = [[UINavigationController alloc]
		                                         initWithRootViewController:controller];
		[self presentPopoverWithController:navController fromBarButton:(UIBarButtonItem *)sender];
	}
	else
	{
		[self.navigationController pushViewController:controller animated:YES];
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if (![Utilities isIPad])
	{
		return;
	}
	[UIView animateWithDuration:duration animations: ^{
	    self.chartScroller.alpha = 0.0;
	} completion: ^(BOOL finished) {
	    [self clearScrollView];
	}];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if (![Utilities isIPad])
	{
		return;
	}
	[UIView animateWithDuration:1.0 animations: ^{
	} completion: ^(BOOL finished) {
	    [self configureScrollView];
	    [self resetPageController];
	    self.chartScroller.alpha = 1.0f;
	}];
}

- (void)reloadSQLData:(NSNotification *)notification
{
	[[CoreDataManager sharedInstance] fetchDataForEntityName:kResults predicate:nil sortTerm:kResultsDate ascending:YES completion: ^(NSArray *results, NSError *resultsError) {
	    if (nil == results)
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
	        [[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:YES completion: ^(NSArray *meds, NSError *medError) {
	            if (nil == meds)
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
	                [self buildDashBoardForResults:results medications:meds];
				}
			}];
		}
	}];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)changePage:(id)sender
{
	long page = self.pageController.currentPage;
	CGRect frame = self.chartScroller.frame;
	frame.origin.x = frame.size.width * page;
	frame.origin.y = 0;
	[self.chartScroller scrollRectToVisible:frame animated:YES];
	self.pageControlUsed = YES;
}

- (void)buildDashBoardForResults:(NSArray *)results
                     medications:(NSArray *)medications
{
	if (nil == results && nil == medications)
	{
		return;
	}
	CGFloat offset = 20;
	NSUInteger viewIndex = 0;
	for (PWESResultsTypes *types in self.dashboardTypes)
	{
		NSError *error = nil;
		PWESDataNTuple *ntuple = [PWESDataNTuple nTupleWithRawResults:results
		                                               rawMedications:medications
		                                         rawMissedMedications:nil
		                                                        types:types
		                                                        error:&error];
		if (ntuple)
		{
			CGFloat x = self.chartScroller.frame.origin.x + self.chartScroller.frame.size.width * viewIndex + offset;
			CGFloat y = 0;
			CGFloat width = self.chartScroller.frame.size.width - 2 * offset;
			CGFloat height = self.chartScroller.frame.size.height;
			CGRect frame = CGRectMake(x, y, width, height);
			PWESDashboardView *dashboard = [PWESDashboardView
			                                dashboardViewWithFrame:frame
			                                                nTuple:ntuple
			                                                 types:types];
			[self.chartScroller addSubview:dashboard];
			viewIndex++;
		}
	}
}

- (void)startAnimation:(NSNotification *)notification
{
	NSLog(@"DashboardViewController:startAnimation with name %@", notification.name);
}

- (void)stopAnimation:(NSNotification *)notification
{
	NSLog(@"DashboardViewController:stopAnimation with name %@", notification.name);
}

- (void)handleError:(NSNotification *)notification
{
	NSLog(@"DashboardViewController:handleError with name %@", notification.name);
}

- (void)handleStoreChanged:(NSNotification *)notification
{
	NSLog(@"DashboardViewController:handleStoreChanged with name %@", notification.name);
}

#pragma mark UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (self.pageControlUsed)
	{
		return;
	}
	scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
	CGFloat pageWidth = scrollView.frame.size.width;
	int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	self.pageController.currentPage = page;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	self.pageControlUsed = NO;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	self.pageControlUsed = NO;
}

#pragma mark ChartSelector method
- (void)selectedCharts:(NSArray *)selectedCharts
{
	self.selectedItems = selectedCharts;
	if (nil == self.dashboardTypes)
	{
		self.dashboardTypes = [NSMutableArray array];
	}
	else
	{
		[self.dashboardTypes removeAllObjects];
	}
	for (NSString *type in selectedCharts)
	{
		if ([type isEqualToString:kCD4AndVL])
		{
			PWESResultsTypes *cd4VLType = [PWESResultsTypes resultsTypeWithMainType:kCD4 secondaryType:kViralLoad wantsMedLine:YES wantsMissedMedLine:NO];
			[self.dashboardTypes addObject:cd4VLType];
		}
		else if ([type isEqualToString:kCD4PercentAndVL])
		{
			PWESResultsTypes *cd4VLType = [PWESResultsTypes resultsTypeWithMainType:kCD4Percent secondaryType:kViralLoad wantsMedLine:YES wantsMissedMedLine:NO];
			[self.dashboardTypes addObject:cd4VLType];
		}
		else
		{
			PWESResultsTypes *singleType = [PWESResultsTypes resultsTypeWithType:type wantsMedLine:NO wantsMissedMedLine:NO];
			[self.dashboardTypes addObject:singleType];
		}
	}
	[self resetPageController];
}

#pragma mark private
- (void)clearScrollView
{
	if (nil != self.chartScroller)
	{
		[self.chartScroller.subviews enumerateObjectsUsingBlock: ^(UIView *obj, NSUInteger idx, BOOL *stop) {
		    [obj removeFromSuperview];
		}];
		[self.chartScroller removeFromSuperview];
		self.chartScroller = nil;
	}
}

- (void)configureScrollView
{
	UIScrollView *scrollView = [[UIScrollView alloc] init];

	CGFloat xOffset = 0;
	CGFloat yScrollOffset = 95;
	CGFloat scrollHeight = self.view.bounds.size.height - 188;
	CGFloat scrollWidth = self.view.bounds.size.width;
	CGFloat yPageOffset = yScrollOffset + scrollHeight + 5;

	scrollFrame = CGRectMake(xOffset, yScrollOffset, scrollWidth, scrollHeight);
	pageFrame = CGRectMake(xOffset, yPageOffset, scrollWidth, 36);
	scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
	[self.view addSubview:scrollView];


	self.chartScroller = scrollView;
	self.chartScroller.backgroundColor = [UIColor clearColor];
	self.chartScroller.delegate = self;
	self.chartScroller.scrollsToTop = YES;
	self.chartScroller.pagingEnabled = YES;
}

- (void)resetPageController
{
	if (nil != self.pageController)
	{
		[self.pageController removeFromSuperview];
	}
	UIPageControl *pager = [[UIPageControl alloc] initWithFrame:pageFrame];
	self.pageController = pager;
	self.pageController.backgroundColor = [UIColor clearColor];
	self.pageController.tintColor = [UIColor lightGrayColor];
	self.pageController.pageIndicatorTintColor = [UIColor lightGrayColor];
	self.pageController.currentPageIndicatorTintColor = DARK_RED;
	[self.pageController addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
	self.chartScroller.contentSize = CGSizeMake(self.view.bounds.size.width * self.dashboardTypes.count, self.chartScroller.frame.size.height);
	self.pageController.numberOfPages = self.dashboardTypes.count;
	self.pageController.currentPage = 0;
	[self.view addSubview:pager];
	[self reloadSQLData:nil];
}

@end
