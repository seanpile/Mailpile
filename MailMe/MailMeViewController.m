//
//  MailMeViewController.m
//  MailMe
//
//  Created by Sean Dawson on 2013-05-14.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <MailCore/MailCore.h>
#import "MailMeViewController.h"
#import "MailMeConfig.h"
#import "MWLogging.h"
#import "UIUtil.h"

@interface MailMeViewController ()
{
    __strong MailMeConfig *config;
}

@end

@implementation MailMeViewController

@synthesize mailField, toLabel, configureLabel, emailLabel, sendButton;
@synthesize misconfiguredView;
@synthesize configureButton;

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(hideKeyboard)];
    [self.tableView
     addGestureRecognizer:gestureRecognizer];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(clearText)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.tableView
     addGestureRecognizer:doubleTap];
    
    config = [MailMeConfig loadFromKeychain];
    
    CGRect f = [toLabel frame];
    CGPoint fCenter = [toLabel center];
    [toLabel setFrame:CGRectMake(f.origin.x, f.origin.y, 0.0, f.size.height)];
    [toLabel sizeToFit];
    [toLabel setFrame:CGRectApplyAffineTransform([toLabel frame],
                                                 CGAffineTransformMakeTranslation(0.0, fCenter.y - toLabel.center.y))];
    
    CGFloat newSize = [toLabel bounds].size.width + 15.0;
    CGFloat newEmailScale = 1.0 - newSize / [emailLabel bounds].size.width;
    [emailLabel setFrame:
     CGRectApplyAffineTransform([emailLabel frame],
                                CGAffineTransformConcat(
                                                        CGAffineTransformMakeScale(newEmailScale, 1.0),
                                                        CGAffineTransformMakeTranslation(newSize, 0)))];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self navigationController] setToolbarHidden:YES];
    
    NSString *email = [config email];
    if (email)
    {
        [emailLabel setText:email];
    }
    else
    {
        [emailLabel setText:@""];
    }
    
    if (!config || ![config isValid])
    {
        [misconfiguredView setAlpha:1.0];
        [sendButton setEnabled:NO];
        [mailField resignFirstResponder];
        [mailField setEditable:NO];
    }
    else
    {
        [misconfiguredView setAlpha:0.0];
        [sendButton setEnabled:YES];
        [mailField becomeFirstResponder];
        [mailField setEditable:YES];
    }
}

- (void) clearText
{
    [mailField setText:@""];
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
    config = c;
}

- (IBAction) sendEmail:(id)sender
{
    NSString *currentTitle = [[self navigationItem] title];
    
    UINavigationBar *nav = [[self navigationController] navigationBar];
    [[self navigationItem] setTitleView:
     [UIUtil createSpinnerViewWithLabel:NSLocalizedString(@"Sending email ", @"Sending email ")
                                 forNav:nav]];
    
    [mailField resignFirstResponder];
    [mailField setEditable:NO];
    [sendButton setEnabled:NO];
    [configureButton setEnabled:NO];
    
    NSString *messageBody = [[mailField text] copy];
    
    if ([messageBody length] == 0)
    {
        MWLogDebug(@"Won 't send an empty email, bailing");
        return;
    }
    
    if (![config isValid])
    {
        MWLogNotice(@"Cannot send with an invalid config, bailing");
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        MWLogDebug(@"Attempting to send with config: %@", config);
        
        CTCoreMessage *msg = [[CTCoreMessage alloc] init];
        CTCoreAddress *address = [CTCoreAddress addressWithName:[config name]
                                                          email:[config email]];
        [msg setTo:[NSSet setWithObject:address]];
        [msg setFrom:[NSSet setWithObject:address]];
        [msg setSubject:messageBody];
        [msg setBody:@""];
        
        NSError *error;
        BOOL success = [CTSMTPConnection sendMessage:msg
                                              server:[config hostname]
                                            username:[config username]
                                            password:[config password]
                                                port:[config port]
                                      connectionType:[config connectionType]
                                             useAuth:[config useAuth]
                                               error:&error];
        address = nil;
        msg = nil;
        
        if (!success)
        {
            MWLogError(@"Error = %d: %@", error.code, error.localizedDescription);
        }
        else
        {
            MWLogDebug(@"Sent message to %@", [config email]);
        }
        
        // Dispatch back to the main queue to update the UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [sendButton setEnabled:YES];
            [configureButton setEnabled:YES];
            [mailField setEditable:YES];
            
            if (success)
            {
                [[self navigationItem] setTitleView:nil];
                [[self navigationItem] setTitle:currentTitle];
                [[self navigationItem] setPrompt:NSLocalizedString(@"Email sent!", "Email was successfully sent")];
                
                [mailField setText:@""];
                
                // Clear the prompt after 2 seconds
                double delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                    [[self navigationItem] setPrompt:nil];
                });
            }
            else
            {
                [[self navigationItem] setTitleView:nil];
                [[self navigationItem] setTitle:currentTitle];
                
                NSString *errorMessage;
                if (error.code == 17)
                {
                    errorMessage = NSLocalizedString(@"Invalid Username or Password", @"Invalid Username or Password");
                } else if (error.code == 25)
                {
                    errorMessage = NSLocalizedString(@"Connection Refused", @"Connection Refused");
                } else {
                    errorMessage = [error localizedDescription];
                }
                
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delivery Error", @"Indicates that an error in delivery occurred")
                                                             message:errorMessage
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel message")
                                                   otherButtonTitles:NSLocalizedString(@"Send Later", @"Send email for later delivery"), nil];
                [av show];
            }
        });
    });
}

# pragma mark -
# pragma mark UIAlertViewDelegate

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Cancel button
    if (buttonIndex == 0)
    {
        return;
    }
    
    MFMailComposeViewController *mvc = [[MFMailComposeViewController alloc] init];
    [mvc setSubject:[mailField text]];
    [mvc setMessageBody:@""
                 isHTML:NO];
    [mvc setToRecipients:[NSArray arrayWithObject:[config email]]];
    [mvc setMailComposeDelegate:self];
    
    [self presentViewController:mvc
                       animated:YES
                     completion:nil];
}

# pragma mark -
# pragma mark MFMailComposeViewControllerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES
                             completion: ^{
                                 [mailField setText:@""];
                                 
                                 [[self navigationItem] setTitleView:nil];
                                 
                                 if (result == MFMailComposeResultSaved ||
                                     result == MFMailComposeResultSent)
                                 {
                                     [[self navigationItem] setPrompt:NSLocalizedString(@"Email saved for later", "Email saved for later")];
                                     
                                     // Clear the prompt after 2 seconds
                                     double delayInSeconds = 2.0;
                                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                                     dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {
                                         [[self navigationItem] setPrompt:nil];
                                     });
                                 }
                             }];
}

@end