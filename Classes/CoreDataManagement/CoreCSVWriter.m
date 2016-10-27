//
//  CoreCSVWriter.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/05/2014.
//
//

#import "CoreCSVWriter.h"
#import "Results+Handling.h"
#import "Medication+Handling.h"
#import "MissedMedication+Handling.h"
#import "OtherMedication+Handling.h"
#import "PreviousMedication+Handling.h"
#import "Procedures+Handling.h"
#import "SideEffects+Handling.h"
#import "iStayHealthyRecord+Handling.h"
#import "Wellness+Handling.h"
#import "Contacts+Handling.h"
#import "Constants.h"
// #import "CoreDataManager.h"
#import "NSDate+Extras.h"
#import "iStayHealthy-Swift.h"

static NSArray * csvModels()
{
    return @[kResults,
             kMedication,
             kMissedMedication,
             kSideEffects,
             kContacts,
             kProcedures,
             kOtherMedication,
             kPreviousMedication];
}

static NSDictionary * csvSortTerms()
{
    return @{ kResults : kResultsDate,
              kMedication : kStartDate,
              kMissedMedication : kMissedDate,
              kPreviousMedication : kEndDateLowerCase,
              kSideEffects : kSideEffectDate,
              kOtherMedication : kStartDate,
              kProcedures : kDate,
              kContacts : kClinicName };
}

static NSDictionary * csvAscDictionary()
{
    return @{ kResults: @(1),
              kMedication : @(1),
              kMissedMedication : @(1),
              kPreviousMedication : @(1),
              kSideEffects : @(1),
              kOtherMedication : @(1),
              kProcedures : @(1),
              kContacts : @(0) };
}

@interface CoreCSVWriter ()
@property (nonatomic, strong) NSMutableArray *csvModels;
@property (nonatomic, strong) NSMutableString *csvString;
@property (nonatomic, assign) NSUInteger insertPosition;
@property (nonatomic, strong) iStayHealthyXMLBlock successBlock;
@end
@implementation CoreCSVWriter
+ (id)sharedInstance
{
    static CoreCSVWriter *reader = nil;
    static dispatch_once_t token;

    dispatch_once(&token, ^{
                      reader = [[CoreCSVWriter alloc] init];
                  });
    return reader;
}

- (void)writeWithCompletionBlock:(iStayHealthyXMLBlock)completionBlock
{
    self.successBlock = [completionBlock copy];
    self.csvString = [NSMutableString string];
    self.csvModels = [NSMutableArray arrayWithArray:csvModels()];
    NSString *firstModel = [self.csvModels objectAtIndex:0];
    NSString *nextModel = [self.csvModels objectAtIndex:1];
    NSString *sortTerm = [csvSortTerms() objectForKey:firstModel];
    NSNumber *number = [csvAscDictionary() objectForKey:firstModel];
    BOOL ascending = (nil != number && [number boolValue]) ? YES : NO;
    [self writeCSVRowForDataModel:firstModel
                         position:0
                         sortTerm:sortTerm
                        ascending:ascending
                    nextDataModel:nextModel];
}

- (void)writeCSVRowForDataModel:(NSString *)dataModel
                       position:(NSUInteger)position
                       sortTerm:(NSString *)sortTerm
                      ascending:(BOOL)ascending
                  nextDataModel:(NSString *)nextDataModel
{
#ifdef APPDEBUG
    NSLog(@"Writing %@ and next model is %@", dataModel, nextDataModel);
#endif
    if (nil == dataModel || [dataModel isEqual:[NSNull null]])
    {
        if (nil != self.successBlock)
        {
            self.successBlock(self.csvString, nil);
        }
    }
    PWESPersistentStoreManager *manager = [PWESPersistentStoreManager defaultManager];
    [manager fetchData:dataModel predicate:nil sortTerm:sortTerm ascending:ascending completion:^(NSArray *array, NSError *error){
         if (nil != array)
         {
             __block NSUInteger updatedPosition = position;
             __block BOOL isHeader = YES;
             [array enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop) {
                  if (isHeader && [obj respondsToSelector:@selector(csvRowHeader)])
                  {
                      NSString *header = [obj csvRowHeader];
                      if (nil != header)
                      {
                          [self.csvString insertString:header atIndex:updatedPosition];
                      }
                      updatedPosition += header.length;
                      isHeader = NO;
                  }
                  if ([obj respondsToSelector:@selector(csvString)])
                  {
                      NSString *elementString = [obj csvString];
                      if (nil != elementString)
                      {
                          [self.csvString insertString:elementString atIndex:updatedPosition];
                      }
                      updatedPosition += elementString.length;
                  }
              }];


             if (nil == nextDataModel)   // reached the end
             {
                 if (nil != self.successBlock)
                 {
                     self.successBlock(self.csvString, nil);
                 }
             }
             else
             {
                 NSUInteger index = [self.csvModels indexOfObject:nextDataModel] + 1;
                 NSString *nextModel = nil;
                 if (self.csvModels.count > index)
                 {
                     nextModel = [self.csvModels objectAtIndex:index];
                 }
                 NSString *sortTerm = [csvSortTerms() objectForKey:nextDataModel];
                 NSNumber *number = [csvAscDictionary() objectForKey:nextDataModel];
                 BOOL ascending = (nil != number && [number boolValue]) ? YES : NO;
                 [self writeCSVRowForDataModel:nextDataModel
                                      position:updatedPosition
                                      sortTerm:sortTerm
                                     ascending:ascending
                                 nextDataModel:nextModel];
             }
         }
         else
         {
             if (nil != self.successBlock)
             {
                 self.successBlock(nil, error);
             }
         }
     }];
}

@end
