//
//  DashboardViewControllerViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 06/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DashboardViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface DashboardViewControllerViewController ()
@property BOOL isPageControlled;
- (void)setUpScrollView;
@end

@implementation DashboardViewControllerViewController
@synthesize chartScrollView = _chartScrollView;
@synthesize headerView = _headerView;
@synthesize pageControl = _pageControl;
@synthesize pageControlView = _pageControlView;
@synthesize detailedTableView = _detailedTableView;
@synthesize isPageControlled = _isPageControlled;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailedTableView.layer.cornerRadius = 20.0;
    self.detailedTableView.layer.frame = CGRectInset(self.detailedTableView.frame, 20.0, 20.0);
    self.detailedTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.detailedTableView.layer.borderWidth = 1.0;
    self.detailedTableView.layer.masksToBounds = YES;
    
    self.pageControl.currentPage = 0;    
    self.isPageControlled = NO;
    self.pageControlView.layer.cornerRadius = 20.0;
}

- (void)setUpScrollView{
    CGSize contentSize = CGSizeMake(NUMBEROFPAGES * self.chartScrollView.frame.size.width, self.chartScrollView.frame.size.height);
    
    self.chartScrollView.backgroundColor = [UIColor clearColor];
    self.chartScrollView.contentSize = contentSize;
    self.chartScrollView.layer.cornerRadius = 20.0;
    
    [self.chartScrollView setPagingEnabled:YES];
    [self.chartScrollView setAlwaysBounceVertical:NO];
    [self.chartScrollView setAlwaysBounceHorizontal:YES];
    
    for (int i = 0; i < NUMBEROFPAGES; ++i) {
        CGFloat xOffset = (CGFloat)i * self.chartScrollView.frame.size.width;
        CGRect chartFrame = CGRectMake(xOffset, 0, self.chartScrollView.frame.size.width, self.chartScrollView.frame.size.height);
        UIView *chartView = [[UIView alloc]initWithFrame:chartFrame];
        [self.chartScrollView addSubview:chartView];
    }
    
    [self.view addSubview:self.chartScrollView];
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

- (IBAction)changePage:(id)sender{
    self.isPageControlled = YES;
    int page = self.pageControl.currentPage;
    CGRect scrollFrame = self.chartScrollView.frame;
    scrollFrame.origin.x = scrollFrame.size.width * page;
    scrollFrame.origin.y = 0;
    [self.chartScrollView scrollRectToVisible:scrollFrame animated:YES];
}

#pragma mark Table Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUMBEROFPAGES;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(nil == cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%@ at row %d",identifier, indexPath.row];
    return cell;
}


#pragma mark Table Delegate
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    int page = indexPath.row;
    self.isPageControlled = NO;
    self.pageControl.currentPage = page;
    CGRect scrollFrame = self.chartScrollView.frame;
    scrollFrame.origin.x = scrollFrame.size.width * page;
    scrollFrame.origin.y = 0;
    [self.chartScrollView scrollRectToVisible:scrollFrame animated:YES];
}


#pragma mark Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isPageControlled) {
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
