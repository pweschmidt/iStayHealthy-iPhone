//
//  PWESResultsTypes.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 18/05/2014.
//
//

#import <Foundation/Foundation.h>

@interface PWESResultsTypes : NSObject
@property (nonatomic, strong, readonly) NSString *mainType;
@property (nonatomic, strong, readonly) NSString *secondaryType;
@property (nonatomic, assign, readonly) BOOL isDualType;
@property (nonatomic, assign, readonly, getter = showMedLine) BOOL wantsMedLine;
@property (nonatomic, assign, readonly, getter = showMissedMedLine) BOOL wantsMissedMedLine;

/**
   initialiser for a single type results type
   @param type
   @param wantsMedLine
   @param wantsMissedMedLine
 */
+ (PWESResultsTypes *)resultsTypeWithType:(NSString *)type
                             wantsMedLine:(BOOL)wantsMedLine
                       wantsMissedMedLine:(BOOL)wantsMissedMedLine;

/**
   initialiser for a dual results type
   @param mainType
   @param secondaryType
   @param wantsMedLine
   @param wantsMissedMedLine
 */
+ (PWESResultsTypes *)resultsTypeWithMainType:(NSString *)mainType
                                secondaryType:(NSString *)secondaryType
                                 wantsMedLine:(BOOL)wantsMedLine
                           wantsMissedMedLine:(BOOL)wantsMissedMedLine;

@end
