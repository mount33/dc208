
//
//  AppLibHelper.m
//  IF
//
//  Created by chenliang on 14/12/2.
//
//

#include "AppLibHelper.h"
#include "HelpshiftCocos2dx.h"
#import "Adjust.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#include "PlatformUtil.h"
#import <GameKit/GameKit.h>

#import <Chartboost/Chartboost.h>
#import <Chartboost/CBNewsfeed.h>
#import <CommonCrypto/CommonDigest.h>
#import <AdSupport/AdSupport.h>

//#import "InMobi.h"
//#import "IMConstants.h"
#import <Partytrack/Partytrack.h>
#include "ACTReporter.h"
#import <Fabric/Fabric.h>
#import <NanigansSDK/NanigansSDK.h>
#include "./Ext/CCDevice.h"
#import "AppsFlyerTracker.h"
#import <Branch/Branch.h>
//#import <TwitterKit/TwitterKit.h>
#import "WeiboSDK.h"
#include "SNSUtil.h"
//#include "ShareSDKUtil.h"
#import <MobileAppTracker/MobileAppTracker.h>
#import "adBertIADGameSDK.h"

void AppLibHelper::initLibs(){
    
    //helpshift
    HelpshiftCocos2dx::install("78595a4520a0688ffb956c4067a028e9",
                               "elex.helpshift.com",
                               "elex_platform_20141202023300092-786765b5a741399");
    
    //adjust
    NSString *yourAppToken = @"evjqgpfe66zl";
    NSString *environment = ADJEnvironmentProduction;
    ADJConfig *adjustConfig = [ADJConfig configWithAppToken:yourAppToken
                                                environment:environment];
//    [adjustConfig setLogLevel:ADJLogLevelVerbose];
    [Adjust appDidLaunch:adjustConfig];
    
    //chartboost
    [Chartboost startWithAppId:@"5477e29543150f10bae6f022"
                  appSignature:@"cca2c9bbdbd7e935a82cea1569e7950ff45528dd"
                      delegate:NULL];
    
    //inmobi
//    [InMobi initialize:@"81b50f9c47454f5abd0b5844aa161152"];
    
    //party
    [[Partytrack sharedInstance] startWithAppID:4419 AndKey:@"2f4cf9ad914f2042b48cf8e994c6e95c"];
    
    //adwords
    [ACTConversionReporter reportWithConversionID:@"988731911" label:@"FNpUCKCNv1gQh7S71wM" value:@"0.00" isRepeatable:NO];

    //twitter
//    [[Twitter sharedInstance] startWithConsumerKey:@"SwpZfIehpp9LR6jWVHbOBExPI"
//                                    consumerSecret:@"HvzPRLmIsELDmSh8LFSclDsvDKwftgrIi5V3Tpmzt9KG3mArKm"];
//    [Fabric with:@[[Twitter sharedInstance]]];
    
    //nanigans
    [NANTracking setNanigansAppId:@"217314" fbAppId:@"1670702669839400"];
    string deviceUid = cocos2d::extension::CCDevice::getDeviceUid();
    [NANTracking setUserId:[NSString stringWithUTF8String:deviceUid.c_str()]];
    [NANTracking trackAppLaunch: nil];
    
    //appsflyer
    [AppsFlyerTracker sharedTracker].appsFlyerDevKey = @"2zyZ7Ubw9shuEjnRQZKiZX";
    [AppsFlyerTracker sharedTracker].appleAppID = @"945274928";
    
    //需要额外delegate的初始化
    [SNSUtiliesIOS shared];
    
    // 初始化shareSDK
//    ShareSDKUtil::initShareSDKUtil();
    
    //tune
    [Tune initializeWithTuneAdvertiserId:@"190521" tuneConversionKey:@"b186337e4d5b34c993a791bad8646339"];
    
    //AdbertSDK 初始化 ，add by zhengwei 20160119
    // adBertIADGameSDK *adbertGameSDK = [[adBertIADGameSDK alloc] init];
    // adbertGameSDK.gameID = @"2015110500004";
    // adbertGameSDK.applyID = @"faa99e4753b0a3da3d5f8d1c4c70e64c";
    // [adbertGameSDK initialize];
    
}

