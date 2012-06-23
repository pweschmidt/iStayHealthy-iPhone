//
//  MoreBloodResultsViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 23/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoreBloodResultsViewController.h"
#import "GeneralSettings.h"
#import "ChartSettings.h"
#import <QuartzCore/QuartzCore.h>
@interface MoreBloodResultsViewController ()

@end

@implementation MoreBloodResultsViewController
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithResults:(NSDictionary *)results{
    self = [super initWithResults:results nibName:@"MoreBloodResultsViewController"];
    if (self) {
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];

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



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tag = indexPath.row + 1000;
    NSString *identifier = @"ResultValueCell";
    ResultValueCell *resultCell = (ResultValueCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == resultCell) {
        NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"ResultValueCell" owner:self options:nil];
        for (id currentObject in cellObjects) {
            if ([currentObject isKindOfClass:[ResultValueCell class]]) {
                resultCell = (ResultValueCell *)currentObject;
                break;
            }
        } 
        [resultCell setDelegate:self];
    }
    resultCell.inputTitle.textColor = TEXTCOLOUR;
    resultCell.colourCodeView.backgroundColor = DARK_RED;
    resultCell.colourCodeView.layer.cornerRadius = 5;
    resultCell.tag = tag;
    int row = indexPath.row;
    NSNumber *value = nil;
    switch (row) {
        case 0:
        {
            resultCell.inputTitle.text = NSLocalizedString(@"Glucose", @"Glucose");
            resultCell.inputValueKind = FLOATINPUT;
            value = [self.resultsDictionary objectForKey:@"glucose"];
            break;
        }
        case 1:
        {
            resultCell.inputTitle.text = NSLocalizedString(@"Total Cholesterol", @"Total Cholesterol");
            resultCell.inputValueKind = FLOATINPUT;
            value = [self.resultsDictionary objectForKey:@"cholesterol"];
            break;
        }
        case 2:
        {
            resultCell.inputTitle.text = NSLocalizedString(@"HDL", @"HDL");
            resultCell.inputValueKind = FLOATINPUT;
            value = [self.resultsDictionary objectForKey:@"hdl"];
            break;
        }
        case 3:
        {
            resultCell.inputTitle.text = NSLocalizedString(@"LDL", @"LDL");
            resultCell.inputValueKind = FLOATINPUT;
            value = [self.resultsDictionary objectForKey:@"ldl"];
            break;
        }
    }
    if (nil != value) {
        float fValue = [value floatValue];
        if (0 < fValue) {
            resultCell.inputValueField.text = [NSString stringWithFormat:@"%3.2f",fValue];
            resultCell.inputValueField.textColor = [UIColor blackColor];
        }
    }
    return resultCell;
    
}

#pragma mark - Result Value cell delegate method
- (void)setValueString:(NSString *)valueString withTag:(int)tag{
    NSLog(@"MoreBloodResultsViewController::setValueString with %@ and tag %d",valueString, tag);
    [self.moreBloodResultsDelegate setResultString:valueString forTag:tag];
}
@end
