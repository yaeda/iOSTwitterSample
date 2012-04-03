//
//  TwitterWrapper_User.h
//  iOSTwitterSample
//
//  Created by Yaeda Takeshi on 12/03/31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TwitterWrapper_User : NSObject

@property (strong, nonatomic) NSString* id_str;
@property (strong, nonatomic) NSString* name;
@property (strong, nonatomic) NSString* screen_name;
@property (strong, nonatomic) NSString* profile_text;
@property (strong, nonatomic) NSString* url;
@property (strong, nonatomic) NSString* icon_url;
@property (strong, nonatomic) UIImage* icon;

- (id)initWithTwitterResponse:(NSDictionary*)response;

@end
