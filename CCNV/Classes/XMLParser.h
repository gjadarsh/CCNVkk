//
//  XMLParser.h
//  SugarSynDemo
//
//  Created by  Linksware Inc. on 21/08/12.
//  Copyright © VINAS Co., Ltd. 2011 - 2013. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"
#import "File.h"

@interface XMLParser : NSObject<NSXMLParserDelegate>{
    
    NSMutableString *currentElementValue;
    NSString *workspaceURL;
    NSMutableDictionary *albim_dict;
    File *objFile;
}
@property (nonatomic,strong)File *objFile;
- (XMLParser *) initXMLParser;

@end
