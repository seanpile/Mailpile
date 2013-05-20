//
//  UIUtil.m
//  MailMe
//
//  Created by Sean Dawson on 2013-05-18.
//  Copyright (c) 2013 Sean Dawson. All rights reserved.
//

#import "UIUtil.h"
#import "MWLogging.h"

@implementation UIUtil

+ (UIView *) createSpinnerViewWithLabel:(NSString *)label forNav:(UINavigationBar *)bar;
{
    UIActivityIndicatorView *activitySpinner = [[UIActivityIndicatorView alloc] init];
    [activitySpinner sizeToFit];
    [activitySpinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhite];
    
    UILabel *activityLabel = [[UILabel alloc] init];
    [activityLabel setText:label];
    [activityLabel setTextColor:[UIColor whiteColor]];
    [activityLabel setFont:[UIFont systemFontOfSize:13.0]];
    [activityLabel setBackgroundColor:[UIColor clearColor]];
    [activityLabel sizeToFit];
    
    // Unable to get widths of bar items for some reason; just estimate the max width as 50% of the frame
    CGFloat maxWidth = bar.frame.size.width * 0.50;
    
    CGFloat padding = 7.5;
    CGSize labelSize = activityLabel.bounds.size;
    CGSize spinnerSize = activitySpinner.bounds.size;
    CGFloat combined = padding + labelSize.width + spinnerSize.width;
    if (combined > maxWidth)
    {
        [activityLabel setMinimumScaleFactor:0.75];
        [activityLabel setAdjustsFontSizeToFitWidth:YES];
        [activityLabel setFrame:CGRectApplyAffineTransform(activityLabel.frame,
                                                           CGAffineTransformMakeScale(maxWidth / combined, 1.0))];
        labelSize = activityLabel.bounds.size;
    }
    
    CGFloat maxHeight = MAX(activityLabel.bounds.size.height, activitySpinner.bounds.size.height);
    [activitySpinner setCenter:CGPointMake(spinnerSize.width / 2.0, maxHeight / 2.0)];
    [activityLabel setCenter:CGPointMake(spinnerSize.width + labelSize.width / 2.0 + padding, maxHeight / 2.0)];
    
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelSize.width + spinnerSize.width + padding, maxHeight)];
    [activityView setBackgroundColor:[UIColor clearColor]];
    [activityView addSubview:activitySpinner];
    [activityView addSubview:activityLabel];
    [activitySpinner startAnimating];
    
    return activityView;
}

@end