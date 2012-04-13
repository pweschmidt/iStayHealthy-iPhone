//
//  XMLLoader.h
//  iStayHealthy
//
//  Created by peterschmidt on 14/08/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XMLDocument;
@class XMLElement;

@interface XMLLoader : NSObject <NSXMLParserDelegate>{
    NSXMLParser *xmlParser;
    XMLDocument *document;
    XMLElement *results;
    XMLElement *medications;
    XMLElement *missedMedications;
    XMLElement *alerts;
    XMLElement *otherMedications;
    XMLElement *contacts;
    XMLElement *procedures;
    XMLElement *sideEffects;
}
@property (nonatomic, retain) NSXMLParser *xmlParser;
@property (nonatomic, retain) XMLDocument *document;
@property (nonatomic, retain) XMLElement *medications;
@property (nonatomic, retain) XMLElement *missedMedications;
@property (nonatomic, retain) XMLElement *alerts;
@property (nonatomic, retain) XMLElement *results;
@property (nonatomic, retain) XMLElement *otherMedications;
@property (nonatomic, retain) XMLElement *contacts;
@property (nonatomic, retain) XMLElement *procedures;
@property (nonatomic, retain) XMLElement *sideEffects;
- (id)initWithData:(NSData *)data;
- (void)startParsing;
- (void)synchronise;
@end
