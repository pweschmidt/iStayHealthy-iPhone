//
//  SQLMasterRecordManager.h
//  iStayHealthy
//
//  Created by Peter Schmidt on 10/02/2013.
//
//

#import <Foundation/Foundation.h>

@class iStayHealthyRecord;
@interface SQLMasterRecordManager : NSObject <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) iStayHealthyRecord *masterRecord;

- (void)checkMasterRecord;
- (iStayHealthyRecord *)validMasterRecord;
- (void)cleanUpMasterRecords;
@end
