//
//  Medication.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 05/09/2012.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class iStayHealthyRecord;

@interface Medication : NSManagedObject

@property (nonatomic, strong) NSString * UID;
@property (nonatomic, strong) NSNumber * Dose;
@property (nonatomic, strong) NSString * Drug;
@property (nonatomic, strong) NSDate * StartDate;
@property (nonatomic, strong) NSDate * EndDate;
@property (nonatomic, strong) NSString * Name;
@property (nonatomic, strong) NSString * MedicationForm;
@property (nonatomic, strong) iStayHealthyRecord *record;

@end
