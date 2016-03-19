## Install

### Cocoapods
* 添加 Mobpex spec 仓库到项目 Podfile:
    ``` ruby
    source 'https://gitlab.com/datayp/PodSpecs.git'
    source 'https://github.com/CocoaPods/Specs.git'
    ```
* 添加 MobpexSDK 到 target 当中:
    ``` ruby
    pod 'MobpexSDK'
    ```
* `pod install`


### 手动导入 SDK 

* #### 添加 MobPex SDK
    1. 在官网下载 SDK 文件并解压
    2. 添加 `libMobPexSDK.a` 文件, 并添加到 `target-->Build Phases-->Link Binary With Libraries` 列表当中
    3. 添加 `MobPex.h` 文件, 确保在 xcode 中设置正确的 `Header Search Paths`
* #### 添加第三方支付渠道 SDK (目前支持 支付宝, 微信支付, 银联和易宝支付)
    1. 可以到渠道官网直接下载, 也可以运行 [Demo](https://gitlab.com/datayp/MobpexSDK) 中的 `prepare.sh` 文件来下载, 下载后的文件会在当前目录下的 `libs` 目录当中
    2. 添加渠道 SDK 到项目当中

* #### 系统 FrameWork 依赖
    * `libsqlite3.dylib`
    * `libz.dylib`
    * `libc++.dylib`
    * `SystemConfiguration.framework`
    * `QuartzCore.framework`
    * `CoreMotion.framework`
    * `CFNetwork.framework`
    * `CoreGraphics.framework`
    * `CoreTelephony.framework`
    * `CoreText.framework`

* #### Linker Flags
    在 `Build Settings` 搜索 `Other Linker Flags`，添加 `-ObjC`

## info.plist 配置
* #### 配置 `URL Scheme`
    配置 URL Schemes 的目的在于让第三方支付渠道客户端能够正确的调用你的应用, 来返回支付结果

    * 添加 `URL Schemes`: 在 Xcode 中，选择你的工程设置项，选中 TARGETS 一栏，在 Info 标签栏的 URL Types 添加 URL Schemes
    * 如果使用微信, 填入微信平台上注册的应用程序 id（为 wx 开头的字符串)

* #### 配置 `LSApplicationQueriesSchemes`
    配置 URL Schemes 的目的在于: 在 iOS 9 及以上系统可以正确的启动第三方支付渠道的客户端

    以下是银联, 支付宝和微信支付所需要的配置, 可以按需添加到项目 info.plist 文件当中. 
    或者也可以直接 Copy-Paste [Demo](https://gitlab.com/datayp/MobpexSDK) 当中的对应的配置
    
    ``` xml
    <key>LSApplicationQueriesSchemes</key>
	    <array>
		    <string>uppayx3</string>
		    <string>uppaysdk</string>
		    <string>uppaywallet</string>
		    <string>uppayx1</string>
		    <string>uppayx2</string>
		    <string>weichat</string>
		    <string>weixin</string>
	    	<string>alipay</string>
	    </array>
    ```	

* #### 配置 `ATS`
iOS 9 之后默认会拒绝非安全连接, 所以如果需要的话可以添加以下配置到 info.plist 当中.
或者也可以直接 Copy-Paste [Demo](https://gitlab.com/datayp/MobpexSDK) 当中的对应的配置
    ``` xml
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
    ```
当然你也可以做更细节的控制, 详情可见 Apple 开发文档


## 代码集成

* #### 开始支付
客户端从自己的服务端获取支付参数后 (详情见服务端集成部分), 调用下面的方法开始支付:

    ``` objc
    
    // channel: 表示支付渠道, 此处为支付宝
    // parameters: 表示支付参数 Dictionary, 从服务端获取
    [[MobPex sharedInstance] payWithChannel:MBPChannelAliPay parameters:paymentInfo];
    
    ```
* #### 获取支付结果
支付结果会在 `UIApplicationDelegate` 的 `- application:openURL:xxxx:` 方法中通过 url 内容返回,
通过处理 url 获取的支付结果给传给你提供的回调 block.
回调 block 的参数内容类型见 `MobPex.h` 头文件

    ``` objc
    // iOS iOS 8 及以下
    - (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
     sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
        [[MobPex sharedInstance] handleAppCallbackWithUrl:url
                                   completionCallback:^(MBPResultCode code, NSDictionary *resultDict) {
        // Your code goes here
        // NSLog(@"From AppDelegate @@@@ code:%lu \n result:%@", (unsigned long)code, resultDict);
    }];
        return YES;
    }

    // iOS 9 及以上
    - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id>*)options{
    
        [[MobPex sharedInstance] handleAppCallbackWithUrl:url
                                   completionCallback:^(MBPResultCode code, NSDictionary *resultDict) {
        // Your code goes here
        // NSLog(@"From AppDelegate @@@@ code:%lu \n result:%@", (unsigned long)code, resultDict);
    }];
        return YES;
    }
    ```

注: 此文档可能会按照开发进度不断更新, 一切以最新文档为准
