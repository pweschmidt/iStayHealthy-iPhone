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

@interface XMLLoader : NSObject <NSXMLParserDelegate>
@property (nonatomic, strong) NSXMLParser *xmlParser;
@property (nonatomic, strong) XMLDocument *document;
@property (nonatomic, strong) XMLElement *medications;
@property (nonatomic, strong) XMLElement *missedMedications;
@property (nonatomic, strong) XMLElement *alerts;
@property (nonatomic, strong) XMLElement *results;
@property (nonatomic, strong) XMLElement *otherMedications;
@property (nonatomic, strong) XMLElement *contacts;
@property (nonatomic, strong) XMLElement *procedures;
@property (nonatomic, strong) XMLElement *sideEffects;
@property (nonatomic, strong) XMLElement *previousMedications;
@property (nonatomic, strong) XMLElement *wellness;
- (id)initWithData:(NSData *)data;
- (BOOL)startParsing:(NSError **)parseError;
- (BOOL)synchronise;
+ (BOOL)isXML:(NSData *)data;
@end