string AppLibHelper::getLocalCountry(){
    NSLocale *locale = NSLocale.currentLocale;
    if(!locale){
        return "";
    }
    NSString *countryCode = [locale objectForKey:NSLocaleCountryCode];
    if(!countryCode){
        return "";
    }
    return [countryCode UTF8String];
}

void AppLibHelper::sendToBranch(std::string cmd, std::string value){
    Branch *branch = [Branch getInstance];
    NSString *cmdStr = [NSString stringWithUTF8String:cmd.c_str()];
    NSString *valueStr = [NSString stringWithUTF8String:value.c_str()];
    [branch getShortURLWithParams:@{cmdStr: valueStr} andChannel:@"sms" andFeature:BRANCH_FEATURE_TAG_SHARE andCallback:^(NSString *url, NSError *error) {
        if (!error && url){
            std::string urlStr = [url cStringUsingEncoding: NSUTF8StringEncoding];
            CCSafeNotificationCenter::sharedNotificationCenter()->postNotification("branch", CCStringMake(urlStr));
        }
    }];
}

//调用各包jni的接口
void AppLibHelper::sendPayLog(const string &cost,const string &itemId){
    //adjust
    double price = [[NSString stringWithUTF8String:cost.c_str()] doubleValue];
    ADJEvent *event = [ADJEvent eventWithEventToken:@"yfrxfe"];
    [event setRevenue:price currency:@"USD"];
    [Adjust trackEvent:event];
    //party
    NSString *itemName = [NSString stringWithUTF8String:cost.c_str()];
    [[Partytrack sharedInstance] sendPaymentWithParameters:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithInt:1],@"item_num",[NSNumber numberWithDouble: price],@"item_price",@"USD",@"item_price_currency",itemName,@"item_name ", nil]];
    //nanigans
    [NANTracking trackSingleProductPurchase:itemName value:price * 100 currency:@"USD" quantity:1];
    //adwords
    NSString *priceDollar = [NSString stringWithUTF8String:cost.c_str()];
    [ACTConversionReporter reportWithConversionID:@"988731911" label:@"H7FMCMKNsV4Qh7S71wM" value:priceDollar isRepeatable:YES];
    //tune
    TuneEventItem *item = [TuneEventItem eventItemWithName:itemName unitPrice:price quantity:1];
    NSArray *eventItems = @[item];
    TuneEvent *tuenEvent = [TuneEvent eventWithId:1022925749];
    tuenEvent.eventItems = eventItems;
    tuenEvent.revenue = price;
    tuenEvent.currencyCode = @"USD";
    [Tune measureEvent:tuenEvent];
}

void AppLibHelper::sendAdjustTrack(const string &track){
    NSString *eventToken = NULL;
    NSInteger tuneEvent = 0;
    if("two_days_login" == track){
        eventToken = @"napcq5";
        tuneEvent = 1021844745;
    }
    if("tutorial_over" == track){
        eventToken = @"rt3ax4";
        tuneEvent = 1021846035;
    }
    if("first_pay" == track){
        eventToken = @"1pc0mi";
//        tuneEvent = ;
    }
    if("reach_level_4" == track){
        eventToken = @"lw6dav";
        tuneEvent = 1021847433;
    }
    if("reach_level_5" == track){
        eventToken = @"sbknue";
        tuneEvent = 1088098819;
    }
    if("reach_level_6" == track){
        eventToken = @"zawvhh";
        tuneEvent = 1021848237;
    }
    if(eventToken != NULL){
        ADJEvent *event = [ADJEvent eventWithEventToken:eventToken];
        [Adjust trackEvent:event];
    }
    if("two_days_login" == track){
        [[AppsFlyerTracker sharedTracker] trackEvent:@"cok_one_day_retention" withValue:@""];
    }
    if(tuneEvent != 0){
        [Tune measureEventId:tuneEvent];
    }
}

