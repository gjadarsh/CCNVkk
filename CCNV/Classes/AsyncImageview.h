//
//  AsyncImageview.h
//  CCNV
//
//  Created by  Linksware Inc. on 1/16/2013.
//
//

#import <Foundation/Foundation.h>
#import "File.h"
@interface AsyncImageview : UIImageView
{
    File *objFile;
    NSURLConnection *Connection2;
    NSMutableData *ResponseData2;
    NSURLConnection *Connection1;
    NSMutableData *ResponseData1;

}
@property(nonatomic,strong)File *objFile;
-(void)loadThumbnailImage:(File*)fileObj;
-(id)init :(File *)file;
@end
