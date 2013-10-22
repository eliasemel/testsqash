//
//  ProfileViewController.h
//  StoryBoardSample
//
//  Created by dbgmacmini1 on 9/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"
#import "ATTImageSlider.h"
#import "MSPost.h"
#import <RestKit/RestKit.h>
#import "AddPhotosViewController.h"
#import "MSUser.h"
#import "AccountController.h"
#import <CoreLocation/CoreLocation.h>
#import "SettingsController.h"
#import "NotificationButtonViewController.h"
#import "MSSettings.h"
#import "FriendsViewController.h"
#import "AccountDetailsViewController.h"
@interface ProfileViewController : UIViewController<UITableViewDataSource, UITableViewDelegate,UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,CLLocationManagerDelegate, CLLocationManagerDelegate, HPGrowingTextViewDelegate,ATTImageSliderDelegate,AddPhotosNotifier,PassFriendId,ShouldRefreshHeaderDetails,NotificationButtonDelegate>
{
    NSInteger displayedImageIndex;
}
@property(nonatomic,retain) NSString   *userId;
@property(strong,nonatomic) NSString *userLocation;
@property(strong,nonatomic) NSString *selectionStatus;
@property(atomic,assign) int postOffset;
@property(nonatomic, retain)IBOutlet UITableView *myProfileDetailListView;
@property(nonatomic, retain)IBOutlet UITableView *photoDetailListView;
@property (strong,nonatomic) NotificationButtonViewController *notificationButtonViewController;
@property(nonatomic,retain)IBOutlet UIButton *profileBtn;
@property(nonatomic,retain)IBOutlet UIButton *photosBtn;
@property(nonatomic,retain)IBOutlet UIButton *friendsBtn;
@property(nonatomic,retain)IBOutlet UIButton *statsBtn;
@property(nonatomic,retain)IBOutlet UIButton *degreeBtn;
@property(nonatomic,retain)IBOutlet UIButton *myProfileBtn;
@property(nonatomic,retain)IBOutlet UIButton *friendsHeartBtn;
@property(nonatomic,retain)IBOutlet UIView *headerViewForProfile;
@property(nonatomic,retain)IBOutlet UIView *shareView;
@property(nonatomic,retain)IBOutlet UIView *bottomToolBar;
@property(nonatomic,retain)IBOutlet UIView *friendsRequestView;
@property(nonatomic,retain)IBOutlet UIView *friendsRequestSentView;
@property (strong,nonatomic) IBOutlet UILabel *titleView;
@property(nonatomic,retain)IBOutlet UILabel *requestLabel;
@property(nonatomic,retain)IBOutlet UILabel *myDossierLabel;
@property(nonatomic,retain)IBOutlet UILabel *degreeLabel;
@property(nonatomic,retain)IBOutlet UILabel *userNameLabel;
@property(nonatomic,retain)IBOutlet UILabel *levelNameLabel;
@property(nonatomic,retain)IBOutlet UILabel *levelLabel;
@property(nonatomic,retain)IBOutlet UILabel *heartInCountLabel;
@property(nonatomic,retain)IBOutlet UILabel *heartOutCountLabel;
@property(nonatomic,retain)IBOutlet UILabel *heartBankCountLabel;
@property(nonatomic,retain)IBOutlet UILabel *supportPriceLabel;
@property(nonatomic,retain)IBOutlet UIImageView *profileImageView;
@property(nonatomic,retain)IBOutlet UIImageView *badgeImageView;
@property(strong,nonatomic)IBOutlet UIView *notificationButtonView;
@property(nonatomic,retain) NSMutableArray *selectedSetOfUrlsArray;
@property(nonatomic,retain) NSMutableArray *postsArray;
@property(nonatomic,retain) NSMutableArray *albumListArray;
@property (nonatomic, retain) IBOutlet UITextField *sharetextField;
@property (nonatomic, retain) IBOutlet UIView *tabView;
@property(nonatomic, retain) MSSettings *userSettings;
@property(nonatomic, retain) SettingsController *settingsController;
@property (strong, nonatomic) IBOutlet CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet CLGeocoder *geoCoder;
@property(nonatomic, retain) UIActionSheet *heartsActionsheet;
@property(nonatomic, retain) NSString *heartsResourceId;
@property(nonatomic, retain) NSString *heartsResource;
@property(nonatomic, retain) NSIndexPath *heartsPostIndexPath;
-(void)touchOnImageViewInTable:(UIGestureRecognizer*)recognizer;
-(void)setUpViews;
-(void)getDataForMyDossierwithOffset:(int)offset andLimit:(int)limit;
-(float)getHeightFortheDynamicLabel:(NSString *)stringForTheLabel;
-(CGFloat)getHeightforIndexPath:(NSIndexPath *)indexPath;
- (IBAction)profileHeartButtonClicked:(id)sender;
-(IBAction)heartCountBtnPressed:(id)sender;
-(IBAction)commentCountBtnPressed:(id)sender;
-(IBAction)goBack:(id)sender;
-(IBAction)friendsBtnClicked:(id)sender;
-(IBAction)profileBtnClicked:(id)sender;
-(IBAction)photoBtnClicked:(id)sender;
-(IBAction)picUploadBtnClicked:(id)sender;
-(IBAction)videoEmbedBtnClicked:(id)sender;
-(IBAction)myProfileBtnClicked;
-(IBAction)playVideoButtonClick:(id)sender;
-(IBAction)statsBtnClicked:(id)sender;
-(IBAction)sendFriendRequest:(id)sender;
-(IBAction)degreeBtnClicked:(id)sender;
-(IBAction)friendRequestBtn:(id)sender;
-(IBAction)profileImageBtnPressed:(id)sender;
@end
