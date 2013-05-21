//
//  MailMeConfig.m
//  MailMe
//
//  Created by Sean Dawson on 2013-05-15.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//
//  This file is released under the MIT License:
//  http://www.opensource.org/licenses/mit-license.php
//

#import "MailMeConfig.h"
#import "SimpleKeyChain.h"
#import "MWLogging.h"

@implementation MailMeConfig

@synthesize name, email, hostname, username, password, useAuth, connectionType, port;

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:name
                  forKey:@"name"];
    [aCoder encodeObject:email
                  forKey:@"email"];
    [aCoder encodeObject:hostname
                  forKey:@"hostname"];
    [aCoder encodeObject:username
                  forKey:@"username"];
    [aCoder encodeObject:password
                  forKey:@"password"];
    [aCoder encodeBool:useAuth
                forKey:@"useAuth"];
    [aCoder encodeInt:connectionType
               forKey:@"connectionType"];
    [aCoder encodeInteger:port
                   forKey:@"port"];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    MailMeConfig *config = [[MailMeConfig alloc] init];
    [config setName:[aDecoder decodeObjectForKey:@"name"]];
    [config setEmail:[aDecoder decodeObjectForKey:@"email"]];
    [config setHostname:[aDecoder decodeObjectForKey:@"hostname"]];
    [config setUsername:[aDecoder decodeObjectForKey:@"username"]];
    [config setPassword:[aDecoder decodeObjectForKey:@"password"]];
    [config setUseAuth:[aDecoder decodeBoolForKey:@"useAuth"]];
    [config setConnectionType:[aDecoder decodeIntForKey:@"connectionType"]];
    [config setPort:[aDecoder decodeIntegerForKey:@"port"]];
    return config;
}

- (NSString *) description
{
    // Note; do not log password!
    
    NSMutableString *desc = [[NSMutableString alloc] init];
    [desc appendString:@"MailMeConfig = {"];
    [desc appendString:[NSString stringWithFormat:@"name = \"%@\", ", name]];
    [desc appendString:[NSString stringWithFormat:@"email = \"%@\", ", email]];
    [desc appendString:[NSString stringWithFormat:@"hostname = \"%@\", ", hostname]];
    [desc appendString:[NSString stringWithFormat:@"username = \"%@\", ", username]];
    [desc appendString:[NSString stringWithFormat:@"useAuth = %d, ", useAuth]];
    [desc appendString:[NSString stringWithFormat:@"connectionType = %d, ", connectionType]];
    [desc appendString:[NSString stringWithFormat:@"port = %d", port]];
    [desc appendString:@"}"];
    return desc;
}

- (BOOL) isValid
{
    return [name length] > 0 && [email length] > 0 && [hostname length] > 0 && [username length] > 0 && port != 0;
}

- (void) saveToKeychain
{
    MWLogInfo(@"Saving config to keychain: %@", self);
    [SimpleKeychain save:@"MailMeConfig"
                    data:self];
}

+ (void) clearKeychain
{
    [SimpleKeychain delete:@"MailMeConfig"];
}

+ (MailMeConfig *) loadFromKeychain
{
    MailMeConfig *config = [SimpleKeychain load:@"MailMeConfig"];
    MWLogInfo(@"Loading config from keychain: %@", config);
    return config;
}

@end