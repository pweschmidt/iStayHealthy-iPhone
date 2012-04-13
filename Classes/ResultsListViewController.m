//
//  ResultsListViewController.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 04/01/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResultsListViewController.h"
#import "iStayHealthyAppDelegate.h"
#import "iStayHealthyRecord.h"
#import "ResultDetailViewController.h"
#import "NSArray-Set.h"
#import "Results.h"
#import "GeneralSettings.h"
#import "ResultChangeViewController.h"

@implementation ResultsListViewController
@synthesize allResults/*, headerView*/;


#pragma mark -
#pragma mark View lifecycle

/**
 load/setup view
 */
- (void)viewDidLoad {
    [super viewDidLoad];
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(loadResultDetailViewController)];
	self.navigationItem.rightBarButtonItem = addButton;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.tableView.rowHeight = 57.0;
    CGRect pozFrame = CGRectMake(CGRectGetMinX(headerView.bounds)+20, CGRectGetMinY(headerView.bounds)+2, 47.0, 30.0);
    UIButton *pozButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [pozButton setFrame:pozFrame];
    [pozButton setBackgroundImage:[UIImage imageNamed:@"poz75.jpg"] forState:UIControlStateNormal];
    [pozButton addTarget:self action:@selector(loadWebView:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:pozButton];
/*
    UINavigationBar *navBar = self.navigationController.navigationBar;
    if (navBar) {
        CGRect titleFrame = CGRectMake(CGRectGetMinX(navBar.bounds)+223.0, CGRectGetMinY(navBar.bounds)+5.0, 47.0, 30.0);
        UILabel *pozLabel = [[[UILabel alloc]initWithFrame:titleFrame]autorelease];
        [pozLabel setBackgroundColor:[UIColor clearColor]];
        UIImageView *pillView = [[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"poz75.jpg"]]autorelease];
        [pozLabel addSubview:pillView];
        [navBar addSubview:pozLabel];
    }
*/	
	
}

/**
 loads the ResultDetailViewController
 */
- (void)loadResultDetailViewController{
	ResultDetailViewController *newRecordView = [[ResultDetailViewController alloc] initWithNibName:@"ResultDetailViewController" bundle:nil];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:newRecordView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	newRecordView.record = masterRecord;
	[navigationController release];
}

- (void)loadResultChangeViewController:(int)row{
	ResultChangeViewController *changeRecordView = [[ResultChangeViewController alloc] initWithNibName:@"ResultChangeViewController" bundle:nil];
    changeRecordView.results = (Results *)[allResults objectAtIndex:row];
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:changeRecordView];
	UINavigationBar *navigationBar = [navigationController navigationBar];
	navigationBar.tintColor = [UIColor blackColor];
	[self presentModalViewController:navigationController animated:YES];
	[navigationController release];
}


/**
 before view appears the data tables are being updated
 @animated
 */
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];	
	NSSet *results = masterRecord.results;
	if (0 != [results count]) {
		self.allResults = [NSArray arrayByOrderingSet:results byKey:@"ResultsDate" ascending:YES reverseOrder:YES];
	}
	else {//if empty - simply map to empty set
		self.allResults = (NSMutableArray *)results;
	}

	[self.tableView reloadData];	
}



#pragma mark -
#pragma mark Table view data source
/**
 only 1 section
 @tableView
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

/**
 returns number of rows == number of saved results
 @tableView
 @section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.allResults count];
}

/**
 returns cell height == 60.0
 @tableView
 @indexPath
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return 60.0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (0 == [self.allResults count]) {
        return NSLocalizedString(@"No Results Entered",nil);
    }
    else
        return @"";
}


/**
 configures the result cell
 @cell
 @indexPath
 */
