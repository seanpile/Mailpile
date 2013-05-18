//
//  MailMeConnectionTypeViewController.m
//  MailMe
//
//  Created by Sean Dawson on 2013-05-17.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//

#import "MailMeConnectionTypeViewController.h"

@interface MailMeConnectionTypeViewController ()

@end

@implementation MailMeConnectionTypeViewController

@synthesize delegate, handler;

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == [delegate connectionType])
    {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
    [delegate setConnectionType:[indexPath row]];
    [[self presentingViewController] dismissViewControllerAnimated:YES
                                                        completion:handler];
}

@end