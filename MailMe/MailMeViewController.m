//
//  MailMeViewController.m
//  MailMe
//
//  Created by Sean Dawson on 2013-05-14.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//

#import <MailCore/MailCore.h>
#import "MailMeViewController.h"
#import "MailMeConfig.h"
#import "MWLogging.h"

@interface MailMeViewController ()
{
    __strong MailMeConfig *config;
}

@end

@implementation MailMeViewController

@synthesize mailField, emailLabel, sendButton;
@synthesize progressView, progressViewIndicator;

- (void) viewDidLoad
{
    [super viewDidLoad];
    [mailField becomeFirstResponder];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(hideKeyboard)];
    [self.tableView
     addGestureRecognizer:gestureRecognizer];
    
    config = [MailMeConfig loadFromKeychain];
    MWLogDebug(@"%@", config);
    
    if (![config isValid])
    {
        [self performSegueWithIdentifier:@"ConfigureMail" sender:self];
    }
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    NSString *email = [config email];
    if (email)
    {
        [emailLabel setText:email];
    }
}

- (void) hideKeyboard
{
    [mailField resignFirstResponder];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MailMeConfgurationViewController *dest = segue.destinationViewController;
    [dest setConfig:config];
    [dest setDelegate:self];
}

- (void) setConfig:(MailMeConfig *)c
{
    MWLogDebug(@"Setting configuration: %@", c);
    config = c;
}

- (IBAction) sendEmail:(id)sender
{
    [mailField resignFirstResponder];
    [mailField setEditable:NO];
    [sendButton setEnabled:NO];
    [progressView setAlpha:1.0];
    [progressViewIndicator startAnimating];
    
    NSString *messageBody = [[mailField text] copy];
    
    if ([messageBody length] == 0)
    {
        MWLogDebug(@"Won't send an empty email, bailing");
        return;
    }
    
    if (![config isValid])
    {
        MWLogNotice(@"Cannot send with an invalid config, bailing");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        MWLogInfo(@"Attempting to send with config: %@", config);
        
        CTCoreMessage *msg = [[CTCoreMessage alloc] init];
        [msg setTo:[NSSet setWithObject:[CTCoreAddress addressWithName:[config name]
                                                                 email:[config email]]]];
        [msg setFrom:[NSSet setWithObject:[CTCoreAddress addressWithName:[config name]
                                                                   email:[config email]]]];
        [msg setSubject:messageBody];
        [msg setBody:@""];
        
        MWLogDebug(@"Created test message, now attempting to send");
        
        NSError *error;
        BOOL success = [CTSMTPConnection sendMessage:msg
                                              server:[config hostname]
                                            username:[config username]
                                            password:[config password]
                                                port:[config port]
                                      connectionType:([config useSSL] ? CTSMTPConnectionTypeStartTLS : CTSMTPConnectionTypePlain)
                                             useAuth:YES
                                               error:&error];
        
        if (!success)
        {
            MWLogError([error localizedDescription]);
        }
        else
        {
            MWLogInfo(@"Sent message to %@", [config email]);
        }
        
        // Dispatch back to the main queue to update the UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [progressViewIndicator stopAnimating];
            [sendButton setEnabled:YES];
            [progressView setAlpha:0.0];
            [mailField setEditable:YES];
            [mailField setText:@""];
        });
    });
}

@end