//
//  MedView_iPad.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 13/05/2014.
//
//

#import "MedView_iPad.h"
#import "Utilities.h"
#import "UILabel+Standard.h"

@interface MedView_iPad ()
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *drug;
@property (nonatomic, strong) NSNumber *dose;
@end


@implementation MedView_iPad
+ (MedView_iPad *)viewForMedication:(Medication *)medication
                              frame:(CGRect)frame
{
	MedView_iPad *view = [[MedView_iPad alloc] initWithFrame:frame];
	if (nil != medication)
	{
		view.name = medication.Name;
		view.drug = medication.Drug;
	}
	[view configureView];
	return view;
}

+ (MedView_iPad *)viewForMissedMedication:(MissedMedication *)medication
                                    frame:(CGRect)frame
{
	MedView_iPad *view = [[MedView_iPad alloc] initWithFrame:frame];
	if (nil != medication)
	{
		view.name = medication.Name;
		view.drug = medication.Drug;
	}
	[view configureView];
	return view;
}

+ (MedView_iPad *)viewForPreviousMedication:(PreviousMedication *)medication
                                      frame:(CGRect)frame
{
	MedView_iPad *view = [[MedView_iPad alloc] initWithFrame:frame];
	if (nil != medication)
	{
		view.name = medication.name;
		view.drug = medication.drug;
	}
	[view configureView];
	return view;
}

+ (MedView_iPad *)viewForOtherMedication:(OtherMedication *)medication
                                   frame:(CGRect)frame
{
	MedView_iPad *view = [[MedView_iPad alloc] initWithFrame:frame];
	[view configureViewForOtherMedication:medication];
	return view;
}

+ (MedView_iPad *)viewForSideEffects:(SideEffects *)medication
                               frame:(CGRect)frame
{
	MedView_iPad *view = [[MedView_iPad alloc] initWithFrame:frame];
	[view configureViewForSideEffects:medication];
	return view;
}

- (void)configureView
{
	UIImage *image = [Utilities imageFromMedName:self.name];
	if (nil == image)
	{
		image = [self blankImage];
	}

	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	imageView.frame = CGRectMake(10, 0, 55, 55);
	imageView.backgroundColor = [UIColor clearColor];

	UILabel *label = [UILabel standardLabel];
	label.frame = CGRectMake(70, 0, self.frame.size.width - 70, 55);
	label.text = self.name;
	label.textColor = TEXTCOLOUR;
	label.textAlignment = NSTextAlignmentCenter;

	UILabel *drug = [UILabel standardLabel];
	drug.frame = CGRectMake(10, 65, self.frame.size.width - 20, 55);
	drug.text = self.drug;
	drug.numberOfLines = 0;
	drug.textColor = DARK_RED;
	drug.textAlignment = NSTextAlignmentLeft;

	[self addSubview:imageView];
	[self addSubview:label];
	[self addSubview:drug];
}

- (void)configureViewForOtherMedication:(OtherMedication *)otherMed
{
	UIImage *image = [Utilities imageFromMedName:self.name];
	if (nil == image)
	{
		image = [self blankImage];
	}

	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	imageView.frame = CGRectMake(20, 10, 55, 55);
	imageView.backgroundColor = [UIColor clearColor];

	UILabel *label = [UILabel standardLabel];
	label.frame = CGRectMake(80, 10, self.frame.size.width - 80, 55);
	label.text = otherMed.Name;
	label.textColor = TEXTCOLOUR;
	label.textAlignment = NSTextAlignmentCenter;


	NSNumber *dose = otherMed.Dose;
	NSString *unit = otherMed.Unit;
	NSString *doseText = [NSString stringWithFormat:@"%3.2f [%@]", [dose floatValue], unit];
	UILabel *drug = [UILabel standardLabel];
	drug.frame = CGRectMake(20, 75, self.frame.size.width - 40, 40);
	drug.text = doseText;
	drug.textColor = DARK_RED;
	drug.textAlignment = NSTextAlignmentLeft;

	[self addSubview:imageView];
	[self addSubview:label];
	[self addSubview:drug];
}

- (void)configureViewForSideEffects:(SideEffects *)effects
{
	UIImage *image = [Utilities imageFromMedName:self.name];
	if (nil == image)
	{
		image = [self blankImage];
	}

	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	imageView.frame = CGRectMake(20, 10, 55, 55);
	imageView.backgroundColor = [UIColor clearColor];

	UILabel *label = [UILabel standardLabel];
	label.frame = CGRectMake(80, 10, self.frame.size.width - 80, 55);
	label.text = effects.Name;
	label.textColor = TEXTCOLOUR;
	label.textAlignment = NSTextAlignmentCenter;


	UILabel *drug = [UILabel standardLabel];
	drug.frame = CGRectMake(20, 75, self.frame.size.width - 40, 40);
	drug.text = effects.SideEffect;
	drug.textColor = DARK_RED;
	drug.textAlignment = NSTextAlignmentLeft;

	[self addSubview:imageView];
	[self addSubview:label];
	[self addSubview:drug];
}

- (UIImage *)blankImage
{
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(55, 55), NO, 0.0);
	UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return blank;
}

@end
