//
//  ResultsViewWithValue_iPhone.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 07/11/2014.
//
//

#import "ResultsViewWithValue_iPhone.h"
#import "PWESDataManager.h"
#import "Results+Handling.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

@interface ResultsViewWithValue_iPhone ()
@property (nonatomic, strong) Results *results;
@property (nonatomic, assign) NSString *resultsType;
@end

@implementation ResultsViewWithValue_iPhone

+ (ResultsViewWithValue_iPhone *)viewForResults:(Results *)results
                                    resultsType:(NSString *)resultsType
                                          frame:(CGRect)frame
{

    ResultsViewWithValue_iPhone *view = [[ResultsViewWithValue_iPhone alloc] initWithFrame:frame];

    view.resultsType = resultsType;
    view.results = results;
    [view configureView];
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

- (void)configureView
{
    NSString *valueString = @"--";

    if ([self.resultsType isEqualToString:kBloodPressure])
    {
        if (0 < [self.results.Systole floatValue] && 0 < [self.results.Diastole floatValue])
        {
            {
                valueString = [NSString stringWithFormat:@"%d/%d", [self.results.Systole intValue], [self.results.Diastole intValue]];
            }
        }
    }
    else if ([self.resultsType isEqualToString:kViralLoad])
    {
        if (1 == [self.results.ViralLoad floatValue] && 0 <= [self.results.ViralLoad floatValue])
        {
            valueString = NSLocalizedString(@"und.", nil);
        }
        else
        {
            valueString = [self.results valueStringForType:self.resultsType];
        }
    }
    else
    {
        valueString = [self.results valueStringForType:self.resultsType];
    }
    

    if ([valueString isEqualToString:NSLocalizedString(@"Enter Value", nil)])
    {
        valueString = @"--";
    }

    UIColor *colour = [self colorForResultsTypeWithValueString:valueString];
    NSString *title = [[Utilities resultsTypeWithShortNamesDictionary] objectForKey:self.resultsType];
    if (nil == title)
    {
        title = @"";
    }

    CGRect titleFrame = CGRectMake(0, 4, self.frame.size.width, self.frame.size.height / 2 - 4);
    CGRect valueFrame = CGRectMake(0, self.frame.size.height / 2 + 4, self.frame.size.width, self.frame.size.height / 2 - 4);

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleFrame];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    titleLabel.text = title;
    titleLabel.textColor = colour;

    UILabel *valueLabel = [[UILabel alloc] initWithFrame:valueFrame];
    valueLabel.textAlignment = NSTextAlignmentCenter;
    valueLabel.text = valueString;
    valueLabel.textColor = colour;
    valueLabel.font = [UIFont systemFontOfSize:13];

    [self addSubview:titleLabel];
    [self addSubview:valueLabel];

}

- (UIColor *)colorForResultsTypeWithValueString:(NSString *)valueString
{
    UIColor *colour = [UIColor lightGrayColor];

    if ([valueString isEqualToString:@"--"])
    {
        return colour;
    }

    if ([self.resultsType isEqualToString:kCD4] || [self.resultsType isEqualToString:kCD4Percent])
    {
        return DARK_YELLOW;
    }
    else if ([self.resultsType isEqualToString:kViralLoad] || [self.resultsType isEqualToString:kHepCViralLoad])
    {
        return DARK_BLUE;
    }
    else if ([self.resultsType isEqualToString:kBMI] ||
             [self.resultsType isEqualToString:kSystole] ||
             [self.resultsType isEqualToString:kDiastole] ||
             [self.resultsType isEqualToString:kBloodPressure] ||
             [self.resultsType isEqualToString:kWeight] ||
             [self.resultsType isEqualToString:kCardiacRiskFactor])
    {
        return DARK_GREEN;
    }
    else if ([self.resultsType isEqualToString:kLiverAlanineTransaminase] ||
             [self.resultsType isEqualToString:kLiverAspartateTransaminase] ||
             [self.resultsType isEqualToString:kLiverAlkalinePhosphatase] ||
             [self.resultsType isEqualToString:kLiverGammaGlutamylTranspeptidase])
    {
        return [UIColor brownColor];
    }
    else
    {
        return DARK_RED;
    }
}

@end
