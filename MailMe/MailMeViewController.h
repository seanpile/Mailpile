//
//  MailMeViewController.h
//  MailMe
//
//  Created by Sean Dawson on 2013-05-14.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MailMeConfgurationViewController.h"

@interface MailMeViewController : UITableViewController
<UITableViewDataSource, UITableViewDelegate,
UITextViewDelegate, MailMeConfigurationDelegate,
UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *mailField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *configureButton;

@property (weak, nonatomic) IBOutlet UIView *misconfiguredView;
@property (weak, nonatomic) IBOutlet UILabel *configureLabel;

- (IBAction) sendEmail:(id)sender;

@end