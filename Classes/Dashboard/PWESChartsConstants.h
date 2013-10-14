//
//  PWESChartsConstants.h
//  HealthCharts
//
//  Created by Peter Schmidt on 14/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//
#import "Constants.h"

#define kSummaryViewHeight 80

typedef NS_ENUM(int, AxisType)
{
    Vertical = 0,
    Horizontal
};


typedef NS_ENUM  (NSUInteger, ResultsTypes)
{
    CD4AndViralLoad = 0,
    CD4PercentAndViralLoad,
    BloodPressure,
    Cholesterol,
    Glucose,
    Weight,
    CardiacRisk
};

typedef NS_ENUM(NSUInteger, SingleResultType)
{
    CD4Type = 0,
    CD4PercentType,
    ViralLoadType,
    HepCViralLoadType,
    SystoleType,
    DiastoleType,
    TotalCholesterolType,
    HDLType,
    LDLType,
    TriglycerideType,
    CholesterolRatioType,
    CardiacRiskType,
    HeartRateType,
    GlucoseType,
    WeightType
};

typedef NS_ENUM(NSUInteger, EvaluationType)
{
    BAD = 0,
    NEUTRAL,
    GOOD
};

