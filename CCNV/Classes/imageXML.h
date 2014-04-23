//
//  imageXML.h
//  SugarSynDemo
//
//  Created by  Linksware Inc. on 23/08/12.
//  Copyright © VINAS Co., Ltd. 2011 - 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"

@interface imageXML : NSObject<NSXMLParserDelegate>{
    
    NSMutableString *currentElementValue;
    NSMutableDictionary *temp;
}
- (imageXML *) initXMLParser;
@end
