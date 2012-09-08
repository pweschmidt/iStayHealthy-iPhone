//
//  DashboardViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 29/08/2012.
//
//

#import "DashboardViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@interface DashboardViewController ()
@property BOOL isPageControlled;
@property CGRect originalFrame;
- (void)setUpScrollView;
- (void)setUpPageControllerView;
- (void)setUpTableView;
@end

@implementation DashboardViewController
@synthesize detailedTableView = _detailedTableView;
@synthesize scrollView = _scrollView;
@synthesize pageControllerView = _pageControllerView;
@synthesize pageControl = _pageControl;
@synthesize isPageControlled = _isPageControlled;
@synthesize originalFrame = _originalFrame;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setUpScrollView];
    self.originalFrame = self.detailedTableView.frame;
    self.pageControl.currentPage = 0;
    self.isPageControlled = NO;
    self.pageControllerView.layer.cornerRadius = 20.0;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    CGRect frame = self.originalFrame;
    frame.size.height = 120;
    frame.size.width = self.view.frame.size.width;
    self.detailedTableView.frame = frame;
    self.detailedTableView.layer.cornerRadius = 20.0;
    self.detailedTableView.layer.frame = CGRectInset(self.detailedTableView.frame, 20.0, 20.0);
    self.detailedTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.detailedTableView.layer.borderWidth = 1.0;
    self.detailedTableView.layer.masksToBounds = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)setUpScrollView
{
    float xOffset = 20;
    float yOffset = self.view.bounds.size.height - 270;
    float width = self.view.bounds.size.width - 40;
    float height = self.view.bounds.size.height - 260;
    CGRect scrollFrame = CGRectMake(xOffset, yOffset, width, height);
    CGSize contentSize = CGSizeMake(kNumberOfChartViews * scrollFrame.size.width, scrollFrame.size.height);
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.contentSize = contentSize;
    self.scrollView.layer.cornerRadius = 20.0;
    
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setAlwaysBounceVertical:NO];
    [self.scrollView setAlwaysBounceHorizontal:YES];
    
    /*
    for (int i = 0; i < kNumberOfChartViews; ++i) {
        CGFloat xOffset = (CGFloat)i * self.scrollView.frame.size.width;
        CGRect chartFrame = CGRectMake(xOffset, 0, scrollFrame.size.width, scrollFrame.size.height);
        ChartScrollView *chartView = [[ChartScrollView alloc]initWithPageNumber:i andFrame:chartFrame];
        [self.scrollView addSubview:chartView];
    }
     */
    
    [self.view addSubview:self.scrollView];
    
}
- (void)setUpPageControllerView
{

    self.pageControl.currentPage = 0;
    self.isPageControlled = NO;
    
}
- (void)setUpTableView
{
    self.detailedTableView.layer.cornerRadius = 20.0;
    self.detailedTableView.layer.frame = CGRectInset(self.detailedTableView.frame, 20.0, 20.0);
    self.detailedTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.detailedTableView.layer.borderWidth = 1.0;
    self.detailedTableView.layer.masksToBounds = YES;
}

- (IBAction)changePage:(id)sender{
    self.isPageControlled = YES;
    int page = self.pageControl.currentPage;
    CGRect scrollFrame = self.scrollView.frame;
    scrollFrame.origin.x = scrollFrame.size.width * page;
    scrollFrame.origin.y = 0;
    [self.scrollView scrollRectToVisible:scrollFrame animated:YES];
}

#pragma Table Source delegate methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfChartViews;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ at row %d",identifier, indexPath.row];
    return cell;
}

#pragma mark Table Delegate
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    int page = indexPath.row;
    self.isPageControlled = NO;
    self.pageControl.currentPage = page;
    CGRect scrollFrame = self.scrollView.frame;
    scrollFrame.origin.x = scrollFrame.size.width * page;
    scrollFrame.origin.y = 0;
    [self.scrollView scrollRectToVisible:scrollFrame animated:YES];
    
}

#pragma mark Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isPageControlled)
    {
        return;
    }
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isPageControlled = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isPageControlled = NO;
}


@end
