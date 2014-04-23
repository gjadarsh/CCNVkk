//
//  XMLParserSharedFolder.h
//  CCNV
//
//  Created by  Linksware Inc. on 12/25/2012.
//
//

#import <Foundation/Foundation.h>
#import "Global.h"
#import "File.h"
@interface XMLParserSharedFolder : NSObject<NSXMLParserDelegate>
{
    
    NSMutableString *currentElementValue;
    NSString *workspaceURL;
    NSMutableDictionary *albim_dict;
    File *objFile;
}
@property (nonatomic,strong)File *objFile;
- (XMLParserSharedFolder *) initXMLParser;


@end
