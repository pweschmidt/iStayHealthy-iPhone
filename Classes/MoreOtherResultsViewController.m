//
//  MoreOtherResultsViewController.m
//  iStayHealthy
//
//  Created by peterschmidt on 23/06/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoreOtherResultsViewController.h"
#import "GeneralSettings.h"
#import "ChartSettings.h"
#import <QuartzCore/QuartzCore.h>

@interface MoreOtherResultsViewController ()

@end

@implementation MoreOtherResultsViewController
@synthesize bloodPressureCell = _bloodPressureCell;
@synthesize systoleTag = _systoleTag;
@synthesize diastoleTag = _diastoleTag;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithResults:(NSDictionary *)results systoleTag:(NSInteger)systag diastoleTag:(NSInteger)diatag{
    self = [super initWithResults:results nibName:@"MoreOtherResultsViewController"];
    if (self) {
        self.systoleTag = systag;
        self.diastoleTag = diatag;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)viewDidUnload
{
    self.bloodPressureCell = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 48;    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        int tag = indexPath.row + 100000;
        
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
        resultCell.colourCodeView.backgroundColor = DARK_GREEN;
        resultCell.colourCodeView.layer.cornerRadius = 5;
        resultCell.inputTitle.text = NSLocalizedString(@"Weight", @"Weight");
        resultCell.inputValueKind = FLOATINPUT;
        resultCell.tag = tag;
        NSNumber *value = [self.resultsDictionary objectForKey:@"weight"];
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
        
        NSString *identifier = @"PressureCell";
        PressureCell *pressureCell = (PressureCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (nil == pressureCell) {
            NSArray *cellObjects = [[NSBundle mainBundle]loadNibNamed:@"PressureCell" owner:self options:nil];
            for (id currentObject in cellObjects) {
                if ([currentObject isKindOfClass:[PressureCell class]]) {
                    pressureCell = (PressureCell *)currentObject;
                    break;
                }
            } 
            [pressureCell setDelegate:self];
        }
        pressureCell.pressureLabel.textColor = TEXTCOLOUR;
        pressureCell.pressureLabel.text = NSLocalizedString(@"Blood Pressure", @"Blood Pressure");
        pressureCell.colourCodeView.backgroundColor = DARK_GREEN;
        pressureCell.colourCodeView.layer.cornerRadius = 5;
        pressureCell.systoleField.tag = self.systoleTag;
        pressureCell.diastoleField.tag = self.diastoleTag;
        [pressureCell setDelegate:self];
        NSNumber *sysValue = [self.resultsDictionary objectForKey:@"systole"];
        NSNumber *diaValue = [self.resultsDictionary objectForKey:@"diastole"];
        if (nil != sysValue && nil != diaValue) {
            
            int iSys = [sysValue intValue];
            int iDia = [diaValue intValue];            
            if (0 < iSys && 0 < iDia) {
                pressureCell.systoleField.text = [NSString stringWithFormat:@"%d",iSys];
                pressureCell.systoleField.textColor = [UIColor blackColor];
                pressureCell.diastoleField.text = [NSString stringWithFormat:@"%d",iDia];
                pressureCell.diastoleField.textColor = [UIColor blackColor];
            }
        }
        self.bloodPressureCell = pressureCell;
        return pressureCell;        
    }
    return nil;
}


#pragma mark - Result Value cell delegate method
- (void)setValueString:(NSString *)valueString withTag:(int)tag{
    [self.moreBloodResultsDelegate setResultString:valueString forTag:tag];
}

#pragma mark - Pressure Cell Delegate
- (void)setSystole:(NSString *)systole diastole:(NSString *)diastole{
    NSLog(@"MoreOtherResultsViewController::setSystole %@ diastole %@",systole, diastole);
    [self.moreBloodResultsDelegate setResultString:systole forTag:self.systoleTag];
    [self.moreBloodResultsDelegate setResultString:diastole forTag:self.diastoleTag];
}

@end
