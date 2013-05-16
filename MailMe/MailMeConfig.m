//
//  MailMeConfig.m
//  MailMe
//
//  Created by Sean Dawson on 2013-05-15.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//

#import "MailMeConfig.h"
#import "SimpleKeyChain.h"
#import "MWLogging.h"

@implementation MailMeConfig

@synthesize name, email, hostname, username, password, useSSL, port;

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
    [aCoder encodeBool:useSSL
                forKey:@"useSSL"];
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
    [config setUseSSL:[aDecoder decodeBoolForKey:@"useSSL"]];
    [config setPort:[aDecoder decodeIntegerForKey:@"port"]];
    return config;
}

- (NSString *) description
{
    NSMutableString *desc = [[NSMutableString alloc] init];
    [desc appendString:@"MailMeConfig = {"];
    [desc appendString:[NSString stringWithFormat:@"name = \"%@\", ", name]];
    [desc appendString:[NSString stringWithFormat:@"email = \"%@\", ", email]];
    [desc appendString:[NSString stringWithFormat:@"hostname = \"%@\", ", hostname]];
    [desc appendString:[NSString stringWithFormat:@"username = \"%@\", ", username]];
    [desc appendString:[NSString stringWithFormat:@"useSSL = %d, ", useSSL]];
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
    MWLogDebug(@"Saving config to keychain: %@", self);
    [SimpleKeychain save:@"MailMeConfig"
                    data:self];
}

+ (MailMeConfig *) loadFromKeychain
{
    MailMeConfig *config = [SimpleKeychain load:@"MailMeConfig"];
    MWLogDebug(@"Loading config from keychain: %@", config);
    return config;
}

@end