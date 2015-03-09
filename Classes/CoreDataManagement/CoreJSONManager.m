//
//  CoreJSONManager.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 12/07/2014.
//
//

#import "CoreJSONManager.h"
// #import "CoreDataManager.h"
#import "Results+Handling.h"
#import "PreviousMedication+Handling.h"
#import "Procedures+Handling.h"
#import "OtherMedication+Handling.h"
#import "Medication+Handling.h"
#import "MissedMedication+Handling.h"
#import "SeinfeldCalendar+Handling.h"
#import "SideEffects+Handling.h"
#import "Contacts+Handling.h"
#import "iStayHealthy-Swift.h"

static NSArray * jsonDataModels()
{
    return @[kResults,
             kMedication,
             kMissedMedication,
             kSideEffects,
             kContacts,
             kProcedures,
             kOtherMedication,
             kPreviousMedication /*,
                                    kSeinfeldCalendar,
                                    kWellness */];
}

static NSDictionary * jsonParentMap()
{
    return @{ kResults : kObservations,
              kMedication : kMedications,
              kMissedMedication : kMissedMedications,
              kSideEffects : kHIVSideEffects,
              kContacts : kClinicalContacts,
              kProcedures : kIllnessAndProcedures,
              kOtherMedication : kOtherMedications,
              kPreviousMedication : kPreviousMedications/*,
                                                           kSeinfeldCalendar : kSeinfeldCalendars,
                                                           kWellness : kWellnesses */};
}

static NSDictionary * jsonSortTerms()
{
    return @{ kResults : kResultsDate,
              kMedication : kStartDate,
              kMissedMedication : kMissedDate,
              kPreviousMedication : kEndDateLowerCase,
              kSideEffects : kSideEffectDate,
              kOtherMedication : kStartDate,
              kProcedures : kDate,
              kContacts : kClinicName,
              /*			  kSeinfeldCalendar : kStartDateLowerCase,
                 kWellness : kDateLowerCase */};
}

static NSDictionary * jsonAscendingDictionary()
{
    return @{ kResults: @(1),
              kMedication : @(1),
              kMissedMedication : @(1),
              kPreviousMedication : @(1),
              kSideEffects : @(1),
              kOtherMedication : @(1),
              kProcedures : @(1),
              kContacts : @(0),
              //			  kSeinfeldCalendar : @(1),
              //			  kSeinfeldCalendarEntry : @(1),
              kWellness : @(1) };
}

@interface CoreJSONManager ()
@property (nonatomic, strong) NSMutableDictionary *jsonDictionary;
@property (nonatomic, strong) iStayHealthyJSONDictionaryBlock dictionaryBlock;
@property (nonatomic, strong) iStayHealthyJSONDataBlock jsonBlock;
@end

@implementation CoreJSONManager
+ (id)sharedInstance
{
    static CoreJSONManager *manager = nil;
    static dispatch_once_t token;

    dispatch_once(&token, ^{
                      manager = [[CoreJSONManager alloc] init];
                  });
    return manager;
}

- (void)writeCoreDataToJSONWithCompletionBlock:(iStayHealthyJSONDataBlock)completionBlock
{
    self.jsonDictionary = [NSMutableDictionary dictionary];
    self.jsonBlock = completionBlock;
    NSString *firstModel = [jsonDataModels() objectAtIndex:0];
    [self createJSONFromModelWithName:firstModel];
}

- (void)parseCoreDataFromJSONWithCompletionBlock:(iStayHealthyJSONDictionaryBlock)completionBlock
{
}

- (NSDictionary *)dictionaryForDataModel:(NSString *)dataModel
{
    return nil;
}

- (void)createJSONFromModelWithName:(NSString *)modelName
{
    NSString *sortTerms = [jsonSortTerms() objectForKey:modelName];
    NSNumber *ascending = [jsonAscendingDictionary() objectForKey:modelName];

    if (nil != sortTerms && nil != ascending)
    {
        PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
        [manager fetchData:modelName predicate:nil sortTerm:sortTerms ascending:[ascending boolValue] completion:^(NSArray *array, NSError *error) {
             if (nil != array)
             {
                 NSMutableArray *valueArray = [NSMutableArray array];
                 [self createArrayOfDictionarysForModel:modelName array:valueArray];
                 NSString *parent = [jsonParentMap() objectForKey:modelName];
                 [self.jsonDictionary setObject:valueArray forKey:parent];
             }
             NSUInteger nextIndex = [jsonDataModels() indexOfObject:modelName] + 1;
             if (nextIndex < jsonDataModels().count)
             {
                 NSString *nextModel = [jsonDataModels() objectAtIndex:nextIndex];
                 [self createJSONFromModelWithName:nextModel];
             }
         }];
    }
}

- (void)createArrayOfDictionarysForModel:(NSString *)modelName array:(NSMutableArray *)array
{
    [array enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
         if ([obj respondsToSelector:@selector(dictionaryForAttributes)])
         {
             NSDictionary *dictionary = [obj dictionaryForAttributes];
             [array addObject:dictionary];
         }
     }];
}

@end
