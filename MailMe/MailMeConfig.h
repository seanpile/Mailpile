//
//  MailMeConfig.h
//  MailMe
//
//  Created by Sean Dawson on 2013-05-15.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//

#ifndef _MailMeConfig_h
#define _MailMeConfig_h

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

@interface MailMeConfig : NSObject <NSCoding>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *hostname;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic) BOOL useAuth;
@property (nonatomic) CTSMTPConnectionType connectionType;
@property (nonatomic) NSUInteger port;

- (void)           saveToKeychain;
+ (MailMeConfig *) loadFromKeychain;
+ (void)           clearKeychain;
- (BOOL)           isValid;

@end

#endif