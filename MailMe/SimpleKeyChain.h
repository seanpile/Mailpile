//
// See Stackoverflow for Keychain implementation:
//
// http://stackoverflow.com/questions/5247912/saving-email-password-to-keychain-in-ios/5251820#5251820

#import <Foundation/Foundation.h>

@interface SimpleKeychain : NSObject

+ (void) save:(NSString *)service data:(id)data;
+ (id) load:(NSString *)service;
+ (void) delete:(NSString *)service;

@end