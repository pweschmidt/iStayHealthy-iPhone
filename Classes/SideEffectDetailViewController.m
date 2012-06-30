//
//  SideEffectDetailViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 27/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SideEffectDetailViewController.h"
#import "GeneralSettings.h"
#import <QuartzCore/QuartzCore.h>

@interface SideEffectDetailViewController ()
@property (nonatomic, strong) NSMutableArray *sideEffectArray;
@property (nonatomic, strong) UITableViewCell *selectedCell;
@property (nonatomic, strong) NSNumber *seriousnessIndex;
@property (nonatomic, strong) NSDate *effectDate;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation SideEffectDetailViewController
@synthesize sideEffectTableView = _sideEffectTableView;
@synthesize sideEffectArray = _sideEffectArray;
@synthesize seriousnessControl = _seriousnessControl;
@synthesize selectedCell = _selectedCell;
@synthesize seriousnessIndex = _seriousnessIndex;
@synthesize dateLabel = _dateLabel;
@synthesize dateButton = _dateButton;
@synthesize effectDate = _effectDate;
@synthesize formatter = _formatter;
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
    NSString *effectsList = [[NSBundle mainBundle] pathForResource:@"SideEffects" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:effectsList];
    NSArray *list = [dict valueForKey:@"SideEffectArray"];
    
    self.sideEffectArray = [NSMutableArray arrayWithArray:list];
    
    self.sideEffectTableView.layer.cornerRadius = 20.0;
    self.sideEffectTableView.layer.frame = CGRectInset(self.sideEffectTableView.frame, 20.0, 20.0);
    self.sideEffectTableView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.sideEffectTableView.layer.borderWidth = 1.0;
    self.sideEffectTableView.layer.masksToBounds = YES;
    self.seriousnessIndex = [NSNumber numberWithInt:0];
    self.seriousnessControl.selectedSegmentIndex = 0;
	self.formatter = [[NSDateFormatter alloc] init];
	self.formatter.dateFormat = @"dd MMM YY";
    
    self.effectDate = [NSDate date];
    self.dateLabel.textColor = TEXTCOLOUR;
    self.dateLabel.text = [self.formatter stringFromDate:self.effectDate];
    self.selectedCell = nil;
}

- (void)viewDidUnload
{
    self.selectedCell = nil;
    self.sideEffectArray = nil;
    self.seriousnessIndex = nil;
    [super viewDidUnload];
}

- (IBAction)seriousnessChanged:(id)sender{
    self.seriousnessIndex = [NSNumber numberWithInt:self.seriousnessControl.selectedSegmentIndex];
}

- (IBAction)setDate:(id)sender{
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void) deselect: (id) sender
{
	[self.sideEffectTableView 
     deselectRowAtIndexPath:[self.sideEffectTableView indexPathForSelectedRow] 
     animated:YES];
}


#pragma mark Table Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sideEffectArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [NSString stringWithFormat:@"Row%d",indexPath.row];    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if(nil == cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.textColor = TEXTCOLOUR;
    cell.textLabel.text = [self.sideEffectArray objectAtIndex:indexPath.row];
    if ([cell.textLabel.text isEqualToString:[self.sideEffectArray lastObject]]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    else {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    if (cell == self.selectedCell) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark Table Delegate
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{

    NSLog(@"SideEffectDetailViewController::selected row %d",indexPath.row);

    if (indexPath.row == self.sideEffectArray.count - 1) {
        NSLog(@"SideEffectDetailViewController::selected row %d. Is last row",indexPath.row);
        return;
    }
    if (nil != self.selectedCell) {
        self.selectedCell.accessoryType = UITableViewCellAccessoryNone;
        self.selectedCell = nil;
    }
    UITableViewCell *cell = [self.sideEffectTableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectedCell = cell;
    [self performSelector:@selector(deselect:) withObject:nil afterDelay:0.5f];
}

@end
