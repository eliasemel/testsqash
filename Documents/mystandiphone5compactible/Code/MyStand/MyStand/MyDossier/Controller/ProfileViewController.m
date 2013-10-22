
//
//  ProfileViewController.m
//  StoryBoardSample
//
//  Created by dbgmacmini1 on 9/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ProfileViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CustomProgressBar.h"
#import "AccountDetailsViewController.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "HPGrowingTextView.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "AddPhotosViewController.h"
#import "ATTImageSlider.h"
#import "PhotosViewController.h"
#import "MSUser.h"
#import "UIElements.h"
#import "Messages.h"
#import <RestKit/RestKit.h>
#import "CommentsViewController.h"
#import "VideoView.h"
#import "MSAlbum.h"
#import "MSHeart.h"
#import "MSSupport.h"
#import "MSLevel.h"
#import "FriendsViewController.h"
#import "NSDateAdditions.h"
#import "SupportCommunityViewController.h"
#import "SeperationViewController.h"
#import "AppDelegate.h"
#import "MSAPIControllerConstants.h"
#import "SVProgressHUD.h"
#import "MSAPIController.h"
#import "Constants.h"
#import "ImpactViewController.h"
#define NUM_OF_ITEMS_IN_A_SET  4
#define AUTOLOCATION_OFF @"Off"
#define AUTOLOCATION_CITYTOWN @"City-Town"
#define AUTOLOCATION_EXACT @"Exact"
#define SHARE_LOCATION @"Yes"
enum frndRequest {
    RequestOut = 0,
    RequestIn
};
@interface ProfileViewController ()
{
    UILabel *profile_nameLabel;
    UILabel *profile_levelLabel;
    UILabel *profile_level;
    UIImageView *profile_imageView;
    UIImageView *profile_bagdeImageView;
    UIImageView * profile_scoreboard;
    UIView *containerViewForGrowingTxt;
    UIActionSheet *popUpActionSheet_Picture;
    UIActionSheet *popUpActionSheet_Video;
    NSInteger displayedImageSet;
    NSInteger index;
    NSIndexPath *cellPosition;
    NSMutableArray *urlArray;
    NSMutableArray *albumSet;
    NSMutableArray *selectedUrlArray;
    NSMutableArray *photosListForDetailedView;
    NSMutableArray* tempPostsArray;
    int * frndRequestStatus;
    UIButton *sendButton;
    MSUser *user;
    HPGrowingTextView *textView;
    CustomProgressBar *levelProgressBar;
    BOOL shouldRemoveObjects;
    BOOL isTextBtnSelected;
    BOOL shouldShowUIblock;
    BOOL isForTheFirstTime;
    BOOL didSentRequest;
    BOOL isSentRequest;
}
@end
@implementation ProfileViewController
@synthesize myProfileDetailListView,photoDetailListView;
@synthesize profileBtn,photosBtn,friendsBtn;
@synthesize headerViewForProfile;
@synthesize selectedSetOfUrlsArray;
@synthesize postsArray;
@synthesize shareView, sharetextField;
@synthesize userNameLabel;
@synthesize levelLabel;
@synthesize levelNameLabel;
@synthesize profileImageView;
@synthesize badgeImageView;
@synthesize bottomToolBar;
@synthesize albumListArray;
@synthesize heartInCountLabel;
@synthesize heartOutCountLabel;
@synthesize heartBankCountLabel;
@synthesize supportPriceLabel,notificationButtonViewController,titleView,selectionStatus;
@synthesize postOffset,notificationButtonView;
@synthesize userId;
@synthesize tabView;
@synthesize geoCoder,locationManager,userLocation;
@synthesize statsBtn;
@synthesize settingsController,userSettings;
@synthesize degreeBtn,degreeLabel,myProfileBtn,myDossierLabel,friendsHeartBtn;
@synthesize friendsRequestSentView,friendsRequestView,requestLabel;
@synthesize heartsActionsheet,heartsResourceId;
@synthesize heartsResource,heartsPostIndexPath;
#pragma mark View Life cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        [self.view setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    heartsPostIndexPath=[[NSIndexPath alloc]init];
    [self.profileImageView setImage:[UIImage imageNamed:@"contact_PlaceHolder.png"]];
    postOffset=10;
    levelProgressBar = [[CustomProgressBar alloc]initWithFrame:CGRectMake(150, 67, 76, 16) backgroundImage:[UIImage imageNamed:@"homeProgressBarBackGround.png"] andFillImage:[UIImage imageNamed:@"homeProgressBarFilImage.png"]];
    
    self.postsArray = [[NSMutableArray alloc]initWithCapacity:3];
    urlArray = [[NSMutableArray alloc]initWithCapacity:3];
    
    self.settingsController=[[SettingsController alloc]init];
    self.userSettings=[self.settingsController getLoggedinUserSettings];
	UIStoryboard *homeStoryboard = [UIStoryboard storyboardWithName:@"HomeStoryboard" bundle:nil];
	notificationButtonViewController =[homeStoryboard instantiateViewControllerWithIdentifier:@"notificationButtonVC"];
	notificationButtonViewController.notificationButtonDelegate = self;
	
    if([self.userSettings.share_location isEqualToString:SHARE_LOCATION])
    {
        locationManager.delegate=self;
        //Get user location
        [locationManager startUpdatingLocation];
        [self geoCodeLocation];
    }
    displayedImageIndex = 0;
    
    [self setupGrowingText];
	if ([selectionStatus isEqualToString:@"Photo"]) {
		[self.photosBtn setSelected:YES];
		[self photoBtnSelected];
	}else{
    [self.profileBtn setSelected:YES];
    }
    //shouldRemoveObjects = YES;
    shouldShowUIblock = YES;
    isForTheFirstTime = YES;
    
    [self setUpViews];
    [self setUI];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
	
}
-(void)viewWillAppear:(BOOL)animated
{
	self.userSettings = [self.settingsController getLoggedinUserSettings];
    shouldRemoveObjects = YES;
	
    [self getUserDetailsAndReloadTable:YES];
	[self setUpViews];
	
	[self.headerViewForProfile addSubview:levelProgressBar];
    [self setUI];
	
    if(!isForTheFirstTime)
        [self getDataForMyDossierwithOffset:0 andLimit:postOffset];
    
    didSentRequest = NO;
    shouldShowUIblock = YES;//no
    
    [self changeNotificationCount];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNotificationCount) name:NOTIF_UPDATE_NOTIFICATION_COUNT object:nil];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
