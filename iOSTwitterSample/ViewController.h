//
//  ViewController.h
//  iOSTwitterSample
//
//  Created by Yaeda Takeshi on 12/03/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *sendEasyTweeetButton;
@property (weak, nonatomic) IBOutlet UIButton *sendCustomTweetButton;
@property (weak, nonatomic) IBOutlet UIButton *getPublicTimelineButton;
@property (weak, nonatomic) IBOutlet UIButton *getFollowingInfoButotn;
@property (weak, nonatomic) IBOutlet UITextField *inputTextField;
@property (weak, nonatomic) IBOutlet UITextView *outputTextView;

- (IBAction)sendEasyTweet:(id)sender;
- (IBAction)sendCustomTweet:(id)sender;
- (IBAction)getPublicTimeline:(id)sender;
- (IBAction)getFollowingsInfo:(id)sender;

- (void)displayText:(NSString *)text;
- (void)handleSwipeDownGesture:(UISwipeGestureRecognizer *)sender;
- (void)canTweetStatus;

@end
