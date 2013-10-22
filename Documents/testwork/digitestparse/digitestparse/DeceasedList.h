//
//  DeceasedList.h
//  DIgiTriBute
//
//  Created by DBG on 25/02/13.
//  Copyright (c) 2013 Digital Brand Group Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
@protocol DeceasedListDelegate <NSObject>
@required
-(void)recivedSucess:(NSArray*)arr;
-(void)failure;
@end
@interface DeceasedList : NSObject
@property (strong,nonatomic) id<DeceasedListDelegate> deceasedlistdelegate;
@property (strong,nonatomic) PFQuery* pfquery;
-(void)getAllDeceasedList;
@end
