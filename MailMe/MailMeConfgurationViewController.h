//
//  MailMeConfgurationViewController.h
//  MailMe
//
//  Created by Sean Dawson on 2013-05-15.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//

#ifndef _MailMeConfigurationDelegate_h
#define _MailMeConfigurationDelegate_h

#import <UIKit/UIKit.h>
#import <MailCore/MailCore.h>
#import "MailMeConfig.h"

@protocol MailMeConfigurationDelegate <NSObject>

- (void) setConfig:(MailMeConfig *)config;

@end

@protocol MailMeConnectionTypeDelegate <NSObject>

- (CTSMTPConnectionType) connectionType;

- (void) setConnectionType:(CTSMTPConnectionType)type;

@end

@interface MailMeConfgurationViewController : UITableViewController <UITextFieldDelegate, MailMeConnectionTypeDelegate>

@property (nonatomic, strong) id <MailMeConfigurationDelegate> delegate;
@property (nonatomic, strong) MailMeConfig *config;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *hostField;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *portField;
@property (weak, nonatomic) IBOutlet UISwitch *useAuthField;
@property (weak, nonatomic) IBOutlet UITableViewCell *connectionTypeCell;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *hostLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *portLabel;
@property (weak, nonatomic) IBOutlet UILabel *useAuthLabel;

- (IBAction) saveConfig:(id)sender;
- (IBAction) removeConfig:(id)sender;

@end

#endif