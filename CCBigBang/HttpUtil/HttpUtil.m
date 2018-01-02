

#import "HttpUtil.h"
#import <AFNetworking/AFNetworking.h>
#import <MJExtension/NSObject+MJKeyValue.h>
#import "WordModel.h"
#import "HttpRequest.h"


/**
 *    自定义返回数据的解析器
 */
@interface KMJSONResponseSerializer : AFJSONResponseSerializer

@end

@implementation KMJSONResponseSerializer

-(instancetype)init{
    if (self = [super init]) {
        self.acceptableContentTypes =
        [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    } return self;
}

-(id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error{
    
    NSError *tmpErr_ = nil;
    id obj_ = [NSJSONSerialization JSONObjectWithData:data options:0 error:&tmpErr_];
    
    if (!obj_ || ![obj_ isKindOfClass:NSDictionary.class] || tmpErr_) {//返回内容不是json字典
        NSData *decodedData = [[NSData alloc] initWithBase64EncodedData:data options:0];
        if (decodedData) { data = decodedData; }//若能解码,说明解码方式正确
    }
    
    return [super responseObjectForResponse:response data:data error:error];
}

@end






@interface AFHTTPSessionManager ()
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;
@end

@interface HttpUtil()
@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, assign, readwrite) BOOL netReachable;
@end

@implementation HttpUtil

+ (HttpUtil *)util{
    static HttpUtil *singleton = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        singleton = [[HttpUtil alloc] init];
        
        AFNetworkReachabilityManager *netManager = [AFNetworkReachabilityManager sharedManager];
        [netManager startMonitoring]; // 开始监听网络状态
        [netManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                case AFNetworkReachabilityStatusNotReachable:
                    singleton.netReachable = NO;
                    break;
                case AFNetworkReachabilityStatusReachableViaWWAN:
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    singleton.netReachable = YES;
                    break;
            }
        }];
    });
    return singleton;
}

-(NSString *)mothodStrWithType:(HTTPMethod)type{
    switch (type) {
        case HTTPMethodPost: return @"POST";
        case HTTPMethodGet:  return @"GET";
    }
}

- (void)sendReq:(HttpRequest *)req finishBlock:(void(^)(NSArray<WordModel *> *_Nullable raw, NSError *_Nullable error))block{
    
    [self.manager.requestSerializer setTimeoutInterval:req.timeout];
    
    req.reqTask = [self.manager dataTaskWithHTTPMethod:[self mothodStrWithType:req.reqMethod]
                                             URLString:req.reqUrl
                                            parameters:req.reqParams
                                        uploadProgress:nil
                                      downloadProgress:nil
                                               success:^(NSURLSessionDataTask *task, id responseObject) {
                                                   NSArray <WordModel *> *arr = [self arrayOfRawResponse:responseObject];
                                                   block(arr, nil);
                                               } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                   block(nil, error);
                                               }];
    [req.reqTask resume];
}

-(NSArray <WordModel *> *)arrayOfRawResponse:(id)response{
    if ([response isKindOfClass:[NSArray class]]) {
        NSArray *innerArr = [((NSArray *)response) lastObject];
        if ([innerArr isKindOfClass:[NSArray class]]) {
            NSMutableArray *resArr = [NSMutableArray array];
            for (NSArray *finalArr in innerArr) { [resArr addObjectsFromArray:finalArr]; }
            NSArray <WordModel *> *ret = [WordModel mj_objectArrayWithKeyValuesArray:resArr];
            return ret;
        }
    }
    return nil;
}

#pragma mark -- setter/getter
-(AFHTTPSessionManager *)manager{
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        _manager.responseSerializer = [[KMJSONResponseSerializer alloc] init];
        _manager.securityPolicy = [AFSecurityPolicy defaultPolicy];
    } return _manager;
}


@end
