//
//  TwitterWrapper.m
//  Tweeting
//
//  Created by Yaeda Takeshi on 12/03/10.
//  Copyright (c) 2012年 Apple Inc. All rights reserved.
//

#import "TwitterWrapper.h"

@interface TwitterWrapper()

+ (void)requestWithHandler:(NSString *)stringURL
                parameters:(NSDictionary *)paramters
                   account:(ACAccount *)account
             requestMethod:(TWRequestMethod)requestMethod
            successHandler:(TWWCallback_Dic)successHandler
              errorHandler:(TWWCallback_Dic)errorHandler;
    
+ (void)getFollowingIds:(ACAccount *)account
         successHandler:(TWWCallback_Arr)successHandler
           errorHandler:(TWWCallback_Dic)errorHandler;

+ (void)getFollowingsFromIds:(NSArray *)ids
              successHandler:(TWWCallback_Dic)successHandler
                errorHandler:(TWWCallback_Dic)errorHandler;

@end

@implementation TwitterWrapper

////////////////////////////////////////////////////////
//
// Private
//

+ (void)requestWithHandler:(NSString *)stringURL
                parameters:(NSDictionary *)parameters
                   account:(ACAccount *)account
             requestMethod:(TWRequestMethod)requestMethod
            successHandler:(TWWCallback_Dic)successHandler
              errorHandler:(TWWCallback_Dic)errorHandler
{

    TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:stringURL]
                                                 parameters:parameters
                                              requestMethod:requestMethod];

    if (account) {
        [postRequest setAccount:account];
    }
    
    [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        
        NSInteger statusCode = [urlResponse statusCode];
        if (statusCode == 200) {
            
            NSError *jsonParsingError = nil;
            NSDictionary *data = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:0 error:&jsonParsingError];

            successHandler(data);
            
        } else {
            
            errorHandler([NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:statusCode]
                                                     forKey:@"status code"]);
            
        }
    }];
    
}

+ (void)getFollowingIds:(ACAccount *)account
         successHandler:(TWWCallback_Arr)successHandler
           errorHandler:(TWWCallback_Dic)errorHandler
{
    [self requestWithHandler:@"http://api.twitter.com/1/friends/ids.json"
                  parameters:[NSDictionary dictionaryWithObjectsAndKeys:[account username], @"screen_name", nil]
                     account:nil
               requestMethod:TWRequestMethodGET
              successHandler:^(NSDictionary *datas) {
        
        successHandler([datas objectForKey:@"ids"]);
        
    } errorHandler:^(NSDictionary *datas) {
        
        errorHandler(nil);
        
    }];
}

+ (void)getFollowingsFromIds:(NSArray *)ids
              successHandler:(TWWCallback_Dic)successHandlerRecursive
                errorHandler:(TWWCallback_Dic)errorHandler
{    
    NSString *stringIds = nil;
    NSArray *nextIds = nil;
    BOOL callNext = [ids count] > 100;
    if (callNext) {
        stringIds = [NSString stringWithFormat:@"%@", [ids subarrayWithRange:NSMakeRange(0, 100)]];
        nextIds = [ids subarrayWithRange:NSMakeRange(100, [ids count] - 100)];
    } else {
        stringIds = [NSString stringWithFormat:@"%@", ids];
    }
    
    [self requestWithHandler:@"http://api.twitter.com/1/users/lookup.json"
                  parameters:[NSDictionary dictionaryWithObjectsAndKeys:stringIds, @"user_id", nil]
                     account:nil requestMethod:TWRequestMethodGET
              successHandler:^(NSDictionary *datas) {
                         
                         successHandlerRecursive(datas);
                         if (callNext) {
                             [self getFollowingsFromIds:nextIds successHandler:successHandlerRecursive errorHandler:errorHandler];
                         }

                     } errorHandler:errorHandler];
}

////////////////////////////////////////////////////////
//
// Public
//

+ (void)getPublicTimeline:(TWWCallback_Dic)successHandler
             errorHandler:(TWWCallback_Dic)errorHandler {
    [self requestWithHandler:@"http://api.twitter.com/1/statuses/public_timeline.json"
                  parameters:nil
                     account:nil
               requestMethod:TWRequestMethodGET
              successHandler:successHandler
                errorHandler:errorHandler];
}

+ (void)getFollowings:(ACAccount *)account
       successHandler:(TWWCallback_Dic)successHandlerRecursive
         errorHandler:(TWWCallback_Dic)errorHandler
{
    [self getFollowingIds:account successHandler:^(NSArray *datas) {
        
        [self getFollowingsFromIds:datas successHandler:successHandlerRecursive errorHandler:errorHandler];
        
    } errorHandler:errorHandler];
}

+ (void)postUpdate:(ACAccount *)account text:(NSString *)text inReplyToStatusId:(NSNumber *)inReplyToStatusId successHandler:(TWWCallback_Dic)successHandler errorHandler:(TWWCallback_Dic)errorHandler {
  
    NSDictionary *parameters = nil;
    if (!inReplyToStatusId) {
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:text, @"status", nil];
    } else {
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:text, @"status", [NSString stringWithFormat:@"%d", inReplyToStatusId], @"in_reply_to_status_id", nil];
    }
    
    [self requestWithHandler:@"http://api.twitter.com/1/statuses/update.json"
                  parameters:parameters
                     account:account
               requestMethod:TWRequestMethodPOST
              successHandler:successHandler
                errorHandler:errorHandler
     ];
    
}


@end
