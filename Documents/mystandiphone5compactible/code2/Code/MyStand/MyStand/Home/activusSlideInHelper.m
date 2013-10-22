//
//  activusSlideInHelper.m
//  MyActivus
//
//  Created by DBG on 08/01/13.
//  Copyright (c) 2013 DBG. All rights reserved.
//

#import "activusSlideInHelper.h"
#import "activusSlideInView.h"

@implementation activusSlideInHelper
- (id)initWithScrollView:(UIScrollView*)scroll andContainerView:(UIView*)view
{
    self = [super init];
    if (self) {
      swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeLeft)];
        swipeRight= [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeRight)];
        swipeLeft.direction=UISwipeGestureRecognizerDirectionLeft;
        swipeRight.direction=UISwipeGestureRecognizerDirectionRight;
        _scrollview=scroll;
        _viewtoinsert=[activusSlideInView getNewViewFromNib];
        
        [_viewtoinsert setFrame:[view frame]];
        [view insertSubview:_viewtoinsert atIndex:0];
        [_viewtoinsert loadDefaultValues];
       _scrollview.contentSize = CGSizeMake(_scrollview.frame.size.width +225,  _scrollview.frame.size.height);
//        [ _scrollview scrollRectToVisible:CGRectMake(0, 0, _scrollview.frame.size.width, _scrollview.frame.size.height) animated:NO];
       [_scrollview addGestureRecognizer:swipeLeft];
        [_scrollview addGestureRecognizer:swipeRight];
        chceck=NO;
		_scrollview.delegate = self;
//        [_viewtoinsert setFont]; //to set custom font
    }
    return self;
}
-(void)slideInWithScrollView
{
//    _scrollview.scrollEnabled=TRUE;
    
    NSLog(@"clicked");
    if(chceck)
    {
        //        NSLog(@" yes clicked");
        //        CGPoint bottomOffset = CGPointMake(0,0);
        //        [_scroll setContentOffset:bottomOffset animated:YES];
        [ _scrollview scrollRectToVisible:CGRectMake((_scrollview.bounds.size.width*0.7), 0,  _scrollview.frame.size.width,  _scrollview.frame.size.height) animated:YES];
      chceck=NO;
    }
    else
    {
        NSLog(@"no clicked");
        CGPoint bottomOffset = CGPointMake(-(_scrollview.bounds.size.width*0.7),0);
        [_scrollview setContentOffset:bottomOffset animated:YES];
        chceck=YES;
    }
//    _scrollview.scrollEnabled=FALSE;
}
-(void)handleSwipeLeft
{
    NSLog(@"swiped left");
    [ _scrollview scrollRectToVisible:CGRectMake((_scrollview.bounds.size.width*0.7), 0,  _scrollview.frame.size.width,  _scrollview.frame.size.height) animated:YES];
    chceck=NO;
}
-(void)handleSwipeRight
{
    NSLog(@"swiped left");
    CGPoint bottomOffset = CGPointMake(-(_scrollview.bounds.size.width*0.7),0);
    [_scrollview setContentOffset:bottomOffset animated:YES];
    chceck=YES;
}
- (void)scrollViewDidScroll:(UIScrollView *)sender {
	//	NSLog(@"did scroll");
//	if(_scrollview.contentOffset.x == 0)
//	{
//		NSLog(@"did scroll from");
//		chceck=NO;
//		//				[_scroll scrollRectToVisible:CGRectMake(0, 0, _scroll.frame.size.width, _scroll.frame.size.height) animated:YES];
//		_scrollview.scrollEnabled = NO;
//	}else if(_scrollview.contentOffset.x <= -225){
//		//				_scroll.scrollEnabled = YES;
//		NSLog(@"did scroll to ");
//		chceck=YES;
//		_scrollview.scrollEnabled = YES;
//	}	
	
}

@end
