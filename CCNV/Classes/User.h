//
//  User.h
//  CCNV
//
//  Created by  Linksware Inc. on 9/21/2012.
//  Copyright (c) 2012  Linksware Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject
{
    int userID;
    NSString *strUserName;
    NSString *strFname;
    NSString *strLname;
    NSString *strEmail;
    NSString *strProductValue;
}
@property(nonatomic,readwrite)int userID;
@property(nonatomic,strong)NSString *strUserName;
@property(nonatomic,strong)NSString *strFname;
@property(nonatomic,strong)NSString *strLname;
@property(nonatomic,strong)NSString *strEmail;
@property(nonatomic,strong)NSString *strProductValue;
-(id)init;
@end
