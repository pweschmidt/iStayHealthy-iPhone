//
//  CoreXMLWriter.m
//  iStayHealthy
//
//  Created by Peter Schmidt on 11/08/2013.
//
//

#import "CoreXMLWriter.h"
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
#import "CoreDataManager.h"

@interface CoreXMLWriter ()
@property (nonatomic, strong) NSMutableString * xmlString;

@end

@implementation CoreXMLWriter
+ (id) sharedInstance
{
    static CoreXMLWriter *reader = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        reader = [[CoreXMLWriter alloc] init];
    });
    return reader;
}

- (void)writeXMLWithCompletionBlock:(iStayHealthySuccessBlock)completionBlock
{
    self.xmlString = [NSMutableString string];
    CoreDataManager *manager = [CoreDataManager sharedInstance];
    iStayHealthyArrayCompletionBlock wellnessBlock = ^void(NSArray *array, NSError *error){
        if (completionBlock)
        {
            if (nil == error)
            {
                completionBlock(YES, nil);
            }
            else
            {
                if (0 < array.count)
                {
                    [self xmlOpenEnclosingElementForClass:kWellness];
                    [array enumerateObjectsUsingBlock:^(Wellness *well, NSUInteger idx, BOOL *stop) {
                        [self.xmlString appendString:[well xmlString]];
                    }];
                    [self xmlCloseEnclosingElementForClass:kWellness];
                }
                completionBlock(NO, error);
            }
        }
    };

    iStayHealthyArrayCompletionBlock contactsBlock = ^void(NSArray *array, NSError *error){
        if (nil == error)
        {
            completionBlock(NO, error);
        }
        else
        {
            if (0 < array.count)
            {
                [self xmlOpenEnclosingElementForClass:kContacts];
                [array enumerateObjectsUsingBlock:^(Contacts *contacts, NSUInteger idx, BOOL *stop) {
                    [self.xmlString appendString:[contacts xmlString]];
                }];
                [self xmlCloseEnclosingElementForClass:kContacts];
            }
            [manager fetchDataForEntityName:kWellness predicate:nil sortTerm:nil ascending:NO completion:wellnessBlock];
        }
    };
    
    iStayHealthyArrayCompletionBlock procsBlock = ^void(NSArray *array, NSError *error){
        if (nil == error)
        {
            completionBlock(NO, error);
        }
        else
        {
            if (0 < array.count)
            {
                [self xmlOpenEnclosingElementForClass:kProcedures];
                [array enumerateObjectsUsingBlock:^(Procedures *proc, NSUInteger idx, BOOL *stop) {
                    [self.xmlString appendString:[proc xmlString]];
                }];
                [self xmlCloseEnclosingElementForClass:kProcedures];
            }
            [manager fetchDataForEntityName:kContacts predicate:nil sortTerm:kClinicName ascending:YES completion:contactsBlock];
        }
    };
    iStayHealthyArrayCompletionBlock otherBlock = ^void(NSArray *array, NSError *error){
        if (nil == error)
        {
            completionBlock(NO, error);
        }
        else
        {
            if (0 < array.count)
            {
                [self xmlOpenEnclosingElementForClass:kOtherMedication];
                [array enumerateObjectsUsingBlock:^(OtherMedication *med, NSUInteger idx, BOOL *stop) {
                    [self.xmlString appendString:[med xmlString]];
                }];
                [self xmlCloseEnclosingElementForClass:kOtherMedication];
            }
            [manager fetchDataForEntityName:kProcedures predicate:nil sortTerm:kDate ascending:YES completion:procsBlock];
        }
    };
    iStayHealthyArrayCompletionBlock effectsBlock = ^void(NSArray *array, NSError *error){
        if (nil == error)
        {
            completionBlock(NO, error);
        }
        else
        {
            if (0 < array.count)
            {
                [self xmlOpenEnclosingElementForClass:kSideEffects];
                [array enumerateObjectsUsingBlock:^(SideEffects *effect, NSUInteger idx, BOOL *stop) {
                    [self.xmlString appendString:[effect xmlString]];
                }];
                [self xmlCloseEnclosingElementForClass:kSideEffects];
            }
            [manager fetchDataForEntityName:kOtherMedication predicate:nil sortTerm:kStartDate ascending:YES completion:otherBlock];
        }
    };
    iStayHealthyArrayCompletionBlock prevBlock = ^void(NSArray *array, NSError *error){
        if (nil == error)
        {
            completionBlock(NO, error);
        }
        else
        {
            if (0 < array.count)
            {
                [self xmlOpenEnclosingElementForClass:kPreviousMedication];
                [array enumerateObjectsUsingBlock:^(PreviousMedication *med, NSUInteger idx, BOOL *stop) {
                    [self.xmlString appendString:[med xmlString]];
                }];
                [self xmlCloseEnclosingElementForClass:kPreviousMedication];
            }
            [manager fetchDataForEntityName:kSideEffects predicate:nil sortTerm:kSideEffectDate ascending:YES completion:effectsBlock];
        }
    };
    iStayHealthyArrayCompletionBlock missedBlock = ^void(NSArray *array, NSError *error){
        if (nil == error)
        {
            completionBlock(NO, error);
        }
        else
        {
            if (0 < array.count)
            {
                [self xmlOpenEnclosingElementForClass:kMissedMedication];
                [array enumerateObjectsUsingBlock:^(MissedMedication *med, NSUInteger idx, BOOL *stop) {
                    [self.xmlString appendString:[med xmlString]];
                }];
                [self xmlCloseEnclosingElementForClass:kMissedMedication];
            }
            [manager fetchDataForEntityName:kPreviousMedication predicate:nil sortTerm:kEndDate ascending:YES completion:prevBlock];
        }
    };
    iStayHealthyArrayCompletionBlock medBlock = ^void(NSArray *array, NSError *error){
        if (nil == error)
        {
            completionBlock(NO, error);
        }
        else
        {
            if (0 < array.count)
            {
                [self xmlOpenEnclosingElementForClass:kMedication];
                [array enumerateObjectsUsingBlock:^(Medication *med, NSUInteger idx, BOOL *stop) {
                    [self.xmlString appendString:[med xmlString]];
                }];
                [self xmlCloseEnclosingElementForClass:kMedication];
            }
            [manager fetchDataForEntityName:kMissedMedication predicate:nil sortTerm:kMissedDate ascending:YES completion:missedBlock];
        }
    };
    iStayHealthyArrayCompletionBlock resultsBlock = ^void(NSArray *array, NSError *error){
        if (nil == error)
        {
            completionBlock(NO, error);
        }
        else
        {
            if (0 < array.count)
            {
                [self xmlOpenEnclosingElementForClass:kResult];
                [array enumerateObjectsUsingBlock:^(Results *result, NSUInteger idx, BOOL *stop) {
                    [self.xmlString appendString:[result xmlString]];
                }];
                [self xmlCloseEnclosingElementForClass:kResult];
            }
            [manager fetchDataForEntityName:kMedication predicate:nil sortTerm:kStartDate ascending:YES completion:medBlock];
            
        }
    };
    
    [manager fetchDataForEntityName:kXMLElementRoot predicate:nil sortTerm:nil ascending:NO completion:^(NSArray *array, NSError *error) {
        if (error)
        {
            completionBlock(NO, error);
        }
        else
        {
            [manager fetchDataForEntityName:kResult predicate:nil sortTerm:kResultsDate ascending:YES completion:resultsBlock];
        }
    }];
    
    
}


