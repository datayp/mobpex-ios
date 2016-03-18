//
//  mobpex.h
//  mobpex
//
//  Created by Jian Hu on 16/2/14.
//  Copyright © 2016年 DataYP. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 接入渠道定义
 */
typedef enum : NSUInteger {
    MBPChannelWeiXin, // 微信
    MBPChannelAliPay, // 支付宝
    MBPChannelYeePay, // 易宝支付
    MBPChannelUPACP, // 银联支付
    MBPChannelApplePay // 苹果支付？什么？苹果能用来支付？
} MBPChannel;

/**
 支付结果定义
 */
typedef enum : NSUInteger {
    MBPResultCodeSuccuss, // 成功
    MBPResultCodeFailed, // 失败
    MBPResultCodeInProcessing, // 正在处理
    MBPResultCodeNetworkingError, // 网络错误
    MBPResultCodeUserCancelled, // 用户取消支付
    MBPResultCodeOther, // 其他
} MBPResultCode;

/**
 完成后的回调方法定义
 @param code 支付结果代码
 @param resultDict 支付结果的一些数据, 包含 ｀channle｀ 表示支付渠道
 `message` 表示文本信息
 */
typedef void (^MBPCallBackBlock)(MBPResultCode code, NSDictionary* resultDict);

@interface MobPex : NSObject

/**
 MobPex 单例方法
 @return MobPex 实例
 */
+ (instancetype)sharedInstance;

/**
 调用此方法来开始支付
 @param channel 支付渠道
 @param params 参数内容从服务器获取
 */
- (void)payWithChannel:(MBPChannel)channel parameters:(NSDictionary*)params;
    
/**
 处理回调 URL 的方法
 在 UIApplicationDelegate 的 App url 回调方法中调用此方法
 @param url App 回调 URL
 @param completeBlock 在此方法处理完 url 所携带的内容后，会把支付结果传入 completeBlock 并调用
 */
- (void)handleAppCallbackWithUrl:(NSURL *)url completionCallback:(MBPCallBackBlock)completeBlock;

@end