//
//  MailMeViewController.h
//  MailMe
//
//  Created by Sean Dawson on 2013-05-14.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailMeConfgurationViewController.h"

@interface MailMeViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, MailMeConfigurationDelegate>

@property (weak, nonatomic) IBOutlet UITextView *mailField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *toLabel;

@property (weak, nonatomic) IBOutlet UIView *misconfiguredView;
@property (weak, nonatomic) IBOutlet UIView *progressView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *progressViewIndicator;

@property (weak, nonatomic) IBOutlet UILabel *configureLabel;
@property (weak, nonatomic) IBOutlet UIButton *configureInfoButton;

- (IBAction) sendEmail:(id)sender;

@end