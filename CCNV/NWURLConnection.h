//
//  NWURLConnection.h
//  CCNV
//
//  Created by Srishti on 04/02/14.
//
//

#import <Foundation/Foundation.h>

@interface NWURLConnection : NSObject
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, copy) void(^completionHandler)(NSURLResponse *response, NSData *data, NSError *error);

+ (NWURLConnection *)sendAsynchronousRequest:(NSURLRequest *)request queue:(NSOperationQueue *)queue completionHandler:(void(^)(NSURLResponse *response, NSData *data, NSError *error))completionHandler;
- (void)start;
- (void)cancel;


@end
