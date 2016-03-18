//
//  HomeViewCtrl.m
//  MobPexDemo
//
//  Created by Jian Hu on 1/28/16.
//  Copyright © 2016 DataYP. All rights reserved.
//

#import "HomeViewCtrl.h"
#import <MobpexSDK/Mobpex.h>
#import "KVNProgress.h"

#define kParserError @"parser-error"
#define kNetworkingError @"networking-error"
#define kServerError @"server-error"
#define kClientError @"client-error"
#define kBizError @"biz-error"

NSString *const MobPexDemoApiURL = @"https://220.181.25.235/yop-center/demo";

@interface HomeViewCtrl () <UITextFieldDelegate, UIWebViewDelegate, NSURLSessionDelegate>

@property(nonatomic, strong)NSNumberFormatter *numFormatter;
@property(nonatomic, weak)UITextField *textField;

@end

@implementation HomeViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Mobpex sdk demo";
    
    [self setupView];
    
    UITapGestureRecognizer *keyboardCancelTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:keyboardCancelTap];
}

- (void)setupView{
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    CGFloat sideInset = 20;
    CGFloat controlHeight = 40;
    CGFloat controlGap = 20;
    CGFloat controlStartY = (screenHeight - 5*(controlGap + controlHeight))/2.0;
    
    //setup amount textfield
    UITextField *inputTextField = ({
        UITextField *input = [UITextField new];
        input.keyboardAppearance = UIKeyboardAppearanceDark;
        input.keyboardType = UIKeyboardTypeDecimalPad;
        CGRect rect = CGRectMake(sideInset, controlStartY, (screenWidth - 2*sideInset), controlHeight);
        input.frame = rect;
        input.placeholder = @"支付金额";
        input.delegate = self;
        self.textField = input;
        input;
    });
    [self.view addSubview:inputTextField];
    
    //setup channel button
    UIButton *alipayButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        CGRect rect = CGRectInset(CGRectOffset(inputTextField.frame, 0, controlHeight+controlGap), 100, 0) ;
        btn.frame = rect;
        [btn setTitle:@"支付宝" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(alipayChosen:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:alipayButton];
    
    UIButton *wxpayButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        CGRect rect = CGRectOffset(alipayButton.frame, 0, controlHeight+controlGap);
        btn.frame = rect;
        [btn setTitle:@"微信" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(wxpayChosen:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:wxpayButton];
    
    UIButton *unionpayButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        CGRect rect = CGRectOffset(wxpayButton.frame, 0, controlHeight+controlGap);
        btn.frame = rect;
        [btn setTitle:@"银联" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(unionpayChosen:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:unionpayButton];
    
    UIButton *yeepayButton = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        CGRect rect = CGRectOffset(unionpayButton.frame, 0, controlHeight+controlGap);
        btn.frame = rect;
        [btn setTitle:@"易宝支付" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(yeepayChosen:) forControlEvents:UIControlEventTouchUpInside];
        btn;
    });
    [self.view addSubview:yeepayButton];
}

#pragma mark - Action Methods
- (void)alipayChosen:(UIButton *)btn{
    if(!btn.isEnabled) return;
    [self hideKeyboard];

    btn.enabled = NO;
    
    [self fetchChannelPaymentInfoWithChannel:@"ALIPAY" success:^(NSDictionary *paymentInfo) {
        btn.enabled = YES;
        
        [[MobPex sharedInstance] payWithChannel:MBPChannelAliPay parameters:paymentInfo];
    } failure:^(NSError *error) {
        btn.enabled = YES;

        [self onError:[self errMessageFromError:error]];
    }];
}

- (void)wxpayChosen:(UIButton *)btn{
    if(!btn.isEnabled) return;
    [self hideKeyboard];

    btn.enabled = NO;

    [self fetchChannelPaymentInfoWithChannel:@"WECHAT" success:^(NSDictionary *paymentInfo) {
        btn.enabled = YES;
        
        [[MobPex sharedInstance] payWithChannel:MBPChannelWeiXin parameters:paymentInfo];
    } failure:^(NSError *error) {
        btn.enabled = YES;
        
        [self onError:[self errMessageFromError:error]];
    }];
}

- (void)unionpayChosen:(UIButton *)btn{
    if(!btn.isEnabled) return;
    [self hideKeyboard];

    btn.enabled = NO;

    [self fetchChannelPaymentInfoWithChannel:@"UPACP" success:^(NSDictionary *paymentInfo) {
        btn.enabled = YES;
        
        [[MobPex sharedInstance] payWithChannel:MBPChannelUPACP parameters:paymentInfo];
    } failure:^(NSError *error) {
        btn.enabled = YES;
        [self onError:[self errMessageFromError:error]];
    }];
}

- (void)yeepayChosen:(UIButton *)btn{
    if(!btn.isEnabled) return;
    [self hideKeyboard];

    btn.enabled = NO;
    
    [self fetchChannelPaymentInfoWithChannel:@"YEEPAY" success:^(NSDictionary *paymentInfo) {
        btn.enabled = YES;
        
        [[MobPex sharedInstance] payWithChannel:MBPChannelYeePay parameters:paymentInfo];
    } failure:^(NSError *error) {
        btn.enabled = YES;
        [self onError:[self errMessageFromError:error]];
    }];
}

// action result indicator
- (void)onError:(NSString*)errMsg{
    [KVNProgress showErrorWithStatus:errMsg];
}

#pragma mark - 发起 Demo API 请求
- (void)fetchChannelPaymentInfoWithChannel:(NSString*)channel success:(void (^)(NSDictionary *paymentInfo))success failure:(void (^)(NSError *error))failure{
    [KVNProgress showWithStatus:@"加载中.."];
    
    NSNumber *ammount = [self.numFormatter numberFromString:self.textField.text];
    NSString *amountStr = [ammount stringValue];
    
    if(!ammount){
        amountStr = @"0.1";
    }
    u_int32_t randInt = arc4random_uniform(UINT_MAX);
    NSString *payType = @"APP";
    if([channel isEqualToString:@"YEEPAY"]){
        payType = @"WAP";
    }
    NSDictionary *formDict = @{@"payType":payType,
                               @"payChannel":channel,
                               @"keyType":@"LS_KEY",
                               @"tradeNo":[@(randInt) stringValue],
                               @"amount":amountStr
                               };
    
    [self requestPaymentInfoWithParams:formDict success:success failure:failure];
}

- (void)requestPaymentInfoWithParams:(NSDictionary*)params success:(void (^)(id JSON))success failure:(void (^)(NSError *error))failure{
    NSURLRequest *req = [self buildRequestWithParams:params];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue new]];
    NSURLSessionTask* task = [session dataTaskWithRequest:req completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
        NSInteger statusCode = httpResp.statusCode;
        NSInteger mod = statusCode/100;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [KVNProgress dismiss];
            
            if(mod==2){// code 2xx
                if(!data || data.length==0){//for status code 204
                    success(nil);
                }else{
                    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                    NSLog(@"%@",jsonStr);
                    
                    NSError *parseErr = nil;
                    id JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&parseErr];
                    if(parseErr){
                        NSError *newErr = [NSError errorWithDomain:kParserError code:parseErr.code userInfo:parseErr.userInfo];
                        failure(newErr);
                        return;
                    }
                    id err = [JSON objectForKey:@"error"];
                    if(err){
                        NSString *errMsg = [err objectForKey:@"message"];
                        NSError *newErr = [NSError errorWithDomain:kBizError code:-1 userInfo:@{@"message":errMsg}];
                        failure(newErr);
                        return;
                    }
                    NSDictionary *paymentInfo = JSON[@"result"][@"paymentParams"];
                    success(paymentInfo);
                }
            }else{
                NSError *newErr = nil;
                if(error==nil){
                    if(mod==4){// code 4xx
                        newErr = [NSError errorWithDomain:kClientError code:httpResp.statusCode userInfo:nil];
                    }else if(mod==5){// code 5xx
                        newErr = [NSError errorWithDomain:kServerError code:httpResp.statusCode userInfo:nil];
                    }
                    failure(newErr);
                }else{ // networking error
                    newErr = [NSError errorWithDomain:kNetworkingError code:error.code userInfo:error.userInfo];
                    failure(newErr);
                }
            }
        });
    }];
    
    [task resume];
}

