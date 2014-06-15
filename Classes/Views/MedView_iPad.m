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
#import "UIFont+Standard.h"

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
		[view configureViewWithImageName:medication.Name
		                      isMedImage:YES
		                      mainString:medication.Name
		                 secondaryString:medication.Drug];
	}
	return view;
}

+ (MedView_iPad *)viewForMissedMedication:(MissedMedication *)medication
                                    frame:(CGRect)frame
{
	MedView_iPad *view = [[MedView_iPad alloc] initWithFrame:frame];
	if (nil != medication)
	{
		[view configureViewWithImageName:medication.Name
		                      isMedImage:YES
		                      mainString:medication.Name
		                 secondaryString:medication.Drug];
	}
	return view;
}

+ (MedView_iPad *)viewForPreviousMedication:(PreviousMedication *)medication
                                      frame:(CGRect)frame
{
	MedView_iPad *view = [[MedView_iPad alloc] initWithFrame:frame];
	if (nil != medication)
	{
		[view configureViewWithImageName:medication.name
		                      isMedImage:YES
		                      mainString:medication.name
		                 secondaryString:medication.drug];
	}
	return view;
}

+ (MedView_iPad *)viewForOtherMedication:(OtherMedication *)medication
                                   frame:(CGRect)frame
{
	MedView_iPad *view = [[MedView_iPad alloc] initWithFrame:frame];
	if (nil != medication)
	{
		NSString *doseString = [NSString stringWithFormat:@"%3.2f %@", [medication.Dose floatValue], medication.Unit];
		[view configureViewWithImageName:@"cross.png"
		                      isMedImage:NO
		                      mainString:medication.Name
		                 secondaryString:doseString];
	}
	return view;
}

+ (MedView_iPad *)viewForSideEffects:(SideEffects *)effects
                               frame:(CGRect)frame
{
	MedView_iPad *view = [[MedView_iPad alloc] initWithFrame:frame];
	if (nil != effects)
	{
		NSString *imageName = (nil != effects.Name) ? effects.Name : @"sideeffects.png";
		[view configureViewWithImageName:imageName
		                      isMedImage:NO
		                      mainString:effects.SideEffect
		                 secondaryString:nil];
	}
	return view;
}

+ (MedView_iPad *)viewForProcedures:(Procedures *)procedures
                              frame:(CGRect)frame
{
	MedView_iPad *view = [[MedView_iPad alloc] initWithFrame:frame];
	if (nil != procedures)
	{
		[view configureViewWithImageName:@"procedure.png"
		                      isMedImage:NO
		                      mainString:procedures.Illness
		                 secondaryString:procedures.Name];
	}
	return view;
}

+ (MedView_iPad *)viewForContacts:(Contacts *)contacts
                            frame:(CGRect)frame
{
	MedView_iPad *view = [[MedView_iPad alloc] initWithFrame:frame];
	if (nil != contacts)
	{
		NSString *clinicID = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"ID", nil), contacts.ClinicID];
		if (nil == clinicID)
		{
			clinicID = contacts.ClinicName;
		}
		NSString *contactNumber = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"Tel.", nil), contacts.ClinicContactNumber];
		if (nil == contactNumber)
		{
			contactNumber = contacts.ConsultantName;
		}
		[view configureViewWithImageName:@"hospital.png"
		                      isMedImage:NO
		                      mainString:clinicID
		                 secondaryString:contactNumber];
	}
	return view;
}

- (void)configureViewWithImageName:(NSString *)imageName
                        isMedImage:(BOOL)isMedImage
                        mainString:(NSString *)mainString
                   secondaryString:(NSString *)secondayString
{
	UIImageView *imageView = [self imageViewForImageName:imageName isMedImage:isMedImage];
	[self addSubview:imageView];

	if (nil != mainString)
	{
		UILabel *mainLabel = [self mainTextLabelWithString:mainString];
		[self addSubview:mainLabel];
	}

	if (nil != secondayString)
	{
		UILabel *secondaryLabel = [self secondaryTextLabelWithString:secondayString];
		[self addSubview:secondaryLabel];
	}
}

- (UIImageView *)imageViewForImageName:(NSString *)imageName isMedImage:(BOOL)isMedImage
{
	UIImage *image = [self imageFromName:imageName isMedImage:isMedImage];

	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
	imageView.frame = CGRectMake(20, 5, 55, 55);
	imageView.backgroundColor = [UIColor clearColor];
	return imageView;
}

- (UIImage *)imageFromName:(NSString *)imageName isMedImage:(BOOL)isMedImage
{
	UIImage *image = nil;
	if (isMedImage)
	{
		image = [Utilities imageFromMedName:imageName];
	}
	else
	{
		image = [UIImage imageNamed:imageName];
	}
	if (nil == image)
	{
		image = [self blankImage];
	}
	return image;
}

- (UILabel *)mainTextLabelWithString:(NSString *)string
{
	UILabel *label = [[UILabel alloc] init];
	label.font = [UIFont fontWithType:Bold size:large];
	label.frame = CGRectMake(20, 63, self.frame.size.width - 40, 18);
	label.text = string;
	label.textColor = TEXTCOLOUR;
	label.textAlignment = NSTextAlignmentLeft;
	return label;
}

- (UILabel *)secondaryTextLabelWithString:(NSString *)string
{
	UILabel *label = [UILabel standardLabel];
	label.frame = CGRectMake(20, 85, self.frame.size.width - 40, 40);
	label.text = string;
	label.textColor = DARK_RED;
	label.numberOfLines = 0;
	label.textAlignment = NSTextAlignmentLeft;
	return label;
}

- (UIImage *)blankImage
{
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(55, 55), NO, 0.0);
	UIImage *blank = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return blank;
}

@end
