//
//  XMLAttribute.h
//  iStayHealthy
//
//  Created by peterschmidt on 13/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XMLAttribute : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;
-(NSString *)toString;
@end
