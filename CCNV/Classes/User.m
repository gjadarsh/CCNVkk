//
//  User.m
//  CCNV
//
//  Created by  Linksware Inc. on 9/21/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import "User.h"

@implementation User
@synthesize strEmail,strFname,strLname,strUserName,userID,strProductValue;

-(id)init{
    
    strFname=@"";
    strUserName=@"";
    strEmail=@"";
    strLname=@"";
    userID=0;
    strProductValue=@"";
    return self;
}

@end