- (NSURLRequest*)buildRequestWithParams:(NSDictionary*)params{
    NSURL *reqUrl = [NSURL URLWithString:MobPexDemoApiURL];
    NSMutableURLRequest *mutReq = [[NSMutableURLRequest alloc]initWithURL:reqUrl];
    mutReq.HTTPMethod = @"POST";
    
    NSMutableString *combined = [[NSMutableString alloc]init];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        [combined appendString:key];
        [combined appendString:@"="];
        [combined appendString:value];
        [combined appendString:@"&"];
    }];
    [combined deleteCharactersInRange:NSMakeRange(combined.length-1, 1)];
    
    NSCharacterSet *charSet = [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789&="];
    [combined stringByAddingPercentEncodingWithAllowedCharacters:charSet];
    
    NSData* formData = [combined dataUsingEncoding:NSUTF8StringEncoding];
    
    mutReq.HTTPBody = formData;
    
    [mutReq addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [mutReq addValue:[@(formData.length) stringValue] forHTTPHeaderField:@"Content-Length"];
    
    return mutReq;
}

- (NSString *)errMessageFromError:(NSError *)error{
    NSString *domain = error.domain;
    
    if([domain isEqualToString:kNetworkingError]){
        return @"网络错误, 请检查网络状态或者请求 URL 是否正确";
    }else if([domain isEqualToString:kServerError]){
        return @"服务器错误";
    }else if([domain isEqualToString:kClientError]){
        return @"错误请求, 请检查请求参数是否正确";
    }else if([domain isEqualToString:kParserError]){
        return @"Json 解析错误";
    }else if([domain isEqualToString:kBizError]){
        return @"业务错误, 请检查请求参数是否正确";
    }
    return @"";
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler{
    completionHandler(NSURLSessionAuthChallengeUseCredential, [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
}

#pragma mark - Keyboard notification methods
- (void)hideKeyboard
{
    [self.view endEditing:YES];
}

#pragma mark - UITextfield delegate methods
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSMutableString *mutText = [NSMutableString new];
    [mutText appendString:textField.text];
    [mutText replaceCharactersInRange:range withString:string];
    
    if(mutText.length==0) return YES;
    
    if(![mutText hasPrefix:@"¥"]){
        [mutText insertString:@"¥" atIndex:0];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            textField.text = mutText;
        });
        return YES;
    }

    // float point check
    NSRange dotRange = [mutText rangeOfString:@"."];
    if(dotRange.location!=NSNotFound && dotRange.location!=mutText.length-1){
        NSString *afterDot = [mutText substringFromIndex:dotRange.location+1];
        if(afterDot.length>2){
            return NO;
        }
    }
    
    // integer number check
    NSString *integralPart = [mutText substringWithRange:NSMakeRange(1, mutText.length-1)];
    if(dotRange.location!=NSNotFound){
        integralPart = [mutText substringWithRange:NSMakeRange(1, dotRange.location-1)];
    }
    if(integralPart.length>10) return NO;
    
    return YES;
}

- (NSNumberFormatter*)numFormatter{
    if(!_numFormatter){
        self.numFormatter = [NSNumberFormatter new];
        _numFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_Hans"];
        _numFormatter.usesGroupingSeparator = YES;
        _numFormatter.groupingSeparator = @",";
        _numFormatter.decimalSeparator = @".";
        _numFormatter.groupingSize = 3;
        _numFormatter.numberStyle = NSNumberFormatterCurrencyStyle;
        _numFormatter.currencySymbol = @"¥";
        _numFormatter.maximumFractionDigits = 2;
        _numFormatter.minimumFractionDigits = 2;
        _numFormatter.maximumIntegerDigits = 10;
    }
    
    return _numFormatter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
