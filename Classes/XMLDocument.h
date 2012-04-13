//
//  XMLDocument.h
//  iStayHealthy
//
//  Created by peterschmidt on 13/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMLElement;

@interface XMLDocument : NSObject{
    XMLElement *root;
}
@property (nonatomic, retain) XMLElement *root;
-(NSMutableString *)xmlString;
-(XMLElement *)elementForName:(NSString *)name;
@end
