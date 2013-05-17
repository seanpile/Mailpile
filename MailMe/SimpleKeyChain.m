//
// See Stackoverflow for Keychain implementation:
//
// http://stackoverflow.com/questions/5247912/saving-email-password-to-keychain-in-ios/5251820#5251820

#import "SimpleKeychain.h"

@implementation SimpleKeychain

+ (NSMutableDictionary *) getKeychainQuery:(NSString *)service
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (id)kSecClassGenericPassword, (id)kSecClass,
            service, (id)kSecAttrService,
            service, (id)kSecAttrAccount,
#if TARGET_OS_IPHONE
            (id)kSecAttrAccessibleAfterFirstUnlock, (id)kSecAttrAccessible,
#endif
            nil];
}

+ (void) save:(NSString *)service data:(id)data
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data]
                      forKey:(id)kSecValueData];
    SecItemAdd((CFDictionaryRef)keychainQuery, NULL);
}

+ (id) load:(NSString *)service
{
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    [keychainQuery setObject:(id)kCFBooleanTrue
                      forKey:(id)kSecReturnData];
    [keychainQuery setObject:(id)kSecMatchLimitOne
                      forKey:(id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr)
    {
        @try
        {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)keyData];
        }
        @catch (NSException *e)
        {
            NSLog(@"Unarchive of %@ failed: %@", service, e);
        }
        @finally
        {
        }
    }
    if (keyData) { CFRelease(keyData); }
    return ret;
}

+ (void) delete:(NSString *)service
{
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((CFDictionaryRef)keychainQuery);
}

@end