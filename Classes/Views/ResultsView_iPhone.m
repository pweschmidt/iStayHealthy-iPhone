//
//  ResultsView_iPhone.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 22/09/2013.
//
//

#import "ResultsView_iPhone.h"
#import "PWESDataManager.h"
#import <QuartzCore/QuartzCore.h>

@interface ResultsView_iPhone ()
@property (nonatomic, assign) ResultsType resultsType;
@property (nonatomic, strong) Results *results;
@end

@implementation ResultsView_iPhone

+ (ResultsView_iPhone *)viewForResults:(Results *)results
                           resultsType:(ResultsType)resultsType
                                 frame:(CGRect)frame
{
    ResultsView_iPhone *view = [[ResultsView_iPhone alloc] initWithFrame:frame];

    view.resultsType = resultsType;
    view.results = results;
    switch (resultsType)
    {
        case HIVResultsType:
            [view addSubview:[view hivResultsView]];
            break;

        case BloodResultsType:
            [view addSubview:[view bloodResultsView]];
            break;

        case OtherResultsType:
            [view addSubview:[view otherResultsView]];
            break;

        case LiverResultsType:
            [view addSubview:[view liverResultsView]];
            break;
    }
    return view;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
    }
    return self;
}

- (UIView *)hivResultsView
{
    UIView *view = [[UIView alloc] init];
    BOOL hasCD4 = ([self.results.CD4 floatValue] > 0 ||
                   [self.results.CD4Percent floatValue] > 0);


    CGRect cd4Frame = CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height);
    UILabel *cd4Label = [[UILabel alloc] initWithFrame:cd4Frame];

    cd4Label.backgroundColor = [UIColor clearColor];
    cd4Label.text = kCD4;
    cd4Label.textAlignment = NSTextAlignmentCenter;
    if (hasCD4)
    {
        cd4Label.textColor = DARK_YELLOW;
        cd4Label.font = [UIFont boldSystemFontOfSize:15];
    }
    else
    {
        cd4Label.textColor = [UIColor lightGrayColor];
        cd4Label.font = [UIFont systemFontOfSize:15];
    }

    [self addSubview:cd4Label];


    CGRect vlFrame = CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height);
    BOOL hasVL = ([self.results.ViralLoad floatValue] > 0 ||
                  [self.results.HepCViralLoad floatValue] > 0);
    UILabel *vlLabel = [[UILabel alloc] initWithFrame:vlFrame];
    vlLabel.backgroundColor = [UIColor clearColor];
    vlLabel.text = NSLocalizedString(@"VL", nil);
    vlLabel.textAlignment = NSTextAlignmentCenter;
    if (hasVL)
    {
        vlLabel.textColor = DARK_YELLOW;
        vlLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    else
    {
        vlLabel.textColor = [UIColor lightGrayColor];
        vlLabel.font = [UIFont systemFontOfSize:15];
    }
    [self addSubview:vlLabel];
    return view;
}

- (UILabel *)bloodResultsView
{
    UILabel *label = [[UILabel alloc] init];

    label.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"Bloods", nil);
    label.textAlignment = NSTextAlignmentCenter;
    BOOL hasResults = ([self.results.Glucose floatValue] > 0 ||
                       [self.results.TotalCholesterol floatValue]  > 0 ||
                       [self.results.HDL floatValue]  > 0 ||
                       [self.results.LDL floatValue]  > 0 ||
                       [self.results.Hemoglobulin floatValue]  > 0 ||
                       [self.results.WhiteBloodCellCount floatValue]  > 0 ||
                       [self.results.redBloodCellCount floatValue]  > 0 ||
                       [self.results.PlateletCount floatValue] > 0);
    if (hasResults)
    {
        label.textColor = DARK_RED;
        label.font = [UIFont boldSystemFontOfSize:15];
    }
    else
    {
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:15];
    }

    return label;
}

- (UIView *)otherResultsView
{
    UILabel *label = [[UILabel alloc] init];

    label.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"Other", nil);
    label.textAlignment = NSTextAlignmentCenter;
    BOOL hasOther = ([self.results.Weight floatValue] > 0 ||
                     [self.results.Systole floatValue] > 0 ||
                     [self.results.Diastole floatValue] > 0 ||
                     [self.results.cardiacRiskFactor floatValue] > 0 ||
                     [self.results.kidneyGFR floatValue] > 0);
    if (hasOther)
    {
        label.textColor = DARK_GREEN;
        label.font = [UIFont boldSystemFontOfSize:15];
    }
    else
    {
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:15];
    }
    return label;
}

- (UIView *)liverResultsView
{
    UILabel *label = [[UILabel alloc] init];

    label.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"Liver", nil);
    label.textAlignment = NSTextAlignmentCenter;
    BOOL hasOther = ([self.results.liverAlanineTransaminase floatValue] > 0 ||
                     [self.results.liverAspartateTransaminase floatValue] > 0 ||
                     [self.results.liverAlkalinePhosphatase floatValue] > 0 ||
                     [self.results.liverGammaGlutamylTranspeptidase floatValue] > 0);
    if (hasOther)
    {
        label.textColor = [UIColor brownColor];
        label.font = [UIFont boldSystemFontOfSize:15];
    }
    else
    {
        label.textColor = [UIColor lightGrayColor];
        label.font = [UIFont systemFontOfSize:15];
    }
    return label;
}

@end
