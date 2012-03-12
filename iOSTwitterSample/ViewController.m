//
//  ViewController.m
//  iOSTwitterSample
//
//  Created by Yaeda Takeshi on 12/03/11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

#import "ViewController.h"
#import "TwitterWrapper.h"

@implementation ViewController

@synthesize sendEasyTweeetButton;
@synthesize sendCustomTweetButton;
@synthesize getPublicTimelineButton;
@synthesize getFollowingInfoButotn;
@synthesize inputTextField;
@synthesize outputTextView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // This notification is posted when the accounts managed by this account store changed in the database.
    // When you receive this notification, you should refetch all account objects.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(canTweetStatus) name:ACAccountStoreDidChangeNotification object:nil];

}

- (void)viewDidUnload
{
    [self setInputTextField:nil];
    [self setOutputTextView:nil];
    [self setSendEasyTweeetButton:nil];
    [self setSendCustomTweetButton:nil];
    [self setGetPublicTimelineButton:nil];
    [self setGetFollowingInfoButotn:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)sendEasyTweet:(id)sender
{

    // Close keyboard
    [self.inputTextField resignFirstResponder];

    // Set up the built-in twitter composition view controller.
    TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
    
    // Set the initial tweet text. See the framework for additional properties that can be set.
    [tweetViewController setInitialText:@"Hello. This is a tweet."];
    
    // Create the completion handler block.
    [tweetViewController setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
        NSString *output;
        
        switch (result) {
            case TWTweetComposeViewControllerResultCancelled:
                // The cancel button was tapped.
                output = @"Tweet cancelled.";
                break;
            case TWTweetComposeViewControllerResultDone:
                // The tweet was sent.
                output = @"Tweet done.";
                break;
            default:
                break;
        }
        
        [self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
        
        // Dismiss the tweet composition view controller.
        [self dismissModalViewControllerAnimated:YES];
    }];
    
    // Present the tweet composition view controller modally.
    [self presentModalViewController:tweetViewController animated:YES];
    
}

- (IBAction)sendCustomTweet:(id)sender
{
    // Close keyboard
    [self.inputTextField resignFirstResponder];
    
	// Create an account store object.
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	
	// Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	// Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
			// Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			
			// For the sake of brevity, we'll assume there is only one Twitter account present.
			// You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
			if ([accountsArray count] > 0) {
				// Grab the initial Twitter account to tweet from.
				ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
				
                [TwitterWrapper postUpdate:twitterAccount text:inputTextField.text inReplyToStatusId:nil successHandler:^(NSDictionary *datas) {
                    
                    // Clear the text
                    self.inputTextField.text = @"";
                    
                    // Output status
                    NSString *output = [NSString stringWithFormat:@"Success :\n%@", datas];
                    [self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
                    
                } errorHandler:^(NSDictionary *datas) {
                    
                    // Output error code
                    NSString *output = [NSString stringWithFormat:@"Error :\n%@", datas];
                    [self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
                    
                }];                
			}
        }
	}];

}

- (IBAction)getPublicTimeline:(id)sender
{

    // Close keyboard
    [self.inputTextField resignFirstResponder];

    [TwitterWrapper getPublicTimeline:^(NSDictionary *datas) {
        
        NSString *output = [NSString stringWithFormat:@"Public Timeline:\n%@", datas];
        [self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
        
    } errorHandler:^(NSDictionary *datas) {
        
        NSString *output = [NSString stringWithFormat:@"ERROR : %@\n", datas];
        [self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
        
    }];

}

- (IBAction)getFollowingsInfo:(id)sender
{

    // Close keyboard
    [self.inputTextField resignFirstResponder];

    // Create an account store object.
	ACAccountStore *accountStore = [[ACAccountStore alloc] init];
	
	// Create an account type that ensures Twitter accounts are retrieved.
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
	
	// Request access from the user to use their Twitter accounts.
    [accountStore requestAccessToAccountsWithType:accountType withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
			// Get the list of Twitter accounts.
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
			
			// For the sake of brevity, we'll assume there is only one Twitter account present.
			// You would ideally ask the user which account they want to tweet from, if there is more than one Twitter account present.
			if ([accountsArray count] > 0) {
				// Grab the initial Twitter account to tweet from.
				ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                
				[TwitterWrapper getFollowings:twitterAccount successHandler:^(NSDictionary *datas) {
                    
                    
                    NSString *output = [NSString stringWithFormat:@"Following Info:\n%@", datas];
                    [self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
                    
                    
                } errorHandler:^(NSDictionary *datas) {
                    
                    NSString *output = [NSString stringWithFormat:@"ERROR : %@\n", datas];
                    [self performSelectorOnMainThread:@selector(displayText:) withObject:output waitUntilDone:NO];
                    
                }];
                
                
            }
        }
    }];

}

- (void)displayText:(NSString *)text
{

    self.outputTextView.text = text;

}

- (void)canTweetStatus
{

    if ([TWTweetComposeViewController canSendTweet]) {
        self.sendEasyTweeetButton.enabled = YES;
        self.sendEasyTweeetButton.alpha = 1.0f;
        self.sendCustomTweetButton.enabled = YES;
        self.sendCustomTweetButton.alpha = 1.0f;
        self.inputTextField.enabled = YES;
        self.inputTextField.alpha = 1.0f;
        self.getFollowingInfoButotn.enabled = YES;
        self.getFollowingInfoButotn.alpha = 1.0f;
    } else {
        self.sendEasyTweeetButton.enabled = NO;
        self.sendEasyTweeetButton.alpha = 0.5f;
        self.sendCustomTweetButton.enabled = NO;
        self.sendCustomTweetButton.alpha = 0.5f;
        self.inputTextField.enabled = NO;
        self.inputTextField.alpha = 0.5f;
        self.getFollowingInfoButotn.enabled = NO;
        self.getFollowingInfoButotn.alpha = 0.5f;
    }

}
@end
