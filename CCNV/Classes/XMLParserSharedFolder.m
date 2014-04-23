//
//  XMLParserSharedFolder.m
//  CCNV
//
//  Created by  Linksware Inc. on 12/25/2012.
//
//

#import "XMLParserSharedFolder.h"

@implementation XMLParserSharedFolder
@synthesize objFile;

- (XMLParserSharedFolder*) initXMLParser{
	
    self = [super init];
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
	attributes:(NSDictionary *)attributeDict {
 //   NSLog(@"Start Element = %@", elementName);
   
     if([elementName isEqualToString:@"receivedShares"])
    {
        ApplicationDelegate.albumContent=[[NSMutableArray alloc] init];
    }
   
//    else if([elementName isEqualToString:@"receivedShare"]){
//        objFile=[[File alloc] init];
//        albim_dict =[[NSMutableDictionary alloc]init];
//        if([[attributeDict objectForKey:@"type"] isEqualToString:@"folder"]||[[attributeDict objectForKey:@"type"] isEqualToString:@"syncFolder"])
//        {
//            objFile.strMediaType=[attributeDict objectForKey:@"type"];
//            [albim_dict setValue:[attributeDict objectForKey:@"type"] forKey:@"mediaType"];
//        }
//    }
    
    else if([elementName isEqualToString:@"receivedShare"]){
        objFile=[[File alloc] init];
        
        albim_dict =[[NSMutableDictionary alloc]init];
        
    }
    //
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	
    if(!currentElementValue)
		currentElementValue = [[NSMutableString alloc] initWithString:string];
	else
		[currentElementValue appendString:string];
    
    //NSLog(@"Found Char = %@", string);
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
//    NSLog(@"End Element = %@", elementName);
//    NSLog(@"App.albumarray = %@",APP.albumContent);
    
    if([elementName isEqualToString:@"collectionContents"])
        return;
    
    
    if([elementName isEqualToString:@"collections"]) {
       // NSString *type=[NSString stringWithFormat:@"%@",[currentElementValue lastPathComponent]];
      //  NSLog(@"%@",type);
        [ApplicationDelegate.albumContent addObject:objFile];
        // [APP.albumContent addObject:albim_dict];
    }
    
    else if([elementName isEqualToString:@"displayName"]){
        objFile.strDisplayName=currentElementValue;
        //[albim_dict setValue:currentElementValue forKey:@"displayName"];
    }
    else if([elementName isEqualToString:@"ref"]){
        objFile.ref=currentElementValue;
        // [albim_dict setValue:currentElementValue forKey:@"ref"];
    }
    else if([elementName isEqualToString:@"file"]){
        
        [ApplicationDelegate.albumContent addObject:objFile];
    }
    else if([elementName isEqualToString:@"mediaType"]){
        // [albim_dict setValue:currentElementValue forKey:@"mediaType"];
        objFile.strMediaType =currentElementValue;
    }
    
    else if([elementName isEqualToString:@"fileData"]){
        objFile.filedata=currentElementValue;
        // [albim_dict setValue:currentElementValue forKey:@"fileData"];
        
    }
    else if([elementName isEqualToString:@"presentOnServer"]){
        //  [albim_dict setValue:currentElementValue forKey:@"presentOnServer"];
        
    }
    else if ([elementName isEqualToString:@"receivedShare"])
    {
        objFile.strMediaType=@"folder";
        [ApplicationDelegate.albumContent addObject:objFile];
    }
    else if ([elementName isEqualToString:@"sharedFolder"])
    {
        objFile.ref=currentElementValue;
    }
    else if ([elementName isEqualToString:@"timeReceived"])
    {
        objFile.strDateTime=currentElementValue;
    }
    else if ([elementName isEqualToString:@"lastModified"])
    {
        objFile.strLastModified=currentElementValue;
    }
    else if ([elementName isEqualToString:@"owner"])
    {
        objFile.strFileAuthor=currentElementValue;
    }
   
    //contents
    else if([elementName isEqualToString:@"receivedShares"]){
        
        objFile=[[File alloc] init];
        objFile.strDisplayName=elementName;
        objFile.ref=currentElementValue;
        objFile.strMediaType=@"folder";
        [ApplicationDelegate.arrSugerSyncFolder addObject:objFile];
        
        objFile=nil;
    }
    else if([elementName isEqualToString:@"webArchive"]){
        
        objFile=[[File alloc] init];
        objFile.strDisplayName=elementName;
        objFile.ref=currentElementValue;
        objFile.strMediaType=@"folder";
        
        [ApplicationDelegate.arrSugerSyncFolder addObject:objFile];
        
        objFile=nil;
    }
    
    
    else {

        
        if (currentElementValue) {
            
        }
        else {
        }
    }
    
    currentElementValue = nil;
}

@end