#pragma mark Custom Methods
-(void)setFriendIdFromFriendsVC:(NSString *)idValue
{
    self.userId = idValue;
}
- (void)changeNotificationCount
{
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    [self.notificationButtonViewController setNotificationCount:[appDelegate.unreadNotificationCount intValue]];
}
- (void)dealloc
{
    self.myProfileDetailListView.dataSource = nil;
}
-(void)viewDidAppear:(BOOL)animated
{
    NSLog(@"height of header::%f",headerViewForProfile.frame.size.height);
}
#pragma mark - setUI
- (void)setUI
{
    AccountController *aAccountController = [[AccountController alloc] init];
    MSUser *aUser = [aAccountController getLoggedinUser];
    if ([self.userId isEqualToString:aUser.user_id])
    {
        self.statsBtn.hidden = YES;
        [self.friendsRequestView setHidden: YES];
        [self.friendsRequestSentView setHidden: YES];
        [self.bottomToolBar setHidden: NO];
		UIView *notificationView = notificationButtonViewController.view;
		notificationButtonView.frame = [UIElements getButtonPositionRelatedToView:titleView];
		[self.notificationButtonView addSubview:notificationView];
    }
    else
    {
        self.friendsBtn.hidden = YES;
        self.statsBtn.frame = CGRectMake(210, 0, 110, 42);
        self.myProfileBtn.hidden = YES;
        self.friendsHeartBtn.frame = CGRectMake(280, 4, 35, 30);
        self.degreeBtn.frame = CGRectMake(221, 4, 50, 30);
        self.degreeLabel.frame = CGRectMake(225, 7, 30, 21);
        self.myDossierLabel.hidden = YES;
        notificationButtonView.frame = CGRectMake(190, -10, 30, 44);
        if([user.is_friend isEqualToString:@"Yes"])
        {
            [self.bottomToolBar setHidden: NO];
            [self.friendsRequestView setHidden: YES];
            [self.friendsRequestSentView setHidden: YES];
        }
        else if ([user.is_friend isEqualToString:@"No"])
        {
            [self.bottomToolBar setHidden: YES];
            notificationButtonView.frame = CGRectMake(217, -10, 30, 44);
            if(didSentRequest)
            {
                [self.bottomToolBar setHidden: YES];
                didSentRequest = NO;
                [self.friendsRequestView setHidden: YES];
                self.requestLabel.text = @"Request Sent!";
                isSentRequest = YES;
                [self.friendsRequestSentView setHidden: NO];
            }
            else
            {
                [self.bottomToolBar setHidden: YES];
                [self.friendsRequestView setHidden: NO];
                isSentRequest = NO;
                [self.friendsRequestSentView setHidden: YES];
            }
        }
        else if ([user.is_friend isEqualToString:@"RequestIn"])
        {
            [self.friendsRequestView setHidden: YES];
            self.requestLabel.text = @"Request Sent!";
            isSentRequest = YES;
            [self.friendsRequestSentView setHidden: NO];
            [self.bottomToolBar setHidden: YES];
        }
        else if([user.is_friend isEqualToString:@"RequestOut"])
        {
            [self.friendsRequestView setHidden: YES];
            isSentRequest = NO;
            self.requestLabel.text = @"Respond To Request!";
            [self.friendsRequestSentView setHidden: NO];
            [self.bottomToolBar setHidden: YES];
        }
        if([user.degree isEqualToString:@"-1"])
        {
            self.degreeBtn.hidden = YES;
            self.degreeLabel.hidden = YES;
        }
        else
        {
            self.degreeBtn.hidden = NO;
            self.degreeLabel.hidden = NO;
        }
        if([user.degree integerValue] == 1)
            self.degreeLabel.text = [NSString stringWithFormat:@"%@st",user.degree];
        else if([user.degree integerValue] == 2 || [user.degree integerValue] == 4 || [user.degree integerValue] == 5 || [user.degree integerValue] == 6 )
            self.degreeLabel.text = [NSString stringWithFormat:@"%@th",user.degree];
        else if([user.degree integerValue] == 3)
            self.degreeLabel.text = [NSString stringWithFormat:@"%@rd",user.degree];
        else
            self.degreeLabel.text = user.degree;
    }
}
-(void)didClickNotificationButton
{
	UIStoryboard *homeStoryboard = [UIStoryboard storyboardWithName:@"HomeStoryboard" bundle:nil];
	UIViewController *homeNotificationVC = [homeStoryboard instantiateViewControllerWithIdentifier:@"notificationNavController"];
	homeNotificationVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentViewController:homeNotificationVC animated:YES completion:NULL];
}
#pragma mark - Get MyProfile details
-(void)getUserDetailsAndReloadTable:(BOOL)val
{
    if(val == YES)
    {
        if([self.postsArray count] >0 && shouldRemoveObjects)
        {
            [self.postsArray removeAllObjects];
            shouldRemoveObjects = YES;
            [self.myProfileDetailListView reloadData];
        }
	}
    if(shouldShowUIblock)
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [MSAPIController getObjectsAtResource:[NSString stringWithFormat:@"%@%@?",MS_RESOURCE_USER,userId] withParams:[NSDictionary dictionaryWithKeysAndObjects:@"response",@"post", nil] mapOriginalObject:FALSE onCompletion:^(NSArray *objects)
     {
         if (objects.count > 0) {
			 user = [objects objectAtIndex:0];
			 if(val == YES)
			 {
				 [ self.postsArray removeAllObjects];
				 [self.postsArray addObjectsFromArray:user.posts];
				 [self.myProfileDetailListView reloadData];
			 }
			 [self updateHeaderWithDetails:user];
			 [self setUI];
			 isForTheFirstTime = NO;
         }
         [SVProgressHUD dismiss];
     } onFaillure:^(NSError *error) {
         [SVProgressHUD dismiss];
         UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil title:ALERT_TITLE_ERROR andMessage:error.localizedDescription cancelTitle:ALERT_TITLE_OK];
         [alertView show];
     } onError:^(NSError *error) {
         [SVProgressHUD dismiss];
         UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil title:ALERT_TITLE_ERROR andMessage:ALERT_TITLE_CONNECTION_FAILURE cancelTitle:ALERT_TITLE_OK];
         [alertView show];
     }];
}
#pragma mark - update HeaderView
-(void)updateHeaderWithDetails:(MSUser*)userLocal
{
    [self.profileImageView setImageWithURL:[NSURL URLWithString:userLocal.user_photo_thumb]
                          placeholderImage:[UIImage imageNamed:@"contact_PlaceHolder.png"]];
    [self.profileImageView.layer setBorderWidth:3.0];
    [self.profileImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
    self.userNameLabel.text = [NSString stringWithFormat:@"%@ %@",userLocal.first_name,user.last_name ];
    MSLevel *levelObj = userLocal.level;
    self.levelLabel.text=[NSString stringWithFormat:@"Level %@", levelObj.level_number];
    self.levelNameLabel.text =levelObj.level_name;
    [self.badgeImageView setImageWithURL:[NSURL URLWithString:userLocal.level.level_photo_thumb]
                        placeholderImage:[UIImage imageNamed:@"contact_PlaceHolder.png"]];
    MSHeart *heartObj =userLocal.hearts;
    self.heartBankCountLabel.text = heartObj.heart_bank;
    self.heartInCountLabel.text = heartObj.heart_in;;
    self.heartOutCountLabel.text = heartObj.heart_out;
    MSSupport *supportObj = userLocal.support;
    self.supportPriceLabel.text = [NSString stringWithFormat:@"$%@", supportObj.support_price];
    [levelProgressBar setValue:userLocal.level_percentage_completed];
}
#pragma mark - Get MyDossier details
-(void)getDataForMyDossierwithOffset:(int)offset andLimit:(int)limit
{
    [MSAPIController getObjectsAtResource:[NSString stringWithFormat:@"/v2/users/%@/posts?",self.userId] withParams:[NSDictionary dictionaryWithKeysAndObjects:@"offset",[NSString stringWithFormat:@"%i",offset],@"limit",[NSString stringWithFormat:@"%i",limit], nil] mapOriginalObject:FALSE onCompletion:^(NSArray *objects) {
        if(offset == 0)
        {//flush array contents
            [self.postsArray removeAllObjects];
            [self.postsArray addObjectsFromArray:objects];
            [self.myProfileDetailListView reloadData];
		}
        else{
            postOffset=postOffset+10;
            [self.postsArray addObjectsFromArray:objects];
            [self.myProfileDetailListView reloadData];
        }
    } onFaillure:^(NSError *error) {
//        UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil title:ALERT_TITLE_ERROR andMessage:error.localizedDescription cancelTitle:ALERT_TITLE_OK];
//        [alertView show];
    } onError:^(NSError *error) {
        UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil title:ALERT_TITLE_ERROR andMessage:ALERT_TITLE_CONNECTION_FAILURE cancelTitle:ALERT_TITLE_OK];
        [alertView show];
    }];
}
#pragma mark - getAllPhotosForMyDossier
-(void)getAllPhotosForMyDossier
{
    self.albumListArray = [[NSMutableArray alloc]initWithCapacity:3];
	albumSet = [[NSMutableArray alloc]initWithCapacity:3];
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    if([albumListArray count]>0)
        [ self.postsArray removeAllObjects];
    MSAlbum *albumObj =[[MSAlbum alloc]init];
    albumObj.user_id = self.userId;
    [MSAPIController getObject:albumObj
                    withParams:nil
             mapOriginalObject:FALSE
                  onCompletion:^(NSArray *objects)
     {
         [self.albumListArray addObjectsFromArray:objects];
         for(int i =0 ; i<[self.albumListArray count]; i++)
         {
             MSAlbum *obj = [self.albumListArray objectAtIndex:i];
             if(![obj.photos_count isEqualToString:@"0"])
             {
                 [albumSet addObject:obj];
                 //[obj log123];
             }
         }
         [self.photoDetailListView reloadData];
         [SVProgressHUD dismiss];
     } onFaillure:^(NSError *error) {
         [SVProgressHUD dismiss];
         UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil title:ALERT_TITLE_ERROR andMessage:error.localizedDescription cancelTitle:ALERT_TITLE_OK];
         [alertView show];
     } onError:^(NSError *error) {
         [SVProgressHUD dismiss];
         UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil title:ALERT_TITLE_ERROR andMessage:ALERT_TITLE_CONNECTION_FAILURE cancelTitle:ALERT_TITLE_OK];
         [alertView show];
     }];
}
#pragma mark - HPGrowingText
-(void)setupGrowingText
{
    containerViewForGrowingTxt = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-82 , 320, 40)];
	textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(6, 3, 240, 40)];
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
	textView.minNumberOfLines = 1;
	textView.maxNumberOfLines = 6;
	textView.returnKeyType = UIReturnKeyDefault; //just as an example
	textView.font = [UIFont systemFontOfSize:15.0f];
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    containerViewForGrowingTxt.backgroundColor = [UIColor blackColor];
    [self.view addSubview:containerViewForGrowingTxt];
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, containerViewForGrowingTxt.frame.size.width, containerViewForGrowingTxt.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textView.text = @"Write a comment.....";
    textView.textColor = [UIColor lightGrayColor];
    textView.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    textView.delegate = self;
    [containerViewForGrowingTxt addSubview:imageView];
    [containerViewForGrowingTxt addSubview:textView];
    [containerViewForGrowingTxt addSubview:entryImageView];
    sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	sendButton.frame = CGRectMake(containerViewForGrowingTxt.frame.size.width - 67, 6, 62, 28);
    sendButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [sendButton setBackgroundImage:[UIImage imageNamed:@"myDossierBtnSend.png"] forState:UIControlStateNormal];
	[sendButton addTarget:self action:@selector(didEndEditing:) forControlEvents:UIControlEventTouchUpInside];
	[containerViewForGrowingTxt addSubview:sendButton];
    containerViewForGrowingTxt.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [containerViewForGrowingTxt setHidden:YES];
}
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    textView.text = nil;
    [sendButton setEnabled:YES];
    textView.textColor = [UIColor blackColor];
    textView.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
    [self keyboardWillShow:nil];
}
- (BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView;
{
    NSString *rawString = [textView text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] >0)
    {
        [containerViewForGrowingTxt setHidden:NO];
        return NO;
    }
    else
    {
        [containerViewForGrowingTxt setHidden:YES];
        [self keyboardWillHide:nil];
        return YES;
    }
}
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
	CGRect r = containerViewForGrowingTxt.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	containerViewForGrowingTxt.frame = r;
}
-(void)didEndEditing:(id)sender
{
    [containerViewForGrowingTxt setHidden:YES]; // set to yes to hide the growing text
    [textView resignFirstResponder];
	if(isTextBtnSelected)
    {
        NSString *rawString = [textView text];
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
        MSPost *post = [[MSPost alloc]init];
        post.location=self.userLocation;
        if ([trimmed length] >0)
        {
            post.post_type =@"TEXT";
            post.content = textView.text;
            post.user_id = self.userId;
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
            [MSAPIController postObject:post withParams:nil mapOriginalObject:TRUE onCompletion:^(NSArray *objects)
             {
                 NSMutableArray *temp = [[NSMutableArray alloc]initWithCapacity:3];
                 [temp addObjectsFromArray:self.postsArray];
                 [postsArray removeAllObjects];
                 [SVProgressHUD dismiss];
                 [SVProgressHUD showSuccessWithStatus:@"Post Created."];
                 [postsArray addObject:[objects objectAtIndex:0]];
                 [postsArray addObjectsFromArray:temp];
                 [temp removeAllObjects];
                 [self.myProfileDetailListView reloadData];
             }
                             onFaillure:^(NSError *error)
             {
                 [[UIElements getUIAlertViewWithDelegate:nil
                                                   title:@"Error"
                                              andMessage:error.localizedDescription
                                             cancelTitle:@"OK"]show ];
                 [SVProgressHUD dismiss];
             }
                                onError:^(NSError *error)
             {
                 UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil
                                                                           title:ALERT_TITLE_ERROR
                                                                      andMessage:ALERT_TITLE_CONNECTION_FAILURE
                                                                     cancelTitle:ALERT_TITLE_OK];
                 [alertView show];
                 [SVProgressHUD dismiss];
             }];
        }
        [sendButton setEnabled:NO];
    }
    else
    {
        NSString *rawString = [textView text];
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
        MSPost *post = [[MSPost alloc]init];
        post.location=self.userLocation;
		NSURL *embededUrl = [NSURL URLWithString:rawString];
        if ([trimmed length] >0&&embededUrl && embededUrl.scheme && embededUrl.host)
        {
            post.post_type =@"VIDEO";
            post.content = textView.text;
            post.embed_url=textView.text;
            post.user_id = self.userId;
			[MSAPIController postObject:post withParams:nil mapOriginalObject:TRUE onCompletion:^(NSArray *objects)
			 {
				 NSMutableArray *temp = [[NSMutableArray alloc]initWithCapacity:3];
				 [temp addObjectsFromArray:self.postsArray];
				 [postsArray removeAllObjects];
				 
				 [SVProgressHUD dismiss];
				 [SVProgressHUD showSuccessWithStatus:@"Post Created."];
				 [postsArray addObject:[objects objectAtIndex:0]];
				 [postsArray addObjectsFromArray:temp];
				 [temp removeAllObjects];
				 [self.myProfileDetailListView reloadData];
			 }
							 onFaillure:^(NSError *error)
			 {
				 [[UIElements getUIAlertViewWithDelegate:nil
												   title:@"Error"
											  andMessage:error.localizedDescription
											 cancelTitle:@"OK"]show ];
				 [SVProgressHUD dismiss];
			 }
								onError:^(NSError *error)
			 {
				 UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil
																		   title:ALERT_TITLE_ERROR
																	  andMessage:ALERT_TITLE_CONNECTION_FAILURE
																	 cancelTitle:ALERT_TITLE_OK];
				 [alertView show];
				 [SVProgressHUD dismiss];
			 }];
			[sendButton setEnabled:NO];
        }else {
            UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil
                                                                      title:ALERT_TITLE_ERROR
                                                                 andMessage:ALERT_TITLE_INVALID_URL
                                                                cancelTitle:ALERT_TITLE_OK];
            [alertView show];
            [SVProgressHUD dismiss];
        }
    }
    textView.text = nil;
    textView.text = @"Write a comment....";
    textView.textColor = [UIColor lightGrayColor];
    textView.font = [UIFont fontWithName:@"Helvetica" size:13.0f];
    [self keyboardWillHide:nil];
}
#pragma mark Show Hide Keyboard Methods
-(void)keyboardWillShow:(NSNotification *)note
{
	CGRect keyboardBounds = CGRectMake(0, 0, 0, 0);
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         containerViewForGrowingTxt.frame =  CGRectMake(0,205, 320, 40);
                     }
                     completion:^(BOOL finished){
                     }];
}
-(void) keyboardWillHide:(NSNotification *)note
{
    [UIView animateWithDuration:0.25
                          delay:0.0
                        options: UIViewAnimationCurveLinear
                     animations:^{
                         containerViewForGrowingTxt.frame = CGRectMake(0,380, 320, 40);
                     }
                     completion:^(BOOL finished){
                     }];
}
#pragma mark - setting Up views
-(void)setUpViews
{
    if(self.profileBtn.selected)
    {
        [self.myProfileDetailListView setHidden:NO];
        [self.headerViewForProfile setHidden:NO];
        [self.photoDetailListView setHidden:YES];
        [self.profileBtn setSelected:YES];
        [self.photosBtn setSelected: NO];
        [self.friendsBtn setSelected:NO];
    }
    if(self.photosBtn.selected)
    {
        [self.photoDetailListView setHidden:NO];
        [self.headerViewForProfile setHidden:YES];
        [self.myProfileDetailListView setHidden:YES];
        [self.profileBtn setSelected:NO];
        [self.friendsBtn setSelected:NO];
    }
    if(self.friendsBtn.selected)
    {
        [self.photoDetailListView setHidden:YES];
        [self.myProfileDetailListView setHidden:YES];
    }
}
#pragma mark - gesture events
-(void)touchOnImageViewInTable:(UIGestureRecognizer*)recognizer
{
    UIImageView *imageVw = (UIImageView*)recognizer.view;
    UITableViewCell *cell = (UITableViewCell*)imageVw.superview.superview;
    NSIndexPath* pathOfTheCell = [self.myProfileDetailListView indexPathForCell:cell];
    if ([self.postsArray count]>0) {
        MSPost *postObj = [self.postsArray objectAtIndex:pathOfTheCell.row];
        photosListForDetailedView = [[NSMutableArray alloc]initWithCapacity:3];// getting the image set for detailview - album
        for(int i =0;i<[postObj.photos count]; i++)
        {
            [photosListForDetailedView addObject:[[postObj.photos objectAtIndex:i]url_normal]];
        }
        [self touchOnImage:imageVw.image inView:pathOfTheCell.row andImageURL:[photosListForDetailedView objectAtIndex:imageVw.tag -3] andIsFromSharedPhotos:YES ];
    }
}

