//
//  TwitterWrapper.m
//  Tweeting
//
//  Created by Yaeda Takeshi on 12/03/10.
//  Copyright (c) 2012年 Apple Inc. All rights reserved.
//

#import "TwitterWrapper.h"
#import "TwitterWrapper_User.h"

@interface TwitterWrapper() {
    int _curAccountIndex;
}

@property (strong, nonatomic) ACAccountStore* accountStore;
@property (strong, nonatomic) NSArray* accountArray;


@end

@implementation TwitterWrapper

@synthesize accountStore = _accountStore;
@synthesize accountArray = _accountArray;

////////////////////////////////////////////////////////
//
// Private
//

- (id)init
{
    if (self = [super init]) {

        // Create an account store object.
        self.accountStore = [[ACAccountStore alloc] init];
        
        // Create an account type that ensures Twitter accounts are retrieved.
        ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        
        // Request access from the user to use their Twitter accounts.
        [self.accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted) {
                // Get the list of Twitter accounts.
                self.accountArray = [self.accountStore accountsWithAccountType:accountType];
            }
        }];
        
        _curAccountIndex = 0;
        
    }
    return self;
}

- (void)requestWithHandler:(NSString *)stringURL
                parameters:(NSDictionary *)parameters
             requestMethod:(TWRequestMethod)requestMethod
            successHandler:(TWWCallback_Dic)successHandler
              errorHandler:(TWWCallback_Dic)errorHandler
{

    TWRequest *postRequest = [[TWRequest alloc] initWithURL:[NSURL URLWithString:stringURL]
                                                 parameters:parameters
                                              requestMethod:requestMethod];

    if (requestMethod == TWRequestMethodPOST || requestMethod == TWRequestMethodDELETE) {
        if (!self.accountArray) {
            errorHandler([NSDictionary dictionaryWithObjectsAndKeys:@"No Account", @"Error", nil]);
            return;
        }
        ACAccount* account = [self.accountArray objectAtIndex:_curAccountIndex];
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
            
            errorHandler([NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:statusCode] forKey:@"status code"]);
            
        }
    }];
    
}

- (void)getFollowingIds:(TWWCallback_Arr)successHandler
           errorHandler:(TWWCallback_Dic)errorHandler
{
    if (!self.accountArray) {
        errorHandler([NSDictionary dictionaryWithObjectsAndKeys:@"No Account", @"Error", nil]);
        return;
    }
    ACAccount *account = [self.accountArray objectAtIndex:_curAccountIndex];
    
    [self requestWithHandler:@"http://api.twitter.com/1/friends/ids.json"
                  parameters:[NSDictionary dictionaryWithObjectsAndKeys:[account username], @"screen_name", nil]
               requestMethod:TWRequestMethodGET
              successHandler:^(NSDictionary *datas) {
        
        successHandler([datas objectForKey:@"ids"]);
        
    } errorHandler:^(NSDictionary *datas) {
        
        errorHandler(nil);
        
    }];
}

- (void)getFollowingsFromIds:(NSArray *)ids
              successHandler:(TWWCallback_Arr)successHandlerRecursive
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
               requestMethod:TWRequestMethodGET
              successHandler:^(NSDictionary *datas) {
                  NSMutableArray* followings = [[NSMutableArray alloc] init];
                  for (NSDictionary* d in datas) {
                      [followings addObject:[[TwitterWrapper_User alloc] initWithTwitterResponse:d]];
                  }
                  
                  successHandlerRecursive(followings);

                  if (callNext) {
                      [self getFollowingsFromIds:nextIds successHandler:successHandlerRecursive errorHandler:errorHandler];
                  }
                  
              } errorHandler:errorHandler];
}

////////////////////////////////////////////////////////
//
// Public
//

- (void)getPublicTimeline:(TWWCallback_Dic)successHandler
             errorHandler:(TWWCallback_Dic)errorHandler
{

    [self requestWithHandler:@"http://api.twitter.com/1/statuses/public_timeline.json"
                  parameters:nil
               requestMethod:TWRequestMethodGET
              successHandler:successHandler
                errorHandler:errorHandler];

}

- (void)getFollowings:(TWWCallback_Arr)successHandlerRecursive
         errorHandler:(TWWCallback_Dic)errorHandler
{

    [self getFollowingIds:^(NSArray *datas) {
        
        [self getFollowingsFromIds:datas successHandler:successHandlerRecursive errorHandler:errorHandler];
        
    } errorHandler:errorHandler];

}

- (void)postUpdate:(NSString *)text
 inReplyToStatusId:(NSNumber *)inReplyToStatusId
    successHandler:(TWWCallback_Dic)successHandler
      errorHandler:(TWWCallback_Dic)errorHandler
{
  
    NSDictionary *parameters = nil;
    if (!inReplyToStatusId) {
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:text, @"status", nil];
    } else {
        parameters = [NSDictionary dictionaryWithObjectsAndKeys:text, @"status", [NSString stringWithFormat:@"%d", inReplyToStatusId], @"in_reply_to_status_id", nil];
    }
    
    [self requestWithHandler:@"http://api.twitter.com/1/statuses/update.json"
                  parameters:parameters
               requestMethod:TWRequestMethodPOST
              successHandler:successHandler
                errorHandler:errorHandler
     ];
    
}


@end
