//
//  ResultsView-iPad.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 23/02/2014.
//
//

#import "ResultsView-iPad.h"
#import "PWESDataManager.h"
#import <QuartzCore/QuartzCore.h>

@interface ResultsView_iPad ()
@property (nonatomic, assign) ResultsType resultsType;
@property (nonatomic, strong) Results *results;
@end

@implementation ResultsView_iPad

+ (ResultsView_iPad *)viewForResults:(Results *)results
                         resultsType:(ResultsType)resultsType
                               frame:(CGRect)frame
{
    ResultsView_iPad *view = [[ResultsView_iPad alloc] initWithFrame:frame];

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

/*
   // Only override drawRect: if you perform custom drawing.
   // An empty implementation adversely affects performance during animation.
   - (void)drawRect:(CGRect)rect
   {
    // Drawing code
   }
 */

- (UIView *)hivResultsView
{
    UIView *view = [[UIView alloc] init];
    BOOL hasCD4 = ([self.results.CD4 floatValue] > 0 ||
                   [self.results.CD4Percent floatValue] > 0);


    CGRect cd4Frame = CGRectMake(20, 0, self.frame.size.width / 2, 20);
    UILabel *cd4Label = [[UILabel alloc] initWithFrame:cd4Frame];

    cd4Label.backgroundColor = [UIColor clearColor];
    cd4Label.text = kCD4;
    cd4Label.textAlignment = NSTextAlignmentLeft;
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
    if (hasCD4)
    {
        CGRect cd4ValueFrame = CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, 20);
        UILabel *cd4ValueLabel = [[UILabel alloc] initWithFrame:cd4ValueFrame];
        cd4ValueLabel.backgroundColor = [UIColor clearColor];
        cd4ValueLabel.text = [NSString stringWithFormat:@"%d", [self.results.CD4 intValue]];
        cd4ValueLabel.textColor = DARK_YELLOW;
        cd4ValueLabel.font = [UIFont boldSystemFontOfSize:15];
        cd4ValueLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:cd4ValueLabel];
    }

    CGRect vlFrame = CGRectMake(20, 25, self.frame.size.width / 2, 20);
    BOOL hasVL = ([self.results.ViralLoad floatValue] > 0 ||
                  [self.results.HepCViralLoad floatValue] > 0);
    UILabel *vlLabel = [[UILabel alloc] initWithFrame:vlFrame];
    vlLabel.backgroundColor = [UIColor clearColor];
    vlLabel.text = NSLocalizedString(@"VL", nil);
    vlLabel.textAlignment = NSTextAlignmentLeft;
    if (hasVL)
    {
        vlLabel.textColor = DARK_BLUE;
        vlLabel.font = [UIFont boldSystemFontOfSize:15];
    }
    else
    {
        vlLabel.textColor = [UIColor lightGrayColor];
        vlLabel.font = [UIFont systemFontOfSize:15];
    }
    [self addSubview:vlLabel];

    if (hasVL)
    {
        CGRect vlValueFrame = CGRectMake(self.frame.size.width / 2, 25, self.frame.size.width / 2, 20);
        UILabel *vlValueLabel = [[UILabel alloc] initWithFrame:vlValueFrame];
        vlValueLabel.backgroundColor = [UIColor clearColor];
        vlValueLabel.textColor = DARK_BLUE;
        vlValueLabel.textAlignment = NSTextAlignmentLeft;
        vlValueLabel.font = [UIFont boldSystemFontOfSize:15];
        if (1 >= [self.results.ViralLoad floatValue])
        {
            vlValueLabel.text = NSLocalizedString(@"und.", nil);
        }
        else
        {
            vlValueLabel.text = [NSString stringWithFormat:@"%d", [self.results.ViralLoad intValue]];
        }
        [self addSubview:vlValueLabel];
    }

    return view;
}

- (UILabel *)bloodResultsView
{
    UILabel *label = [[UILabel alloc] init];

    label.frame = CGRectMake(20, 0, self.frame.size.width, 20);
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"Bloods", nil);
    label.textAlignment = NSTextAlignmentLeft;
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

    label.frame = CGRectMake(20, 0, self.frame.size.width, 20);
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"Other", nil);
    label.textAlignment = NSTextAlignmentLeft;
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

    label.frame = CGRectMake(20, 0, self.frame.size.width, 20);
    label.backgroundColor = [UIColor clearColor];
    label.text = NSLocalizedString(@"Liver", nil);
    label.textAlignment = NSTextAlignmentLeft;
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