#pragma mark - addFriend
- (void)addFriend:(NSArray*)arrayOfFriends
{
    [MSAPIController postResource:MS_RESOURCE_ADDFRIEND withParams:[NSDictionary dictionaryWithKeysAndObjects:MS_PARAM_USERIDS,arrayOfFriends,nil] onCompletion:^(NSDictionary *response)
     {
         didSentRequest = YES;
         [self setUI];
     }
                       onFaillure:^(NSError *error)
     {
         [SVProgressHUD dismiss];
     }
                          onError:^(NSError *error)
     {
         [SVProgressHUD dismiss];
     }];
}
#pragma mark - refresh header
-(void)refreshHeaderDetails
{
    [self getUserDetailsAndReloadTable:NO];
}
#pragma mark - button click events
-(IBAction)degreeBtnClicked:(id)sender
{
    UIStoryboard *rippleStoryboard = [UIStoryboard storyboardWithName:@"RippleStoryboard" bundle:nil];
    SeperationViewController *seperationVC = (SeperationViewController*)[rippleStoryboard instantiateViewControllerWithIdentifier:@"seperationVC"];
    seperationVC.mainUser = user;
	seperationVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self.navigationController pushViewController:seperationVC animated:YES];
}
- (IBAction)playVideoButtonClick:(id)sender {
    UIButton *btn = (UIButton*)sender;
    UITableViewCell *cell = (UITableViewCell*)btn.superview.superview;
    
    NSIndexPath* pathOfTheCell = [self.myProfileDetailListView indexPathForCell:cell];
    UIStoryboard *homeStoryBoard = [UIStoryboard storyboardWithName:@"HomeStoryboard" bundle:nil];
    if (self.postsArray.count>0)
    {
        MSPost *postObj = [self.postsArray objectAtIndex:pathOfTheCell.row];
        SupportCommunityViewController *supportVC = (SupportCommunityViewController*)[homeStoryBoard instantiateViewControllerWithIdentifier:@"supportCommunityVC"];
        supportVC.viewTitle=@"Video";
        supportVC.strWebsiteUlr=postObj.embed_url;
        [self.navigationController pushViewController:supportVC animated:YES];
    }
}
-(IBAction)friendRequestBtn:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(IBAction)sendFriendRequest:(id)sender
{
    [self addFriend:[NSArray arrayWithObject:user.user_id]];
}
-(IBAction)shareSomethingBtnClicked:(id)sender
{
    isTextBtnSelected = YES;
    [containerViewForGrowingTxt setHidden:NO];
	[textView becomeFirstResponder];
    if([textView becomeFirstResponder])
    {
        textView.text = nil;
        textView.textColor = [UIColor blackColor];
        textView.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
        [self keyboardWillShow:nil];
    }
}
-(IBAction)picUploadBtnClicked:(id)sender
{
    isTextBtnSelected = NO;
    [containerViewForGrowingTxt setHidden:YES];
    popUpActionSheet_Picture = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo",@"Choose up to 9 photos", nil];
    popUpActionSheet_Picture.actionSheetStyle = UIActionSheetStyleDefault;
    [popUpActionSheet_Picture showInView:self.view];
}
-(IBAction)videoEmbedBtnClicked:(id)sender
{
    isTextBtnSelected = NO;
    popUpActionSheet_Video = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Embed URL", nil];
    popUpActionSheet_Video.actionSheetStyle = UIActionSheetStyleDefault;
    [popUpActionSheet_Video showInView:self.view];
}
-(IBAction)profileBtnClicked:(id)sender
{
    [self getUserDetailsAndReloadTable:YES];
    [self.profileBtn setSelected:YES];
    [self.friendsBtn setSelected:NO];
    [self.photosBtn setSelected: NO];
    [self setUpViews];
}
-(IBAction)photoBtnClicked:(id)sender
{
	[self photoBtnSelected];
//    [containerViewForGrowingTxt setHidden:YES];
//    [self getAllPhotosForMyDossier];
//    [self.bottomToolBar setHidden:YES];
//    [self.photosBtn setSelected:YES];
//    [self.profileBtn setSelected:NO];
//    [self.friendsBtn setSelected:NO];
//    [self setUpViews];
//    [self setUI];
}
-(void)photoBtnSelected
{
	[containerViewForGrowingTxt setHidden:YES];
    [self getAllPhotosForMyDossier];
    [self.bottomToolBar setHidden:YES];
    [self.photosBtn setSelected:YES];
    [self.profileBtn setSelected:NO];
    [self.friendsBtn setSelected:NO];
    [self setUpViews];
    [self setUI];

}
- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(IBAction)heartCountBtnPressed:(id)sender
{
	UIButton *btn = (UIButton*)sender;
	UITableViewCell *cell = (UITableViewCell*)btn.superview.superview;
	self.heartsPostIndexPath = [self.myProfileDetailListView indexPathForCell:cell];
	MSPost *postObj = [self.postsArray objectAtIndex: self.heartsPostIndexPath.row];
	self.heartsResource = MS_RESOURCE_HEARTS_POST;
	self.heartsResourceId=postObj.post_id;
	self.heartsActionsheet = [[UIActionSheet alloc] initWithTitle:@"How many hearts would you like to send?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Kind Thought - 1 heart",@"Big Respect - 5 hearts",@"World Changer - 10 hearts", nil];
	self.heartsActionsheet.actionSheetStyle = UIActionSheetStyleDefault;
	[self.heartsActionsheet showInView:self.view];
}
- (IBAction)profileHeartButtonClicked:(id)sender {
    self.heartsResource=MS_RESOURCE_HEARTS_USER;
    self.heartsResourceId=self.userId;
	self.heartsActionsheet = [[UIActionSheet alloc] initWithTitle:@"How many hearts would you like to send?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Kind Thought - 1 heart",@"Big Respect - 5 hearts",@"World Changer - 10 hearts", nil];
	self.heartsActionsheet.actionSheetStyle = UIActionSheetStyleDefault;
	[self.heartsActionsheet showInView:self.view];
}
-(IBAction)commentCountBtnPressed:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    UITableViewCell *cell = (UITableViewCell*)btn.superview.superview;
    cellPosition = [self.myProfileDetailListView indexPathForCell:cell];
    CommentsViewController *commentsVC = (CommentsViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"CommentsVC"];
	MSPost *postObj = [self.postsArray objectAtIndex:cellPosition.row];
    commentsVC.postHeartCount = postObj.hearts_people_count;
    commentsVC.postId = postObj.post_id;
    commentsVC.userId = self.userId;
    commentsVC.postedUserId = postObj.posted_user_id;
    [self presentViewController:commentsVC animated:YES completion:nil];
}
-(IBAction)myProfileBtnClicked
{
    AccountDetailsViewController *accountVC =(AccountDetailsViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"accountVC"];
    [accountVC setRefreshDelegate:self];
    [self.navigationController pushViewController:accountVC animated:YES];
}
-(IBAction)profileImageBtnPressed:(id)sender
{
    AccountController *accountController = [[AccountController alloc] init];
    MSUser *aUser = [accountController getLoggedinUser];
    if ([self.userId isEqualToString:aUser.user_id])
    {
		AccountDetailsViewController *accountVC =(AccountDetailsViewController*)[self.storyboard instantiateViewControllerWithIdentifier:@"accountVC"];
		[accountVC setRefreshDelegate:self];
		[self.navigationController pushViewController:accountVC animated:YES];
    }
}
-(IBAction)statsBtnClicked:(id)sender
{
	if([MSAPIController didHandleNetworkAvailability])
    {
		UIStoryboard *impactStoryboard = [UIStoryboard storyboardWithName:@"ImpactStoryboard" bundle:nil];
		ImpactViewController *impactVC = (ImpactViewController *)[impactStoryboard instantiateViewControllerWithIdentifier:@"impactVC"];
		impactVC.transitionStyle = @"model";
		impactVC.userForImpact= userId;
		impactVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		[self presentViewController:impactVC animated:YES completion:NULL];

		
	}
}
-(IBAction)friendsBtnClicked:(id)sender
{
    UIStoryboard *friendStoryboard = [UIStoryboard storyboardWithName:@"FriendStoryboard" bundle:nil];
	UIViewController *friendVC = [friendStoryboard instantiateInitialViewController];
	friendVC.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	[self presentViewController:friendVC animated:YES completion:NULL];
}
#pragma mark - getDynamicHeight
- (float)getHeightFortheDynamicLabel:(NSString *)stringForTheLabel
{
    CGSize maxSize = CGSizeMake(215, 2000.0);
    CGSize newSize = [stringForTheLabel sizeWithFont:[UIFont systemFontOfSize:14.0]
                                   constrainedToSize:maxSize];
    return newSize.height;
}

