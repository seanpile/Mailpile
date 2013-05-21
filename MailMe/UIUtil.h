//
//  UIUtil.h
//  MailMe
//
//  Created by Sean Dawson on 2013-05-18.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//
//  This file is released under the MIT License:
//  http://www.opensource.org/licenses/mit-license.php
//

#ifndef _UIUtil_h
#define _UIUtil_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIUtil : NSObject

+ (UIView *) createSpinnerViewWithLabel:(NSString *)label forNav:(UINavigationBar *)nav;

@end

#endif