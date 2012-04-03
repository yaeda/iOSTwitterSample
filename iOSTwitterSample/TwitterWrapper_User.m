//
//  TwitterWrapper_User.m
//  iOSTwitterSample
//
//  Created by Yaeda Takeshi on 12/03/31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TwitterWrapper_User.h"

@implementation TwitterWrapper_User

@synthesize id_str, name, screen_name, profile_text, url, icon_url, icon;

- (id)init
{
    self.id_str = nil;
    self.name = nil;
    self.screen_name = nil;
    self.profile_text = nil;
    self.url = nil;
    self.icon_url = nil; // TODO : default icon path
    self.icon = nil; // TODO : default icon

    return self;
}

- (id)initWithTwitterResponse:(NSDictionary*)response
{
    self = [self init];
    if (self != nil) {
        self.id_str = [response objectForKey:@"id_str"];
        self.name = [response objectForKey:@"name"];
        self.screen_name = [response objectForKey:@"screen_name"];
        self.profile_text = [response objectForKey:@"description"];
        self.url = [response objectForKey:@"url"];
        self.icon_url = [response objectForKey:@"profile_image_url"];
    }
    return self;
}

- (NSString*)description
{
    NSMutableString* str = [[NSMutableString alloc] init];
    [str appendFormat:@"id_str : %@, ", self.id_str];
    [str appendFormat:@"name   : %@, ", self.name];
    [str appendFormat:@"screen_name : %@, ", self.screen_name];
    [str appendFormat:@"description : %@, ", self.profile_text];
    [str appendFormat:@"url : %@, ", self.url];
    [str appendFormat:@"profile_image_url : %@", self.icon_url];
    
    return str;
}

@end