void AppLibHelper::updatePlatformScore(int score){
    if ([GKLocalPlayer localPlayer].isAuthenticated) {
        NSString *identifier = @"castle";
        GKScore *scoreReporter = [[GKScore alloc] initWithLeaderboardIdentifier: identifier];
        scoreReporter.value = score;
        scoreReporter.context = 0;
        
        NSArray *scores = @[scoreReporter];
        [GKScore reportScores:scores withCompletionHandler:^(NSError *error) {
            //Do something interesting here.
        }];
    }
}

void AppLibHelper::triggerEventActivate(){
    [FBSDKAppEvents activateApp];
    [[AppsFlyerTracker sharedTracker] trackAppLaunch];
    [Tune measureSession];
}

void AppLibHelper::triggerEventExistUser(){
    [Tune setExistingUser:true];
}

void AppLibHelper::triggerEventLoginComplete(const string &userId, const string &userName, const string &userLevel, const string &cokfbad){
    TuneEvent *tuenEvent = [TuneEvent eventWithId:1039267685];
    tuenEvent.attribute1 = [NSString stringWithUTF8String:userId.c_str()];
    tuenEvent.attribute2 = [NSString stringWithUTF8String:cokfbad.c_str()];
    [Tune measureEvent:tuenEvent];
    
    ADJEvent *adjEvent = [ADJEvent eventWithEventToken:@"eynjfo"];
    [adjEvent addCallbackParameter:@"cokuid" value:[NSString stringWithUTF8String:userId.c_str()]];
    [adjEvent addCallbackParameter:@"cokfbad" value:[NSString stringWithUTF8String:cokfbad.c_str()]];
    [Adjust trackEvent:adjEvent];
}

void AppLibHelper::triggerEventCompletedRegistration(){
    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedRegistration];
}

void AppLibHelper::triggerEventCompletedTutorial(){
    [FBSDKAppEvents logEvent:FBSDKAppEventNameCompletedTutorial];
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventTutorial_completion withValue:@""];
}

void AppLibHelper::triggerEventAchievedLevel(int level){
    NSString *eventLevel = [NSString stringWithFormat:@"%d",level];
    [FBSDKAppEvents logEvent:FBSDKAppEventNameAchievedLevel
               parameters:@{ FBSDKAppEventParameterNameLevel : eventLevel}];
    
    [[AppsFlyerTracker sharedTracker] trackEvent: AFEventLevelAchieved withValues:@{AFEventParamLevel:eventLevel}];
}

void AppLibHelper::triggerEventPurchaseInit(const string &cost,const string &itemId){
    
}

//调用IF的jni接口，所有包一起统计
void AppLibHelper::triggerEventPurchase(const string &cost,const string &itemId){
    //这段之前没有调到，然而FB上有数据，疑似第三方平台上传的数据
//    double price = [[NSString stringWithUTF8String:cost.c_str()] doubleValue];
//    [FBSDKAppEvents logPurchase:price currency:@"USD"];
    //appsflyer
    NSString *purchaseItem = [NSString stringWithUTF8String:itemId.c_str()];
    NSString *purchaseDollar = [NSString stringWithUTF8String:cost.c_str()];
    NSDictionary *afObj = @{AFEventParamContentId:purchaseItem,
                            AFEventParamRevenue:purchaseDollar,
                            AFEventParamCurrency:@"USD"};
    [[AppsFlyerTracker sharedTracker] trackEvent:AFEventPurchase withValues:afObj];
}

string AppLibHelper::getAppsFlyerUID(){
    return [[[AppsFlyerTracker sharedTracker] getAppsFlyerUID] UTF8String];
}
