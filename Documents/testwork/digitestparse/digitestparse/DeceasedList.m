//
//  DeceasedList.m
//  DIgiTriBute
//
//  Created by DBG on 25/02/13.
//  Copyright (c) 2013 Digital Brand Group Inc. All rights reserved.
//

#import "DeceasedList.h"

@implementation DeceasedList
@synthesize deceasedlistdelegate;
-(id)init
{
    _pfquery=[PFQuery queryWithClassName:@"Deceased"];
    return  self;
}
-(void)getAllDeceasedList
{
    [_pfquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(!error)
        {
            [self.deceasedlistdelegate recivedSucess:objects];
        }
        else
        {
            [self.deceasedlistdelegate failure];
        }
    }];
}
@end
