//
//  BaseViewControllor.h
//  ImageCrop
//
//  Created by DBG on 21/06/13.
//  Copyright (c) 2013 DBG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewControllor : UIViewController
{
UITapGestureRecognizer *singleTap ;
}
- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect;
@end
