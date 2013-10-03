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
#import "PWESGraph.h"
#import "PWESDashboardView.h"
#import "PWESDataManager.h"
#import "PWESDataNTuple.h"
#import "CoreDataManager.h"
#import "GeneralSettings.h"
#import "EditResultsTableViewController.h"

@interface DashboardViewController ()
{
    CGRect scrollFrame;
    CGRect pageFrame;
}
@property (nonatomic, assign) BOOL pageControlUsed;
@property (nonatomic, strong) NSMutableArray *dashboardTypes;
@end

@implementation DashboardViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Charts", nil);
    CGFloat xOffset = 0;
    CGFloat yScrollOffset = 95;
    CGFloat scrollHeight = self.view.frame.size.height - 188;
    CGFloat scrollWidth = self.view.frame.size.width;
    CGFloat yPageOffset = yScrollOffset + scrollHeight + 5;
    
    scrollFrame = CGRectMake(xOffset, yScrollOffset, scrollWidth, scrollHeight);
    pageFrame = CGRectMake(xOffset, yPageOffset, scrollWidth, 36);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    [self.view addSubview:scrollView];
    

    self.chartScroller = scrollView;
    self.chartScroller.backgroundColor = [UIColor clearColor];
    self.chartScroller.delegate = self;
    self.chartScroller.scrollsToTop = YES;
    self.chartScroller.pagingEnabled = YES;
    self.dashboardTypes = [NSMutableArray array];
    NSArray *cd4VL = @[kCD4, kViralLoad];
    NSArray *cd4PVL = @[kCD4Percent, kViralLoad];
    NSArray *bloodpressure = @[kSystole];
    NSArray *cholesterol = @[kTotalCholesterol, kHDL];
    NSArray *weight = @[kWeight];
    NSArray *glucose = @[kGlucose];
    NSArray *risk = @[kCardiacRiskFactor];
    [self.dashboardTypes addObject:cd4VL];
    [self.dashboardTypes addObject:cd4PVL];
    [self.dashboardTypes addObject:bloodpressure];
    [self.dashboardTypes addObject:cholesterol];
    [self.dashboardTypes addObject:weight];
    [self.dashboardTypes addObject:glucose];
    [self.dashboardTypes addObject:risk];
    
    
    UIPageControl *pager = [[UIPageControl alloc] initWithFrame:pageFrame];
    self.pageController = pager;
    self.pageController.backgroundColor = [UIColor clearColor];
    self.pageController.tintColor = [UIColor lightGrayColor];
    self.pageController.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageController.currentPageIndicatorTintColor = DARK_RED;
    [self.pageController addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    self.chartScroller.contentSize = CGSizeMake(self.view.frame.size.width * self.dashboardTypes.count, self.chartScroller.frame.size.height);
    self.pageController.numberOfPages = self.dashboardTypes.count;
    self.pageController.currentPage = 0;
    [self.view addSubview:pager];
}

- (void)addButtonPressed:(id)sender
{
    EditResultsTableViewController *controller = [[EditResultsTableViewController alloc] initWithStyle:UITableViewStyleGrouped managedObject:nil hasNumericalInput:YES];
    [self.navigationController pushViewController:controller animated:YES];
}


- (void)reloadSQLData:(NSNotification *)notification
{
    __weak DashboardViewController *weakSelf = self;
    [[CoreDataManager sharedInstance] fetchDataForEntityName:kResults predicate:nil sortTerm:kResultsDate ascending:NO completion:^(NSArray *results, NSError *resultsError) {
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
            [[CoreDataManager sharedInstance] fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:NO completion:^(NSArray *meds, NSError *medError) {
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
                    [weakSelf buildDashBoardForResults:results medications:meds];
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
    int page = self.pageController.currentPage;
    CGRect frame = self.chartScroller.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.chartScroller scrollRectToVisible:frame animated:YES];
    self.pageControlUsed = YES;
}

- (void)buildDashBoardForResults:(NSArray *)results
                     medications:(NSArray *)medications
{
    if (nil == results && nil == medications) {
        return;
    }
    CGFloat offset = 20;
    NSUInteger viewIndex = 0;
    for (NSArray * types in self.dashboardTypes)
    {
        NSError *error = nil;
        PWESDataNTuple *ntuple = [PWESDataNTuple initWithRawResults:results
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
                                            medications:medications
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
@end
