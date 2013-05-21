//
//  MailMeConfgurationViewController.m
//  MailMe
//
//  Created by Sean Dawson on 2013-05-15.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//
//  This file is released under the MIT License:
//  http://www.opensource.org/licenses/mit-license.php
//

#import <MailCore/MailCore.h>
#import "MWLogging.h"
#import "MailMeConfgurationViewController.h"
#import "MailMeConnectionTypeViewController.h"
#import "MailMeConfig.h"
#import "SimpleKeyChain.h"
#import "UIUtil.h"

static NSString *const kHost = @"Host";
static NSString *const kUser = @"User";
static NSString *const kConnectionType = @"ConnectionType";
static NSString *const kAuth = @"Auth";
static NSString *const kPort = @"Port";
static NSDictionary *defaultServerValues;

typedef enum
{
    HeaderFieldsEmpty = 0,
    HeaderFieldsPopulated,
    TestingConnection
} ConfigurationState;

@interface MailMeConfgurationViewController ()
{
    NSArray *labels;
    NSArray *orderedTextFields;
    CTSMTPConnectionType connectionType;
}

@property (atomic) BOOL hasDisappeared;

- (void) setFormState:(ConfigurationState)state;

- (void) sizeLabel:(UILabel *)label andTextField:(UITextField *)field;
- (void) sizeLabels:(NSArray *)labels andTextFields:(NSArray *)fields;

@end

@implementation MailMeConfgurationViewController

@synthesize hasDisappeared;
@synthesize delegate;
@synthesize config;
@synthesize nameField;
@synthesize emailField;
@synthesize hostField;
@synthesize userNameField;
@synthesize passwordField;
@synthesize portField;
@synthesize useAuthField;
@synthesize nameLabel, useAuthLabel, emailLabel, hostLabel, usernameLabel, passwordLabel, portLabel;
@synthesize connectionTypeCell;


- (void) viewDidLoad
{
    [super viewDidLoad];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSNumber *const tStartTLS = [NSNumber numberWithInt:CTSMTPConnectionTypeStartTLS];
        NSNumber *const tTLS = [NSNumber numberWithInt:CTSMTPConnectionTypeTLS];
        NSNumber *const p465 = [NSNumber numberWithInt:465];
        NSNumber *const p587 = [NSNumber numberWithInt:587];
        
        defaultServerValues = @{
                                @"gmail.com" : @{
                                        kHost : @"smtp.gmail.com",
                                        kConnectionType : tStartTLS,
                                        kPort : p587
                                        },
                                @"live.com" : @{
                                        kHost : @"smtp.live.com",
                                        kConnectionType : tStartTLS,
                                        kPort : p587
                                        },
                                @"yahoo.com" : @{
                                        kHost : @"smtp.mail.yahoo.com",
                                        kConnectionType : tTLS,
                                        kPort : p465
                                        },
                                @"yahoo.co.uk" : @{
                                        kHost : @"smtp.mail.yahoo.co.uk",
                                        kConnectionType : tTLS,
                                        kPort : p465
                                        },
                                @"yahoo.de" : @{
                                        kHost : @"smtp.mail.yahoo.de",
                                        kConnectionType : tTLS,
                                        kPort : p465
                                        },
                                @"yahoo.com.au" : @{
                                        kHost : @"smtp.mail.yahoo.com.au",
                                        kConnectionType : tTLS,
                                        kPort : p465
                                        },
                                @"comcast.net" : @{
                                        kHost : @"smtp.comcast.net",
                                        kConnectionType : tStartTLS,
                                        kPort : p587
                                        },
                                @"verizon.net" : @{
                                        kHost : @"outgoing.verizon.net",
                                        kConnectionType : tTLS,
                                        kPort : p465
                                        },
                                };
    });
    
    [[self navigationController] setToolbarHidden:(config == nil)];
    
    orderedTextFields = @[nameField, emailField, hostField, userNameField, passwordField, portField];
    labels = @[nameLabel, emailLabel, hostLabel, usernameLabel, passwordLabel, useAuthLabel, portLabel];
    
    [nameField setText:[config name]];
    [emailField setText:[config email]];
    [hostField setText:[config hostname]];
    [userNameField setText:[config username]];
    [passwordField setText:[config password]];
    [useAuthField setOn:[config useAuth]];
    [self setConnectionType:[config connectionType]];
    
    if ([config port] != 0)
    {
        [portField setText:[NSString stringWithFormat:@"%d", [config port]]];
    }
    
    // Need to call this when view loads to initialize colors
    if (![config email] || [[config email] length] == 0)
    {
        [self setFormState:HeaderFieldsEmpty];
    }
    else
    {
        [self setFormState:HeaderFieldsPopulated];
    }
    
    // Align these columns
    [self sizeLabels:[NSArray arrayWithObjects:nameLabel, emailLabel, nil]
       andTextFields:[NSArray arrayWithObjects:nameField, emailField, nil]];
    
    [self sizeLabel:hostLabel
       andTextField:hostField];
    [self sizeLabel:usernameLabel
       andTextField:userNameField];
    [self sizeLabel:passwordLabel
       andTextField:passwordField];
    [self sizeLabel:useAuthLabel
       andTextField:nil];
    [self sizeLabel:portLabel
       andTextField:portField];
}