- (NSString *)xmlOpenEnclosingElementForClass:(NSString *)className
{
    if ([className isEqualToString:kResult])
    {
        return [NSString stringWithFormat:@"<%@>",kResults];
    }
    else if ([className isEqualToString:kSideEffects])
    {
        return [NSString stringWithFormat:@"<%@>",kHIVSideEffects];
    }
    else if ([className isEqualToString:kMedication])
    {
        return [NSString stringWithFormat:@"<%@>",kMedications];
    }
    else if ([className isEqualToString:kOtherMedication])
    {
        return [NSString stringWithFormat:@"<%@>",kOtherMedications];
    }
    else if ([className isEqualToString:kPreviousMedication])
    {
        return [NSString stringWithFormat:@"<%@>",kPreviousMedications];
    }
    else if ([className isEqualToString:kMissedMedication])
    {
        return [NSString stringWithFormat:@"<%@>",kMissedMedications];
    }
    else if ([className isEqualToString:kContacts])
    {
        return [NSString stringWithFormat:@"<%@>",kClinicalContacts];
    }
    else if ([className isEqualToString:kProcedures])
    {
        return [NSString stringWithFormat:@"<%@>",kIllnessAndProcedures];
    }
    else if ([className isEqualToString:kWellness])
    {
        return [NSString stringWithFormat:@"<%@>",kWellnesses];
    }
    return nil;
}
- (NSString *)xmlCloseEnclosingElementForClass:(NSString *)className
{
    if ([className isEqualToString:kResult])
    {
        return [NSString stringWithFormat:@"</%@>",kResults];
    }
    else if ([className isEqualToString:kSideEffects])
    {
        return [NSString stringWithFormat:@"</%@>",kHIVSideEffects];
    }
    else if ([className isEqualToString:kMedication])
    {
        return [NSString stringWithFormat:@"</%@>",kMedications];
    }
    else if ([className isEqualToString:kOtherMedication])
    {
        return [NSString stringWithFormat:@"</%@>",kOtherMedications];
    }
    else if ([className isEqualToString:kPreviousMedication])
    {
        return [NSString stringWithFormat:@"</%@>",kPreviousMedications];
    }
    else if ([className isEqualToString:kMissedMedication])
    {
        return [NSString stringWithFormat:@"</%@>",kMissedMedications];
    }
    else if ([className isEqualToString:kContacts])
    {
        return [NSString stringWithFormat:@"</%@>",kClinicalContacts];
    }
    else if ([className isEqualToString:kProcedures])
    {
        return [NSString stringWithFormat:@"</%@>",kIllnessAndProcedures];
    }
    else if ([className isEqualToString:kWellness])
    {
        return [NSString stringWithFormat:@"</%@>",kWellnesses];
    }
    return nil;
}



@end