-(CGFloat)getHeightforIndexPath:(NSIndexPath *)indexPath
{
    MSPost *post=(MSPost *)[self.postsArray objectAtIndex:indexPath.row];
    CGFloat ht;
    float height = [self getHeightFortheDynamicLabel:post.content];
    ht = height;
    return ht;
}
#pragma mark - tableview delegates and datasource
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 10.0)
    {
        [self getDataForMyDossierwithOffset:postOffset andLimit:10];
    }
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return self.headerViewForProfile;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSLog(@"header view height::%f",self.headerViewForProfile.frame.size.height);
    return 0.01;
//    return self.headerViewForProfile.frame.size.height;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView ==  self.myProfileDetailListView)
    {
        return [self.postsArray count];
    }
    else
    {
		return [albumSet count];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView ==  self.myProfileDetailListView)
    {
        MSPost *post=(MSPost *)[self.postsArray objectAtIndex:indexPath.row];
        if([post.post_type isEqualToString:@"TEXT"])
        {
            return [self getHeightforIndexPath:indexPath]+65;
        }
        else if([post.post_type isEqualToString:@"VIDEO"])
        {
            return 132;
        }
        else
        {
            return 162;
        }
        if (indexPath.row == [self.postsArray count])
        {
            return 40;
        }
    }
    else
        return 118;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AccountController *aAccountController = [[AccountController alloc] init];
    MSUser *aUser = [aAccountController getLoggedinUser];
    if(tableView == self.myProfileDetailListView)
    {
        if ([self.postsArray count]>0)
        {
            MSPost *postObject = [self.postsArray objectAtIndex:indexPath.row];
            if([postObject.post_type isEqualToString:@"TEXT"])
            {
                UITableViewCell *tableCell1 = [tableView
                                               dequeueReusableCellWithIdentifier:@"UpdatesCell"];
                UILabel * nameLabel = (UILabel*)[tableCell1 viewWithTag:1];
                UILabel * content = (UILabel*)[tableCell1 viewWithTag:2];
                UILabel *heartCountLabel = (UILabel*)[tableCell1 viewWithTag:3];
                UILabel *commentCountLabel =(UILabel*)[tableCell1 viewWithTag:4];
                UILabel *placeTimeLabel = (UILabel*)[tableCell1 viewWithTag:5];
                UIImageView *userImageView = (UIImageView*)[tableCell1 viewWithTag:6];
                UIButton *heartButton = (UIButton*)[tableCell1 viewWithTag:7];
                UIButton *commentButton = (UIButton*)[tableCell1 viewWithTag:8];
                [userImageView.layer setBorderWidth:3.0];
                [userImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
                nameLabel.text = postObject.posted_user_fullname;
                content.frame = CGRectMake(82, 32, 202,[self getHeightFortheDynamicLabel:postObject.content]);
                content.text = postObject.content;
                CGFloat offset = content.frame.origin.y + content.frame.size.height;
                heartButton.frame = CGRectMake(79,offset+2 ,23,21);
                commentButton.frame = CGRectMake(123,offset+2 , 39, 21);
                heartCountLabel.frame =CGRectMake(107, offset+2, 23, 21);
                commentCountLabel.frame = CGRectMake(132,offset+2, 28, 21);
                placeTimeLabel.frame = CGRectMake(173, offset-2, 136, 28);
                heartCountLabel.text = postObject.heart_in;
                commentCountLabel.text = postObject.comment_count;
                if ([postObject.posted_user_id isEqualToString:aUser.user_id])
                    [heartButton setEnabled:NO];
                else
                    [heartButton setEnabled:YES];
                if([postObject.location length]>0)
                    placeTimeLabel.text =[NSString stringWithFormat:@"%@ near %@",[[postObject.created_at toLocalTime]formatRelativeTime],postObject.location];
                else
                    placeTimeLabel.text=[[postObject.created_at toLocalTime]formatRelativeTime];
                [userImageView setImageWithURL:[NSURL URLWithString:postObject.posted_user_photo] placeholderImage:[UIImage imageNamed:@"contact_PlaceHolder.png"]
                 ];
				return tableCell1;
            }
            else if([postObject.post_type isEqualToString:@"PHOTO"])
            {
                int arrayCount = [postObject.photos count];
                UITableViewCell *tableCell2 = [tableView
                                               dequeueReusableCellWithIdentifier:@"SharedPicturesCell"];
                UIImageView * userImageView = (UIImageView*)[tableCell2 viewWithTag:1];
                UILabel * contentLabel = (UILabel*)[tableCell2 viewWithTag:2];
                UIImageView * imageView1 = (UIImageView*)[tableCell2 viewWithTag:3];
                UIImageView * imageView2 = (UIImageView*)[tableCell2 viewWithTag:4];
                UIImageView * imageView3 = (UIImageView*)[tableCell2 viewWithTag:5];
                UIButton *heartButton = (UIButton*)[tableCell2 viewWithTag:6];
                UILabel  * heartCountLabel = (UILabel*)[tableCell2 viewWithTag:7];
                UILabel * commentCountLabel = (UILabel*)[tableCell2 viewWithTag:9];
                UILabel * placeTimeLabel = (UILabel*)[tableCell2 viewWithTag:10];
                placeTimeLabel.frame = CGRectMake(173,126 , 136, 28);
                if(arrayCount==1)
                    [contentLabel setText:[NSString stringWithFormat:@"%@ shared %d picture",postObject.posted_user_fullname,arrayCount]];
                else
                    [contentLabel setText:[NSString stringWithFormat:@"%@ shared %d pictures",postObject.posted_user_fullname,arrayCount]];
                heartCountLabel.text = postObject.heart_in;
                commentCountLabel.text = postObject.comment_count;
                if ([postObject.posted_user_id isEqualToString:aUser.user_id])
                    [heartButton setEnabled:NO];
                else
                    [heartButton setEnabled:YES];
                
                if([postObject.location length]>0)
                    placeTimeLabel.text =[NSString stringWithFormat:@"%@ near %@",[[postObject.created_at toLocalTime]formatRelativeTime],postObject.location];
                else
                    placeTimeLabel.text=[[postObject.created_at toLocalTime]formatRelativeTime];
                [userImageView setImageWithURL:[NSURL URLWithString:postObject.posted_user_photo] placeholderImage:[UIImage imageNamed:@"contact_PlaceHolder.png"]];
                [userImageView.layer setBorderWidth:3.0];
                [userImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
                NSMutableArray *photosList = [[NSMutableArray alloc]initWithCapacity:3];
                for(int i =0;i<[postObject.photos count]; i++)
                {
                    [photosList addObject:[postObject.photos objectAtIndex:i]];
                }
                if([photosList count]!=0)
                {
                    if([photosList count]==1)
                    {
                        if (imageView1.hidden)
                            [imageView1 setHidden:NO];
                        [imageView1 setUserInteractionEnabled:YES];
                        [imageView1 setImageWithURL:[NSURL URLWithString:[[photosList objectAtIndex:0]url_thumb]] placeholderImage:[UIImage imageNamed:@"defaultPhoto.png"]];
                        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchOnImageViewInTable:)];
                        [imageView1 addGestureRecognizer:tap];
                        [imageView2 setHidden:YES];
                        [imageView3 setHidden:YES];
                        return tableCell2;
                    }
                    else if ([photosList count]==2)
                    {
                        if (imageView1.hidden)
                            [imageView1 setHidden:NO];
                        [imageView1 setUserInteractionEnabled:YES];
                        if (imageView2.hidden)
                            [imageView2 setHidden:NO];
                        [imageView2 setUserInteractionEnabled:YES];
                        [imageView1 setImageWithURL:[NSURL URLWithString:[[photosList objectAtIndex:0]url_thumb]] placeholderImage:[UIImage imageNamed:@"defaultPhoto.png"]];
                        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchOnImageViewInTable:)];
                        [imageView1 addGestureRecognizer:tap1];
                        [imageView2 setImageWithURL:[NSURL URLWithString:[[photosList objectAtIndex:1]url_thumb]] placeholderImage:[UIImage imageNamed:@"defaultPhoto.png"]];
                        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchOnImageViewInTable:)];
                        [imageView2 addGestureRecognizer:tap2];
                        [imageView3 setHidden:YES];
                        return tableCell2;
                    }
                    else if(([photosList count]==3)||([photosList count]>3))
                    {
                        if (imageView1.hidden)
                            [imageView1 setHidden:NO];
                        [imageView1 setUserInteractionEnabled:YES];
                        if (imageView2.hidden)
                            [imageView2 setHidden:NO];
                        [imageView2 setUserInteractionEnabled:YES];
                        if (imageView3.hidden)
                            [imageView3 setHidden:NO];
                        [imageView3 setUserInteractionEnabled:YES];
                        [imageView1 setImageWithURL:[NSURL URLWithString:[[photosList objectAtIndex:0]url_thumb]] placeholderImage:[UIImage imageNamed:@"defaultPhoto.png"]];
                        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchOnImageViewInTable:)];
                        [imageView1 addGestureRecognizer:tap1];
                        [imageView2 setImageWithURL:[NSURL URLWithString:[[photosList objectAtIndex:1]url_thumb]] placeholderImage:[UIImage imageNamed:@"defaultPhoto.png"]];
                        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchOnImageViewInTable:)];
                        [imageView2 addGestureRecognizer:tap2];
                        [imageView3 setImageWithURL:[NSURL URLWithString:[[photosList objectAtIndex:2]url_thumb]] placeholderImage:[UIImage imageNamed:@"defaultPhoto.png"]];
                        UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(touchOnImageViewInTable:)];
                        [imageView3 addGestureRecognizer:tap3];
                        return tableCell2;
                    }
                }
                return tableCell2;
            }
            else
            {
                UITableViewCell *tableCell3 = [tableView
                                               dequeueReusableCellWithIdentifier:@"SharedVideoCell"];
                UIImageView * userImageView = (UIImageView*)[tableCell3 viewWithTag:1];
                UIButton * heartButton = (UIButton*)[tableCell3 viewWithTag:3];
                UILabel  * heartCountLabel = (UILabel*)[tableCell3 viewWithTag:4];
                UILabel * commentCountLabel = (UILabel*)[tableCell3 viewWithTag:6];
                UILabel * placeTimeLabel = (UILabel*)[tableCell3 viewWithTag:7];
                heartCountLabel.text = postObject.heart_in;
                commentCountLabel.text = postObject.comment_count;
                placeTimeLabel.frame = CGRectMake(173,94, 136, 28);
                if ([postObject.posted_user_id isEqualToString:aUser.user_id])
                    [heartButton setEnabled:NO];
                else
                    [heartButton setEnabled:YES];
                if([postObject.location length]>0)
                    placeTimeLabel.text =[NSString stringWithFormat:@"%@ near %@",[[postObject.created_at toLocalTime]formatRelativeTime],postObject.location];
                else
                    placeTimeLabel.text=[[postObject.created_at toLocalTime]formatRelativeTime];
                [userImageView.layer setBorderWidth:3.0];
                [userImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
                UILabel * contentLabel = (UILabel*)[tableCell3 viewWithTag:2];
                [contentLabel setText:[NSString stringWithFormat:@"%@ shared a video",postObject.posted_user_fullname]];
                [userImageView setImageWithURL:[NSURL URLWithString:postObject.posted_user_photo] placeholderImage:[UIImage imageNamed:@"defaultVideo.png"]];
				return tableCell3;
            }
			
        }
        else
        {
            UITableViewCell *tableCell1 = [tableView dequeueReusableCellWithIdentifier:@"UpdatesCell"];
            return tableCell1;
        }
    }
    else
    {
        MSAlbum *albumObject = [albumSet objectAtIndex:indexPath.row];
        [urlArray removeAllObjects];
        [urlArray addObjectsFromArray:albumObject.photos];
        UITableViewCell *tableCell = [tableView
                                      dequeueReusableCellWithIdentifier:@"PhotoDetailCell"];
        UILabel *picSectionLabels = (UILabel *)[tableCell viewWithTag:1];
        if([albumObject.album_name isEqualToString:@"PROFILEPHOTOS"])
        {
            picSectionLabels.text = @"Profile Photos";
        }
        else if([albumObject.album_name isEqualToString:@"WALLPHOTOS"])
        {
            picSectionLabels.text = @"Wall Photos";
        }
        else if([albumObject.album_name isEqualToString:@"ENVIRONMENTACTIONS"])
        {
            picSectionLabels.text = @"Environmental Actions";
        }
        else if([albumObject.album_name isEqualToString:@"COMMUNITYACTIONS"])
        {
            picSectionLabels.text = @"Community Actions";
        }
        else if([albumObject.album_name isEqualToString:@"SELFACTIONS"])
        {
            picSectionLabels.text = @"Self Actions";
        }
        else
        {
            picSectionLabels.text = @"Others";
        }
        ATTImageSlider *imageSlider=[ATTImageSlider alloc];
        imageSlider.tag = indexPath.row;
        imageSlider.delegate1 = self;
        imageSlider = [imageSlider initWithFrame:CGRectMake(0, 0, tableCell.frame.size.width, tableCell.frame.size.height)];
        [tableCell.contentView addSubview:imageSlider];
        return tableCell;
    }
}

