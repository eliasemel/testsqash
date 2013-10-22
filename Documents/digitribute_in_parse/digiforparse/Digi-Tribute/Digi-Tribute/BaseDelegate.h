//
//  BaseDelegate.h
//  SocialConnect
//
//  Created by dbgmacmini2 dbg on 10/10/12.
//  Copyright (c) 2012 digitalbranddgroup. All rights reserved.
//
#define LINKED_IN_API_KEY @"0bh2coo6trul";
#define LINKED_IN_API_SECERET_KEY @"4zknCoTRoPfqQGOF";

#import <UIKit/UIKit.h>

#import "Facebook.h"
#import "FBSession.h"
#import "OAuthLoginView.h"
#import "OAToken.h"
#import "FBSBJSON.h"
#import "FacebookAppRequest.h"
#import <Twitter/Twitter.h>
#import <Twitter/TWRequest.h>
#import <Accounts/ACAccountStore.h>
#import <Accounts/ACAccountType.h>
@protocol FacebookDelegate <NSObject>

-(void)facebookLoginSucess:(FBSession*)session;
-(void)facebookLoginFailed;

@end

@protocol FacebookRequestDialogDelegate <NSObject>

-(void)facebookDialogClosedWithUrl:(NSDictionary*)params;


@end
@protocol TwitterLoginDelegate <NSObject>

-(void)twitterLoginSuccess;
-(void)twitterAccountNotConfigured;
@end

@interface BaseDelegate : UIResponder<FBDialogDelegate,LinkedInLoginDelegate>
@property(strong,nonatomic) OAToken* accesstoken;
@property(strong,nonatomic)id<FacebookDelegate> fBLoginViewDelegate;
@property(strong,nonatomic)id<FacebookRequestDialogDelegate> facebookRequestDialogDelegate;
@property(strong,nonatomic)id<LinkedInLoginDelegate> linkedInLoginDelegate;
@property(strong,nonatomic) OAuthLoginView* oAuthLoginView;
@property(strong,nonatomic) OAToken* linkedInaccesstoken;
@property(strong,nonatomic) Facebook* facebook;
@property(nonatomic) BOOL isTwitterAccount;

- (void)openFacebookSession;
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error;
-(void)logoutFromFacebook;
- (BOOL)applications: (UIApplication *)application
             openURL: (NSURL *)url
   sourceApplication: (NSString *)sourceApplication
          annotation: (id)annotation;


-(void)linkedInLogin:(UIViewController*)controller
;


-(void)grandAccessToTwitterWithDelegate:(id<TwitterLoginDelegate>)twitterLoginDelegate;

-(void)logoutFromLinkedIn;

-(void)openDialogWith:(FacebookAppRequest*)facebookAppRequest andDelegate:(id<FacebookRequestDialogDelegate>) aFacebookRequestDialogDelegate;
+ (NSDictionary*)parseURLParams:(NSString *)query;
-(BOOL)isLoginedToLinkedIn;
-(BOOL)isLoginedToFacebook;


@end
