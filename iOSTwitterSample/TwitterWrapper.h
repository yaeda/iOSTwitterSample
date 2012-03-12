//
//  TwitterWrapper.h
//  Tweeting
//
//  Created by Yaeda Takeshi on 12/03/10.
//  Copyright (c) 2012年 Apple Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>
#import <Accounts/Accounts.h>

typedef void(^TWWCallback_Dic)(NSDictionary *datas);
typedef void(^TWWCallback_Arr)(NSArray *datas);

@interface TwitterWrapper : NSObject

+ (void)getPublicTimeline:(TWWCallback_Dic)successHandler
             errorHandler:(TWWCallback_Dic)errorHandler;

+ (void)getFollowings:(ACAccount *)account
         successHandler:(TWWCallback_Dic)successHandlerRecursive
           errorHandler:(TWWCallback_Dic)errorHandler;

+ (void)postUpdate:(ACAccount *)account
              text:(NSString *)text
 inReplyToStatusId:(NSNumber *)inReplyToStatusId
    successHandler:(TWWCallback_Dic)successHandler
      errorHandler:(TWWCallback_Dic)errorHandler;

@end
