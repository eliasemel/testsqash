//
//  activusSlideInHelper.h
//  MyActivus
//
//  Created by DBG on 08/01/13.
//  Copyright (c) 2013 DBG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "activusSlideInView.h"

@interface activusSlideInHelper : NSObject<UIScrollViewDelegate>
{
    BOOL chceck;
    UISwipeGestureRecognizer *swipeLeft;
    UISwipeGestureRecognizer *swipeRight;
}
@property(strong,nonatomic) UIScrollView *scrollview;
@property(strong,nonatomic) activusSlideInView *viewtoinsert;
-(void)slideInWithScrollView;
- (id)initWithScrollView:(UIScrollView*)scroll andContainerView:(UIView*)view;
@end