- (void)configureResultCell:(ResultCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSUInteger count = [self.allResults count];

	if (indexPath.row >= count) {
		return;
	}
	Results *current = (Results *)[self.allResults objectAtIndex:indexPath.row];
	int cd4 = [current.CD4 intValue];
	int vl = [current.ViralLoad intValue]; 
    float cd4Percent = [current.CD4Percent floatValue];

	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init]autorelease];
	formatter.dateFormat = @"dd MMM YYYY";
	
	cell.dateLabel.text = [formatter stringFromDate:current.ResultsDate];
	cell.cd4TitleLabel.text = NSLocalizedString(@"CD4 Count",nil);
    cell.cd4Label.text = [NSString stringWithFormat:@"%d",cd4];
	if (350 <= cd4) {
		cell.cd4Label.textColor = DARK_GREEN;
	}
	else if (200 <= cd4 && 350 > cd4){
		cell.cd4Label.textColor = DARK_YELLOW;
	}
	else if( 200 > cd4 && 0 < cd4){
		cell.cd4Label.textColor = DARK_RED;
	}
    else{
        cell.cd4Label.text = NSLocalizedString(@"n/a",nil);
        cell.cd4Label.textColor = [UIColor lightGrayColor];
    }
        

    cell.cd4PercentTitleLabel.text = NSLocalizedString(@"CD4 %",nil);
    cell.cd4PercentLabel.text = [NSString stringWithFormat:@"%2.1f%%",cd4Percent];
    if (21.0 <= cd4Percent) {
        cell.cd4PercentLabel.textColor = DARK_GREEN;
    }
    else if (15.0 <= cd4Percent && 21.0 > cd4Percent) {
        cell.cd4PercentLabel.textColor = DARK_YELLOW;
    }
    else if(15.0 > cd4Percent && 0.0 < cd4Percent){
        cell.cd4PercentLabel.textColor = DARK_RED;
    }
    else{
        cell.cd4PercentLabel.text = NSLocalizedString(@"n/a",nil);
        cell.cd4PercentLabel.textColor = [UIColor lightGrayColor];
    }



	cell.viralLoadTitleLabel.text = NSLocalizedString(@"Viral Load",nil);
	if (40 >= vl) {
		cell.viralLoadLabel.text = NSLocalizedString(@"undetectable",nil);
		cell.viralLoadLabel.textColor = DARK_GREEN;
	}
    else if(0.0 > vl){
        cell.viralLoadLabel.text = NSLocalizedString(@"n/a",nil);
        cell.viralLoadLabel.textColor = [UIColor lightGrayColor];
    }
	else {
		cell.viralLoadLabel.text = [NSString stringWithFormat:@"%d",vl];
		if (100000 <= vl && 500000 > vl) {
			cell.viralLoadLabel.textColor = DARK_YELLOW;
		}
		if (500000 <= vl) {
			cell.viralLoadLabel.textColor = DARK_RED;
		}
	}

}

/**
 loads/sets up the cells
 @tableView
 @indexPath
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    ResultCell *cell = (ResultCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[self configureResultCell:cell atIndexPath:indexPath];
		
    return (UITableViewCell *)cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{    
    [self loadResultChangeViewController:indexPath.row];
}


/**
 only row deletion is enabled. row is removed and entry is deleted from the database
 @tableView
 @editingStyle
 @indexPath
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete && 0 == indexPath.section) {
		Results *results = (Results *)[self.allResults objectAtIndex:indexPath.row];
		[masterRecord removeResultsObject:results];
		[self.allResults removeObject:results];
		NSManagedObjectContext *context = results.managedObjectContext;
		[context deleteObject:results];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
		NSError *error = nil;
		if (![context save:&error]) {
#ifdef APPDEBUG
			NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
#endif
			abort();
		}
    }   
}


#pragma mark -
#pragma mark Memory management

/**
 handle memory warnings
 */
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
/**
 unload
 */
- (void)viewDidUnload {
	[super viewDidUnload];
}

/**
 dealloc
 */
- (void)dealloc {
	[allResults release];
//    [headerView release];
    [super dealloc];
}


@end

