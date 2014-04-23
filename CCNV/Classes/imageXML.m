//
//  imageXML.m
//  SugarSynDemo
//
//  Created by  Linksware Inc. on 23/08/12.
//  Copyright © VINAS Co., Ltd. 2011 - 2013. All rights reserved.
//

#import "imageXML.h"

@implementation imageXML

- (imageXML *) initXMLParser{
	
    self = [super init];
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName 
	attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"collectionContents"]) {
        
        APP.imageXML = [[NSMutableArray alloc]init];
        
    }
    
    else if([elementName isEqualToString:@"file"]){
        
        temp =[[NSMutableDictionary alloc]init];
    }
    //NSLog(@"Start Element = %@", elementName);
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
    
    if([elementName isEqualToString:@"collectionContents"])
        return;
    
    if([elementName isEqualToString:@"file"]) {
        
        [APP.imageXML addObject:temp];
    }
    
    else if([elementName isEqualToString:@"displayName"]){
        
        [temp setValue:currentElementValue forKey:@"displayName"];
    }
    else if([elementName isEqualToString:@"ref"]){
        
        [temp setValue:currentElementValue forKey:@"ref"];
    }
    else if ([elementName isEqualToString:@"fileData"]){
        [temp setValue:currentElementValue forKey:@"fileData"];
    }
    
    else {
        //NSLog(@"Problem Element Name = %@", elementName);
        
        if (currentElementValue) {
            
        }
        else {
        }
    }
    
    currentElementValue = nil;
    
    //NSLog(@"End Element = %@", elementName);
    //NSLog(@"App.albumarray = %@",APP.imageXML);
}

@end
