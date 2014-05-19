//
//  PWESChartsConstants.h
//  HealthCharts
//
//  Created by Peter Schmidt on 14/07/2013.
//  Copyright (c) 2013 Peter Schmidt. All rights reserved.
//
#import "Constants.h"

#define kSummaryViewHeight 80.0f

typedef NS_ENUM (int, AxisType)
{
	Vertical = 0,
	VerticalRight,
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

typedef NS_ENUM (NSUInteger, SingleResultType)
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

typedef NS_ENUM (NSUInteger, EvaluationType)
{
	BAD = 0,
	NEUTRAL,
	GOOD
};
#define kPlotMarginiPhone 5.0f
#define kPlotMarginiPad 30.0f
#define kAxisLineWidth  2.0f
#define kAxisTickWidth  1.0f
#define kPXTickDistance 25.0f
#define kTickLength     10.0f
#define kMaxLog10Ticks  11

#define TICKS               7
#define TICKWIDTH           1.5
#define TITLEFONTTYPE       "Arial"
#define TITLEFONTSIZE       13.0
#define LABELFONTTYPE       "Arial"
#define LABELFONTSIZE       11.0
#define EXPONENTFONTSIZE    7.0
#define MARGINTOP           20.0
#define MARGINLEFT          25.0
#define MARGINBOTTOM        20.0
#define MARGINRIGHT         20.0
#define LINEWIDTH           2.0
#define MAJORTICKLENGTH     9.0
#define MINORTICKLENGTH     5.0
#define DATAPOINTRADIUS     2.5
#define DATAPOINTSIZE       5.0
#define DASHCOUNT           2
#define LABELFONTSIZESMALL  10.0
#define LABELSMALLFONTTYPE  "Courier"
#define LABELFONTSIZEVERYSMALL 9.0
#define TIMEINTERVAL        1209600.0 //14 calendar days
#define MAXCD4COUNT         700.0
#define MAXCD4PERCENT       50.0
#define MAXVIRALLOAD        10000000.0
#define UNDETECTABLE        50.0
#define CD4TICKS            8
#define CD4PERCENTTICKS     10
#define VIRALLOADTICKS      8
