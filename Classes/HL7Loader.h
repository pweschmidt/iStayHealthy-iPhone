//
//  HL7Loader.h
//  iStayHealthy
//
//  Created by peterschmidt on 07/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class iStayHealthyRecord, XMLElement;

@interface HL7Loader : NSObject<NSFetchedResultsControllerDelegate>{
	NSFetchedResultsController *fetchedResultsController_;
	iStayHealthyRecord *masterRecord;
    NSData *rawData;
    
}
@property (nonatomic, assign) NSData *rawData;
@property (nonatomic, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain) iStayHealthyRecord *masterRecord;
- (id)initWithData:(NSData *)data;
- (void)parse;
@end
