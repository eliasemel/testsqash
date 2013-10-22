//
//  RequestModel.h
//  RequestModels
//
//  Created by dbgmacmini2 dbg on 17/07/12.
//  Copyright (c) 2012 aromalsasidharan@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestModel : NSObject
@property(strong,nonatomic)NSString* postUrl;
@property(strong,nonatomic) NSMutableDictionary* params;
-(id)initWithUrl:(NSString*)aUrl;


-(void)addParam:(NSString*)paramName andValue:(NSString*)paramValue;
-(void)addAccessCode:(NSString*)paramValue;
@end
