//
//  MailMeConfgurationViewController.m
//  MailMe
//
//  Created by Sean Dawson on 2013-05-15.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//

#import "MailMeConfgurationViewController.h"
#import "MailMeConfig.h"
#import "SimpleKeyChain.h"

@interface MailMeConfgurationViewController ()

@end

@implementation MailMeConfgurationViewController

@synthesize delegate;
@synthesize config;
@synthesize nameField;
@synthesize emailField;
@synthesize hostField;
@synthesize userNameField;
@synthesize passwordField;
@synthesize portField;
@synthesize useSSLField;

- (id) initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    [nameField setText:[config name]];
    [emailField setText:[config email]];
    [hostField setText:[config hostname]];
    [userNameField setText:[config username]];
    [passwordField setText:[config password]];
    [portField setText:[NSString stringWithFormat:@"%d", [config port]]];
    [useSSLField setOn:[config useSSL]];
}

- (void) didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == emailField)
    {
        if ([[textField text] hasSuffix:@"gmail.com"])
        {
            [hostField setText:@"smtp.gmail.com"];
            [userNameField setText:[emailField text]];
            [useSSLField setOn:YES];
            [portField setText:@"587"];
        }
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSArray *orderedFields = @[nameField, emailField, hostField, userNameField, passwordField, portField];
    
    NSUInteger idx = [orderedFields indexOfObject:textField];
    if (idx < [orderedFields count] - 1)
    {
        [[orderedFields objectAtIndex:(idx + 1)] becomeFirstResponder];
    }
    
    return YES;
}

- (IBAction) saveConfig:(id)sender
{
    MailMeConfig *c = [[MailMeConfig alloc] init];
    [c setName:[nameField text]];
    [c setEmail:[emailField text]];
    [c setHostname:[hostField text]];
    [c setUsername:[userNameField text]];
    [c setPassword:[passwordField text]];
    [c setUseSSL:[useSSLField isOn]];
    [c setPort:[[portField text] integerValue]];
    [c saveToKeychain];
    [delegate setConfig:c];
    
    [[self navigationController] popViewControllerAnimated:YES];
}

@end