#pragma mark - UIActionSheet Delegates
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(actionSheet == popUpActionSheet_Picture)
    {
        if (buttonIndex == 0)
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
            {
                UIImagePickerController *imagePicker1 =[[UIImagePickerController alloc] init];
                imagePicker1.delegate = self;
                imagePicker1.mediaTypes = [NSArray arrayWithObjects:(NSString *) kUTTypeImage,nil];
                imagePicker1.allowsEditing = YES;
                imagePicker1.sourceType = UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePicker1 animated:YES completion:nil];
            }
        }
        else if (buttonIndex == 1)
        {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum])
            {
                AddPhotosViewController *addPicVC = [[AddPhotosViewController alloc]initWithNibName:@"AddPhotosViewController" bundle:nil];
                [addPicVC setDelegate:self];
                [self presentViewController:addPicVC animated:YES completion:nil];
            }
        }
    }
    else if(actionSheet == popUpActionSheet_Video)
    {
        if (buttonIndex == 0)
        {
            [containerViewForGrowingTxt setHidden:NO];
            [textView becomeFirstResponder];
            if([textView becomeFirstResponder])
            {
                textView.text = nil;
                textView.textColor = [UIColor blackColor];
                textView.font = [UIFont fontWithName:@"Helvetica" size:15.0f];
                [self keyboardWillShow:nil];
            }
        }
    }
    else if (actionSheet==heartsActionsheet)
    {
        if (buttonIndex == 0)
        {
            [self giveHeartstoResource:self.heartsResource withResourceId:self.heartsResourceId andHeartCount:@"1"];
        }
        else if (buttonIndex==1)
        {
            [self giveHeartstoResource:self.heartsResource withResourceId:self.heartsResourceId  andHeartCount:@"5"];
        }
        else if (buttonIndex==2)
        {
			[self giveHeartstoResource:self.heartsResource withResourceId:self.heartsResourceId  andHeartCount:@"10"];
        }
    }
}
#pragma mark GiveHearts
-(void)giveHeartstoResource:(NSString*)resource withResourceId:(NSString*)resourceId andHeartCount:(NSString*)count
{
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [MSAPIController postResource:[NSString stringWithFormat:@"%@/%@/hearts",resource,resourceId] withParams:[NSDictionary dictionaryWithKeysAndObjects:@"count",count, nil] onCompletion:^(NSDictionary *response) {
        if(self.heartsResource==MS_RESOURCE_HEARTS_POST)
        {
            MSPost *postObject = [self.postsArray objectAtIndex:self.heartsPostIndexPath.row];
            postObject.heart_in =[[response objectForKey:@"heart"] objectForKey:@"heart_count"];
            [self.postsArray replaceObjectAtIndex:self.heartsPostIndexPath.row withObject:postObject];
            [self.myProfileDetailListView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.heartsPostIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        else if(self.heartsResource==MS_RESOURCE_HEARTS_USER)
        {
            self.heartInCountLabel.text=[[response objectForKey:@"heart"] objectForKey:@"heart_count"];
        }
        [SVProgressHUD dismiss];
		[SVProgressHUD showSuccessWithStatus:@"Success"];
        [self getUserDetailsAndReloadTable:NO];
    }
     
    onFaillure:^(NSError *error) {
        UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil
                                                                  title:ALERT_TITLE_ERROR
                                                             andMessage:error.localizedDescription
                                                            cancelTitle:ALERT_TITLE_OK];
        [alertView show];
        [SVProgressHUD dismiss];
    } onError:^(NSError *error) {
        UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil
                                                                  title:ALERT_TITLE_ERROR
                                                             andMessage:error.localizedDescription
                                                            cancelTitle:ALERT_TITLE_OK];
        [alertView show];
        [SVProgressHUD dismiss];
    }];
}
#pragma mark - postImageWithImageArray
-(void)postImageWithImageArray:(NSMutableArray*)imageSetArray
{
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    RKParams* params = [RKParams params] ;
    [params setValue:@"PHOTO"  forParam:@"post_type"];
    MSPost *postObj =[[MSPost alloc]init];
    postObj.location=self.userLocation;
    postObj.user_id = self.userId;
    for(int i =0; i<[imageSetArray count]; i++)
    {
        NSData* imageData = UIImagePNGRepresentation([imageSetArray objectAtIndex:i]);
        [params setData:imageData MIMEType:@"image/png" forParam:@"photos[]"];
    }
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
    [MSAPIController postObject:postObj withParams:params mapOriginalObject:TRUE onCompletion:^(NSArray *objects)
     {
         NSMutableArray *temp = [[NSMutableArray alloc]initWithCapacity:3];
         [temp addObjectsFromArray:self.postsArray];
         [postsArray removeAllObjects];
         [postsArray addObject:[objects objectAtIndex:0]];
         [postsArray addObjectsFromArray:temp];
         [temp removeAllObjects];
         [self.myProfileDetailListView reloadData];
         [SVProgressHUD dismiss];
		 
     }
                     onFaillure:^(NSError *error)
     {
         [SVProgressHUD dismiss];
         [appDelegate showAlertWithMessage:error.localizedDescription];
     }
                        onError:^(NSError *error)
     {
         [SVProgressHUD dismiss];
         [appDelegate showAlertWithMessage:error.localizedDescription];
		 
     }];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - ATTImageSliderDelegate
-(NSInteger)totalNumberOfSetsForImageSlider:(ATTImageSlider*)imageSliderObj
{
    NSInteger totalNumOfSets = [urlArray count]/NUM_OF_ITEMS_IN_A_SET;
	if ([urlArray count]< NUM_OF_ITEMS_IN_A_SET)
    {
        return 1;
    }
    else{
		if ([urlArray count]% NUM_OF_ITEMS_IN_A_SET)
		{
			totalNumOfSets = totalNumOfSets + 1;
		}
    }
    return totalNumOfSets;
}
-(NSInteger)numberOfImagesInASetForImageSlider:(ATTImageSlider*)imageSliderObj
{
    return NUM_OF_ITEMS_IN_A_SET;
}

-(void) imageSlider:(ATTImageSlider *)imageSliderObj ImageSelectedAtIndex:(NSInteger)index
{
}
-(void) imageSlider:(ATTImageSlider*)imageSliderObj DisplayBlankDefaultImageAtIndex:(NSInteger)index
{
    
}
-(void) imageSlider:(ATTImageSlider*)imageSliderObj BlankImageSelectedAtIndex:(NSInteger)index
{
    
}
-(NSArray*) imageSlider:(ATTImageSlider *)imageSliderObj getImagesForSet:(NSInteger)setIndex
{
    NSInteger baseIndex = setIndex * NUM_OF_ITEMS_IN_A_SET;
	selectedUrlArray = [NSMutableArray arrayWithCapacity:3];
    for (int i=0; i < NUM_OF_ITEMS_IN_A_SET ; i++)
    {
        NSInteger nextIndex = (baseIndex + i);
        NSInteger totalCount;
        MSAlbum *albumObject = [albumSet objectAtIndex:imageSliderObj.tag];
        totalCount = [albumObject.photos count];
        NSMutableArray * array1 = [[NSMutableArray alloc]initWithCapacity:3];
        for (int i = 0; i< totalCount; i++)
        {
            MSPhoto *photoObj = [albumObject.photos objectAtIndex:i];
            [array1 addObject:photoObj.url_thumb];
        }
        urlArray = array1;
        if (nextIndex >= totalCount)
        {
            break;
        }
        else
        {
            [selectedUrlArray addObject:[urlArray objectAtIndex:nextIndex]];
        }
    }
    if ([selectedUrlArray count]>0)
    {
        displayedImageSet = setIndex;
    }
    return selectedUrlArray;
}
-(void)touchOnImage:(UIImage*)img inView:(NSInteger)tagVal andImageURL:(NSURL *)urlStr andIsFromSharedPhotos:(BOOL)val
{
    PhotosViewController *photosVc = [[PhotosViewController alloc]initWithNibName:@"PhotosViewController" bundle:nil];
    photosVc.userId = self.userId;
    if(val)
    {
        MSPost *postObject = [postsArray objectAtIndex:tagVal];
        [photosVc.picsObjectArray addObjectsFromArray:postObject.photos];
        [photosVc.picsUrlArray addObjectsFromArray:photosListForDetailedView];
        NSUInteger indexOfTheObject = [photosListForDetailedView indexOfObject: urlStr];
        photosVc.picUrlAtIndex = indexOfTheObject;
        photosVc.postedUserId = postObject.posted_user_id;
        photosVc.isFromPosts = YES;
    }
    else
    {
        switch (tagVal)
        {
            case 0:
            {
                MSAlbum *albumObject = [albumSet objectAtIndex:tagVal];
                [urlArray removeAllObjects];
                [self getDetailsForPhotoVCForObject:photosVc fromAlbumObject:albumObject withPicOfUrl:urlStr];
            }
                break;
            case 1:
            {
                MSAlbum *albumObject = [albumSet objectAtIndex:tagVal];
                [urlArray removeAllObjects];
                [self getDetailsForPhotoVCForObject:photosVc fromAlbumObject:albumObject withPicOfUrl:urlStr];
            }
                break;
            case 2:
            {
                MSAlbum *albumObject = [albumSet objectAtIndex:tagVal];
                [urlArray removeAllObjects];
                [self getDetailsForPhotoVCForObject:photosVc fromAlbumObject:albumObject withPicOfUrl:urlStr];
            }
                break;
            case 3:
            {
                MSAlbum *albumObject = [albumSet objectAtIndex:tagVal];
                [urlArray removeAllObjects];
                [self getDetailsForPhotoVCForObject:photosVc fromAlbumObject:albumObject withPicOfUrl:urlStr];
            }
                break;
            case 4:
            {
                MSAlbum *albumObject = [albumSet objectAtIndex:tagVal];
                [urlArray removeAllObjects];
                [self getDetailsForPhotoVCForObject:photosVc fromAlbumObject:albumObject withPicOfUrl:urlStr];
            }
                break;
            case 5:
            {
                MSAlbum *albumObject = [albumSet objectAtIndex:tagVal];
                [urlArray removeAllObjects];
				[self getDetailsForPhotoVCForObject:photosVc fromAlbumObject:albumObject withPicOfUrl:urlStr];
            }
                break;
            default:
                break;
        }
        
    }
    [photosVc setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [self presentViewController:photosVc animated:YES completion:nil];
}
#pragma mark -
-(void)getDetailsForPhotoVCForObject:(PhotosViewController*)photosVc fromAlbumObject:(MSAlbum*)albumObject withPicOfUrl:(NSURL*)urlStr
{
    [photosVc.picsObjectArray addObjectsFromArray:albumObject.photos];//array of elements of type MSPhotos
    for (int i = 0; i< [photosVc.picsObjectArray count]; i++)
    {
        MSPhoto *photoObj = [albumObject.photos objectAtIndex:i];
        [urlArray addObject:photoObj.url_thumb];
    }
    [photosVc.picsUrlArray addObjectsFromArray:urlArray];
    NSUInteger indexOfTheObject = [urlArray indexOfObject:urlStr];
    photosVc.picUrlAtIndex = indexOfTheObject;
    photosVc.isFromPosts = NO;
}
#pragma mark - ImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
		UIImage *newImage = [UIElements scaleAndRotateImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
        shouldRemoveObjects = NO;
        RKParams *params = [RKParams params];
        [params setValue:@"PHOTO"  forParam:@"post_type"];
        NSData* imageData = UIImagePNGRepresentation(newImage);
        [params setData:imageData MIMEType:@"image/png" forParam:@"photos[]"];
        MSPost *post = [[MSPost alloc]init];
        post.location=self.userLocation;
        post.post_type =@"PHOTO";
        post.user_id = self.userId;
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
        [MSAPIController postObject:post withParams:params mapOriginalObject:TRUE onCompletion:^(NSArray *objects)
         {
             NSMutableArray *temp = [[NSMutableArray alloc]initWithCapacity:3];
             [temp addObjectsFromArray:self.postsArray];
             [self.postsArray removeAllObjects];
             [SVProgressHUD dismiss];
             [SVProgressHUD showSuccessWithStatus:@"Post Created."];
             [self.postsArray addObject:[objects objectAtIndex:0]];
             [self.postsArray addObjectsFromArray:temp];
             [temp removeAllObjects];
             [self.myProfileDetailListView reloadData];
             [SVProgressHUD dismiss];
             [self dismissViewControllerAnimated:YES completion:nil];
         } onFaillure:^(NSError *error) {
             [SVProgressHUD dismiss];
             UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil title:ALERT_TITLE_ERROR andMessage:error.localizedDescription cancelTitle:ALERT_TITLE_OK];
             [alertView show];
         } onError:^(NSError *error) {
             [SVProgressHUD dismiss];
             UIAlertView *alertView = [UIElements getUIAlertViewWithDelegate:nil title:ALERT_TITLE_ERROR andMessage:ALERT_TITLE_CONNECTION_FAILURE cancelTitle:ALERT_TITLE_OK];
             [alertView show];
         }];
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker1
{
    [self dismissViewControllerAnimated:YES completion:nil];
    picker1 = nil;
}
#pragma mark - Location
- (void)geoCodeLocation
{    //Geocoding Block
    [self.geoCoder reverseGeocodeLocation: locationManager.location completionHandler:
     ^(NSArray *placemarks, NSError *error) {
         //Get nearby address
         CLPlacemark *placemark = [placemarks objectAtIndex:0];
         NSString *locatedAt= @"";
         if([self.userSettings.auto_location isEqualToString:AUTOLOCATION_EXACT])
         {
             locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
         }
         else if([self.userSettings.auto_location isEqualToString:AUTOLOCATION_CITYTOWN])
         {
             NSMutableString  *cityTown =[[NSMutableString alloc]init];
             NSString *city=[placemark.addressDictionary objectForKey:@"City"];
             NSString *subAdministrativeArea=[placemark.addressDictionary objectForKey:@"SubAdministrativeArea"];
			 NSString *state=[placemark.addressDictionary objectForKey:@"State"];
             NSString *countryCode=[placemark.addressDictionary objectForKey:@"CountryCode"];
			 if(city!=nil)
				 [cityTown appendFormat:@"%@, ",city] ;
             if(subAdministrativeArea!=nil)
                 [cityTown appendFormat:@"%@, ",subAdministrativeArea] ;
             if(state!=nil)
                 [cityTown appendFormat:@"%@, ",state] ;
             if(countryCode!=nil)
                 [cityTown appendFormat:@"%@",countryCode] ;
             locatedAt=cityTown;
         }
         self.userLocation =locatedAt;
     }];
}
@end
