//
//  IntoductionViewController.m
//  MyStand
//
//  Created by DBGMINI1 on 10/8/12.
//  Copyright (c) 2012 Digital Brand Group Inc. All rights reserved.
//

#import "IntoductionViewController.h"
#import "AppDelegate.h"
#import "UIElements.h"
#import "Messages.h"
#import "EnterRefferalCodeViewController.h"
@interface IntoductionViewController ()

@end

@implementation IntoductionViewController
@synthesize scrollViewLogin,pageControlLogin,scrollViewPages,playMission,meetCaptain,creatAccount,token;
@synthesize accountController,facebookUserDetailRequest;
@synthesize user,firstSubView,secondSubView,thirdSubView,baseview;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidAppear:(BOOL)animated
{
	playMission = (PlayMissionViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"playMissionVC"];
	playMission.MissionBreifViewDelegate = self;
	UIView *playMissionView = playMission.view;
	playMissionView.frame = CGRectMake(0, 0, self.view.frame.size.width, (self.view.frame.size.height-self.pageControlLogin.frame.size.height));
	meetCaptain = (MeetCaptainViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"meetCaptainVC"];
	meetCaptain.meetCaptainViewDelegate = self;
	UIView *meetCaptainView = meetCaptain.view;
	meetCaptainView.frame = CGRectMake(320, 0, self.view.frame.size.width, (self.view.frame.size.height-self.pageControlLogin.frame.size.height));
	creatAccount = (CreateAccountViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"createAccountVC"];
	creatAccount.createAccountViewDelegate = self;
	UIView *createAccountView = creatAccount.view;
	createAccountView.frame = CGRectMake(640, 0, self.view.frame.size.width, (self.view.frame.size.height-self.pageControlLogin.frame.size.height));
	[self.firstSubView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.secondSubView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.thirdSubView setTranslatesAutoresizingMaskIntoConstraints:NO];
//	[self.firstSubView addSubview:playMissionView];
//	[self.secondSubView addSubview:meetCaptainView];
//	[self.thirdSubView addSubview:createAccountView];
	[self.scrollViewPages setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.baseview setTranslatesAutoresizingMaskIntoConstraints:NO];

	self.scrollViewPages.contentSize = CGSizeMake(960, 419);
	[self.scrollViewPages setScrollEnabled:YES];
//	[self.scrollViewPages addSubview:baseview];
	[self.scrollViewPages addSubview:playMissionView];
	[self.scrollViewPages addSubview:meetCaptainView];
	[self.scrollViewPages addSubview:createAccountView];
	NSLog(@"content size %f",scrollViewPages.contentSize.width);
	
//	NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(baseview);
	
//	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[scrollViewPages]|" options:0 metrics: 0 viewsDictionary:viewsDictionary]];
//	
//	[self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[scrollViewPages]|" options:0 metrics: 0 viewsDictionary:viewsDictionary]];
	
//	[scrollViewPages addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[baseview]|" options:0 metrics: 0 viewsDictionary:viewsDictionary]];
//	
//	[scrollViewPages addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[baseview]|" options:0 metrics: 0 viewsDictionary:viewsDictionary]];
//	

	
}
- (void)viewDidLoad
{	

    [super viewDidLoad];
    
    if(!self.user)
    {
        self.user =[[MSUser alloc]init];
         self.user.is_facebook_login=NO;
    }
    
    self.accountController=[[AccountController alloc]init];
	[UIElements setPatternColorForView:self.view];
//	self.scrollViewPages = [[ScrollViewPages alloc]initWithScrollView:self.scrollViewLogin andPageController:self.pageControlLogin];
		
    
//	[self.scrollViewPages addView:playMissionView];
//	[self.scrollViewPages addView:meetCaptainView];
//	[self.scrollViewPages addView:createAccountView];
}

-(void)buttonSkipIntroClicked
{
//	[self.scrollViewPages scrollToPage:2];
    self.pageControlLogin.currentPage = 2;
}

