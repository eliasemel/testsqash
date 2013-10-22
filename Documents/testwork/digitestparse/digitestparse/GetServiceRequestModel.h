//
//  GetServiceRequestModel.h
//  Digi-Tribute
//
//  Created by DBG on 31/10/12.
//  Copyright (c) 2012 Digital Brand Group Inc. All rights reserved.
//

#import "RequestModel.h"
#import "ConstantsAPI.h"

@interface GetServiceRequestModel : RequestModel
-(void)addActionName:(NSString*)actionname;
-(void)addSecurityToken:(NSString*)sectocken;
@end
