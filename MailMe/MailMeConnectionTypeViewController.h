//
//  MailMeConnectionTypeViewController.h
//  MailMe
//
//  Created by Sean Dawson on 2013-05-17.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//
//  This file is released under the MIT License:
//  http://www.opensource.org/licenses/mit-license.php
//

#ifndef _MailMeConnectionTypeViewController_h
#define _MailMeConnectionTypeViewController_h

#import <UIKit/UIKit.h>
#import "MailMeConfgurationViewController.h"

typedef void(^completion)(void);

@interface MailMeConnectionTypeViewController : UITableViewController

@property (nonatomic, weak) id <MailMeConnectionTypeDelegate> delegate;
@property (nonatomic, strong) completion handler;

@end

#endif