//
//  MailMeConfgurationViewController.h
//  MailMe
//
//  Created by Sean Dawson on 2013-05-15.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailMeConfig.h"

@protocol MailMeConfigurationDelegate <NSObject>

- (void) setConfig:(MailMeConfig *)config;

@end

@interface MailMeConfgurationViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) id <MailMeConfigurationDelegate> delegate;
@property (nonatomic, strong) MailMeConfig *config;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *hostField;
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *portField;
@property (weak, nonatomic) IBOutlet UISwitch *useSSLField;

- (IBAction) saveConfig:(id)sender;

@end