- (void) sizeLabel:(UILabel *)label andTextField:(UITextField *)field;
{
    [self sizeLabels:[NSArray arrayWithObject:label]
       andTextFields:(field == nil ? [NSArray array] : [NSArray arrayWithObject:field])];
}

- (void) sizeLabels:(NSArray *)lbs andTextFields:(NSArray *)fields;
{
    CGFloat maxWidth = 0.0;
    for (UILabel *l in lbs)
    {
        // First shrink to 0 width, and then size to fit
        CGRect f = [l frame];
        [l setFrame:CGRectMake(f.origin.x, f.origin.y, 0.0, f.size.height)];
        [l sizeToFit];
        CGFloat width = [l frame].size.width;
        if (width > maxWidth)
        {
            maxWidth = width;
        }
    }
    
    
    CGFloat newSize = maxWidth + 20.0;
    
    for (UITextField *tf in fields)
    {
        CGFloat newTextFieldScale = 1.0 - newSize / [tf frame].size.width;
        [tf setFrame:
         CGRectApplyAffineTransform([tf frame],
                                    CGAffineTransformConcat(
                                                            CGAffineTransformMakeScale(newTextFieldScale, 1.0),
                                                            CGAffineTransformMakeTranslation(newSize, 0)))];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    hasDisappeared = YES;
}

- (CTSMTPConnectionType) connectionType
{
    return connectionType;
}

- (void) setConnectionType:(CTSMTPConnectionType)type
{
    /* Note: it doesn't make sense to localize these strings since they are technical constants */
    
    connectionType = type;
    switch (connectionType)
    {
        case CTSMTPConnectionTypePlain:
        {
            [[connectionTypeCell detailTextLabel] setText:@"Plain"];
            break;
        }
            
        case CTSMTPConnectionTypeStartTLS:
        {
            [[connectionTypeCell detailTextLabel] setText:@"StartTLS"];
            break;
        }
            
        case CTSMTPConnectionTypeTLS:
        {
            [[connectionTypeCell detailTextLabel] setText:@"TLS"];
            break;
        }
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == emailField)
    {
        // Autopopulate if we recognize the server
        
        BOOL found = NO;
        for (NSString *suffix in[defaultServerValues allKeys])
        {
            if ([[textField text] hasSuffix:suffix])
            {
                NSDictionary *values = [defaultServerValues objectForKey:suffix];
                NSString *host = [values objectForKey:kHost];
                NSNumber *cType = [values objectForKey:kConnectionType];
                NSNumber *port = [values objectForKey:kPort];
                
                if (host)
                {
                    [hostField setText:host];
                }
                
                if (cType)
                {
                    [self setConnectionType:[cType intValue]];
                }
                
                if (port)
                {
                    [portField setText:[port stringValue]];
                }
                
                [userNameField setText:[emailField text]];
                [useAuthField setOn:YES];
                found = YES;
                break;
            }
        }
        
        if (!found)
        {
            // Default sane configuration...
            [userNameField setText:[emailField text]];
            [useAuthField setOn:YES];
            [self setConnectionType:CTSMTPConnectionTypeStartTLS];
            [portField setText:@"587"];
        }
        
        if ([[emailField text] length] > 0)
        {
            [self setFormState:HeaderFieldsPopulated];
        }
    }
}

- (BOOL) canBecomeFirstResponder
{
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    NSUInteger idx = [orderedTextFields indexOfObject:textField];
    if (idx < [orderedTextFields count] - 1)
    {
        [[orderedTextFields objectAtIndex:(idx + 1)] becomeFirstResponder];
    }
    
    return YES;
}

- (void) setFormState:(ConfigurationState)state
{
    BOOL enabled = (state == HeaderFieldsPopulated);
    
    UIColor *labelFieldColor = [UIColor blackColor];
    UIColor *textFieldColor = [UIColor colorWithRed:56.0 / 255.0
                                              green:84.0 / 255.0
                                               blue:135.0 / 255.0
                                              alpha:1.0];
    
    for (UILabel *label in labels)
    {
        if (enabled)
        {
            [label setTextColor:labelFieldColor];
        }
        else
        {
            [label setTextColor:[UIColor lightGrayColor]];
        }
    }
    
    for (UITextField *tf in orderedTextFields)
    {
        [tf setEnabled:enabled];
        if (enabled)
        {
            [tf setTextColor:textFieldColor];
        }
        else
        {
            [tf setTextColor:[UIColor lightGrayColor]];
        }
    }
    
    [useAuthField setEnabled:enabled];
    
    [connectionTypeCell setUserInteractionEnabled:enabled];
    if (enabled)
    {
        [[connectionTypeCell textLabel] setTextColor:labelFieldColor];
        [[connectionTypeCell detailTextLabel] setTextColor:textFieldColor];
    }
    else
    {
        [[connectionTypeCell textLabel] setTextColor:[UIColor lightGrayColor]];
        [[connectionTypeCell detailTextLabel] setTextColor:[UIColor lightGrayColor]];
    }
    
    if (state == HeaderFieldsEmpty)
    {
        // Re-enable the Name/Email fields
        [nameField setEnabled:YES];
        [nameField setTextColor:textFieldColor];
        [nameLabel setTextColor:labelFieldColor];
        [emailField setEnabled:YES];
        [emailField setTextColor:textFieldColor];
        [emailLabel setTextColor:labelFieldColor];
    }
}

- (IBAction) saveConfig:(id)sender
{
    NSString *currentTitle = [[self navigationItem] title];
    
    [[self navigationItem] setPrompt:nil];
    [[self view] endEditing:YES];
    [self setFormState:TestingConnection];
    
    MailMeConfig *c = [[MailMeConfig alloc] init];
    [c setName:[nameField text]];
    [c setEmail:[emailField text]];
    [c setHostname:[hostField text]];
    [c setUsername:[userNameField text]];
    [c setPassword:[passwordField text]];
    [c setUseAuth:[useAuthField isOn]];
    [c setConnectionType:connectionType];
    [c setPort:[[portField text] integerValue]];
    
    UINavigationBar *nav = [[self navigationController] navigationBar];
    
    [[self navigationItem] setTitleView:
     [UIUtil createSpinnerViewWithLabel:NSLocalizedString(@"Testing Connection", @"Testing Connection")
                                 forNav:nav]];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error;
        BOOL success = [CTSMTPConnection canConnectToServer:[c hostname]
                                                   username:[c username]
                                                   password:[c password]
                                                       port:[c port]
                                             connectionType:[c connectionType]
                                                    useAuth:[c useAuth]
                                                      error:&error];
        
        if (!success)
        {
            MWLogError(@"Error = %d: %@", error.code, error.localizedDescription);
        }
        else
        {
            MWLogDebug(@"Confirmed SMTP server: %@", c);
        }
        
        // Dispatch back to the main queue to update the UI
        dispatch_async(dispatch_get_main_queue(), ^{
            // Don't save if the user cancelled the action
            if (hasDisappeared)
            {
                MWLogDebug(@"Won't save since the user has cancelled the view!");
                return;
            }
            
            if (success)
            {
                [c saveToKeychain];
                [delegate setConfig:c];
                [[self navigationController] popViewControllerAnimated:YES];
            }
            else
            {
                [[self navigationItem] setTitleView:nil];
                [[self navigationItem] setTitle:currentTitle];
                [self setFormState:HeaderFieldsPopulated];
                
                NSString *errorMessage;
                if (error.code == 17)
                {
                    errorMessage = NSLocalizedString(@"Invalid Username or Password", @"Invalid Username or Password");
                }
                else if (error.code == 25)
                {
                    errorMessage = NSLocalizedString(@"Connection Refused", @"Connection Refused");
                }
                else
                {
                    errorMessage = [error localizedDescription];
                }
                
                
                UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Error", @"Indicates that an error in delivery occurred")
                                                             message:errorMessage
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
                [av show];
            }
        });
    });
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [[self view] endEditing:YES];
    MailMeConnectionTypeViewController *ctv = [segue destinationViewController];
    [ctv setDelegate:self];
    [ctv setHandler: ^{
        NSIndexPath *indexPathForCell = [[self tableView] indexPathForCell:connectionTypeCell];
        MWLogDebug(@"indexPath = %@", indexPathForCell);
        [[self tableView] scrollToRowAtIndexPath:indexPathForCell
                                atScrollPosition:UITableViewScrollPositionNone
                                        animated:YES];
    }];
}

- (IBAction) removeConfig:(id)sender
{
    [MailMeConfig clearKeychain];
    [delegate setConfig:nil];
    [[self navigationController] popViewControllerAnimated:YES];
}

@end