-(void)buttonPlayMissionBriefClicked
{
    [[UIElements getUIAlertViewWithDelegate:nil title:@"" andMessage:@"Mission Brief Coming Soon!" cancelTitle:@"OK"]show ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)buttonNextClicked
{
//    [self.scrollViewPages scrollToPage:2];
	self.pageControlLogin.currentPage = 2;
}

-(void)buttonCreateAccountClicked
{
    if([MSAPIController didHandleNetworkAvailability])
    {
	UIViewController *logInVC = (UIViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"referralCodeVC"];
	// Push the new view controller in the usual way:
	[self.navigationController pushViewController:logInVC animated:YES];
    }

}

-(void)buttonLoginWithFacebookClicked
{
    if([MSAPIController didHandleNetworkAvailability])
    {        AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        [delegate logoutFromFacebook];
        delegate.fBLoginViewDelegate = self;
        [delegate openFacebookSession];
    }
}


-(void)buttonAlreadyAccountClicked
{
	LogInViewController *logInVC = (LogInViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"logInVC"];
	logInVC.createAccountViewDelegate = self;
	// Push the new view controller in the usual way:
	[self.navigationController pushViewController:logInVC animated:YES];
    
    
}

#pragma mark Facebook Methods

-(void)facebookLoginSucess:(FBSession *)session
{
    [SVProgressHUD dismiss];
    NSLog(@"%@",session.accessToken);
    if(session.accessToken!=nil)
    {
        self.user.facebook_token=session.accessToken;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];

        self.facebookUserDetailRequest = [[FacebookUserDetailRequest alloc]init];
        self.facebookUserDetailRequest.facebookResutantDelegate = self;
        [self.facebookUserDetailRequest executeRequest];

    }
}

-(void)resultsReceived:(id)result fromRequestType:(NSString *)type
{
    self.user.facebook_id=[result objectForKey:@"id"];
    self.user.facebook_link=[result objectForKey:@"link"];

    [MSAPIController postResource:MS_RESOURCE_FACEBOOK_LOGIN withParams:[NSDictionary dictionaryWithKeysAndObjects:MS_PARAM_FBID,self.user.facebook_id,MS_PARAM_FBTOKEN,self.user.facebook_token,@"device_token",@"put device token here", nil]
                     onCompletion:^(NSDictionary *response)
     {
         [self.accountController saveAccessToken:[[response objectForKey:@"meta"] objectForKey:@"token"]];
         [MSAPIController addHeader:MS_TOKEN withValue:[[response objectForKey:@"meta"] objectForKey:@"token"]];
         [self getUserInfo];
         
     }
                       onFaillure:^(NSError *error)
     {
         if(error.code==404)
         {
             self.user.is_facebook_login=YES;
             EnterRefferalCodeViewController *referalVC = (EnterRefferalCodeViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"referralCodeVC"];
             self.user.first_name=[result objectForKey:@"first_name"];
             self.user.last_name=[result objectForKey:@"last_name"];
             self.user.email=[result objectForKey:@"email"];
             self.user.facebook_profile_pic_url=[[NSString alloc] initWithFormat:@"https://graph.facebook.com/%@/picture",self.user.facebook_id];
             referalVC.user=self.user;
             // Push the new view controller in the usual way:
             [self.navigationController pushViewController:referalVC animated:YES];
             
         }
         else
         {
                   [SVProgressHUD dismiss];
             UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil title:@"Error" andMessage:error.localizedDescription cancelTitle:@"Ok"];
             [alertView show];
         }
     }
                          onError:^(NSError *error)
     {
               [SVProgressHUD dismiss];
         UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil title:@"Error" andMessage:ALERT_TITLE_CONNECTION_FAILURE cancelTitle:@"Ok"];
         [alertView show];
     }];


}

-(void)getUserInfo
{
    [MSAPIController getObjectsAtResource:MS_RESOURCE_ME withParams:nil mapOriginalObject:TRUE onCompletion:^(NSArray *objects) {
        [accountController saveUser:[objects objectAtIndex:0]];
        UIStoryboard *homeStoryboard = [UIStoryboard storyboardWithName:@"HomeStoryboard" bundle:nil];
        
        UITabBarController *homeVC = (UITabBarController *)[homeStoryboard instantiateViewControllerWithIdentifier:@"homeVC"];
        // Push the new view controller in the usual way:
        [self.navigationController pushViewController:homeVC animated:YES];
    }
                               onFaillure:^(NSError *error)
     {
        [SVProgressHUD dismiss];
        UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil title:@"Error" andMessage:error.localizedDescription cancelTitle:@"Ok"];
        [alertView show];
        
    } onError:^(NSError *error) {
        [SVProgressHUD dismiss];
        UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil title:@"Error" andMessage:ALERT_TITLE_CONNECTION_FAILURE cancelTitle:@"Ok"];
        [alertView show];
        
    }];
    
}


-(void)facebookLoginFailed
{
      [SVProgressHUD dismiss];
}
-(void)errorReceived:(NSError *)error
{
    if(error!=nil)
    [SVProgressHUD dismiss];
}
- (void)viewDidUnload {
	//[self setBasescrollview:nil];
	[super viewDidUnload];
}
@end
