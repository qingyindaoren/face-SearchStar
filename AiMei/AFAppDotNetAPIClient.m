// AFAppDotNetAPIClient.h
//

#import "AFAppDotNetAPIClient.h"


//基地址
/*

*/


static NSString *SERVERHTTPS_URL = @"https://api-cn.faceplusplus.com/imagepp/";

@interface AFAppDotNetAPIClient ()
@property (nonatomic,copy)void(^successBlock)( NSURLSessionDataTask *task, id responseObject);
@property (nonatomic,copy)void(^failtureBlock)(  NSURLSessionDataTask *task,NSError * error);
@end


@implementation AFAppDotNetAPIClient

//从appstore获取信息用



+ (instancetype)sharedZCClient {
    static AFAppDotNetAPIClient *_sharedZCClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedZCClient = [[AFAppDotNetAPIClient alloc] initWithBaseURL:[NSURL URLWithString:SERVERHTTPS_URL]];
  
            _sharedZCClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
            
       
         _sharedZCClient.requestSerializer.timeoutInterval = 20;
            [_sharedZCClient.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        //告诉AFN，下载下来的数据是JSON，直接解析返回给我们
        _sharedZCClient.responseSerializer = [AFJSONResponseSerializer serializer];
        _sharedZCClient.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml",@"text/plain", nil];
        
        
    });
    
    return _sharedZCClient;
}




- (void)request:(HTTPMethod)method urlString:(NSString*)urlString parameters:(NSDictionary*)parameters finished:(void(^)( id responseObject,NSError * error))finished{
    self.successBlock = ^( NSURLSessionDataTask *task,id responseObject) {
        finished(responseObject,nil);
    };
    self.failtureBlock = ^( NSURLSessionDataTask *task, NSError *error) {
        finished(nil,error);
    };
    if (method == GET ) {
        [self GET:urlString parameters:parameters progress:nil success:self.successBlock failure:self.failtureBlock];
    }else if (method == POST){
        [self POST:urlString parameters:parameters progress:nil success:self.successBlock failure:self.failtureBlock];
    }
}

@end







