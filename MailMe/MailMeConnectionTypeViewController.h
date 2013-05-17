//
//  MailMeConnectionTypeViewController.h
//  MailMe
//
//  Created by Sean Dawson on 2013-05-17.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MailMeConfgurationViewController.h"

@interface MailMeConnectionTypeViewController : UITableViewController

@property (nonatomic, weak) id <MailMeConnectionTypeDelegate> delegate;

@end