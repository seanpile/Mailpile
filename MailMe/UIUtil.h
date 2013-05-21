//
//  UIUtil.h
//  MailMe
//
//  Created by Sean Dawson on 2013-05-18.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//

#ifndef _UIUtil_h
#define _UIUtil_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIUtil : NSObject

+ (UIView *) createSpinnerViewWithLabel:(NSString *)label forNav:(UINavigationBar *)nav;

@end

#endif