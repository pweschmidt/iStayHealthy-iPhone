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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (0 == section) {
        return 1;
    }
    if (1 == section) {
        return 3;
    }
    else {
        return 4;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *text = @"";

    if (1 == section) {
        text = NSLocalizedString(@"Lipids", @"Lipids");
    }
    if (2 == section) {
        text = NSLocalizedString(@"Full Blood Count", @"Blood Count");
    }
    return text;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        int tag = 1000;
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
        NSNumber *value = nil;
        resultCell.inputTitle.text = NSLocalizedString(@"Glucose", @"Glucose");
        resultCell.inputValueKind = FLOATINPUT;
        value = [self.resultsDictionary objectForKey:@"glucose"];
        if (nil != value) {
            float fValue = [value floatValue];
            if (0 < fValue) {
                resultCell.inputValueField.text = [NSString stringWithFormat:@"%3.2f",fValue];
                resultCell.inputValueField.textColor = [UIColor blackColor];
            }
        }
        return resultCell;
    }
    if (1 == indexPath.section) {
        int tag = indexPath.row + 1001;
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
                resultCell.inputTitle.text = NSLocalizedString(@"Total Cholesterol", @"Total Cholesterol");
                resultCell.inputValueKind = FLOATINPUT;
                value = [self.resultsDictionary objectForKey:@"cholesterol"];
                break;
            }
            case 1:
            {
                resultCell.inputTitle.text = NSLocalizedString(@"HDL", @"HDL");
                resultCell.inputValueKind = FLOATINPUT;
                value = [self.resultsDictionary objectForKey:@"hdl"];
                break;
            }
            case 2:
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
    if (2 == indexPath.section) {
        int tag = indexPath.row + 1004;
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
                resultCell.inputTitle.text = NSLocalizedString(@"Hemoglobulin", @"Hemoglobulin");
                resultCell.inputValueKind = FLOATINPUT;
                value = [self.resultsDictionary objectForKey:@"hemoglobulin"];
                break;
            }
            case 1:
            {
                resultCell.inputTitle.text = NSLocalizedString(@"White Blood Cells", @"White Blood Cells");
                resultCell.inputValueKind = FLOATINPUT;
                value = [self.resultsDictionary objectForKey:@"whiteCells"];
                break;
            }
            case 2:
            {
                resultCell.inputTitle.text = NSLocalizedString(@"Red Blood Cells", @"Red Blood Cells");
                resultCell.inputValueKind = FLOATINPUT;
                value = [self.resultsDictionary objectForKey:@"redCells"];
                break;
            }
            case 3:
            {
                resultCell.inputTitle.text = NSLocalizedString(@"Platelets", @"Platelets");
                resultCell.inputValueKind = FLOATINPUT;
                value = [self.resultsDictionary objectForKey:@"platelets"];
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
    return nil;
}

#pragma mark - Result Value cell delegate method
- (void)setValueString:(NSString *)valueString withTag:(int)tag{
    NSLog(@"MoreBloodResultsViewController::setValueString with %@ and tag %d",valueString, tag);
    [self.moreBloodResultsDelegate setResultString:valueString forTag:tag];
}
@end
