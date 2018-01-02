

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HTTPMethod) {
    HTTPMethodPost = 0,
    HTTPMethodGet  = 1,
};

/**
 HTTP请求对象
 */
@interface HttpRequest : NSObject

@property (nonatomic, strong) NSURLSessionDataTask * _Nullable reqTask;//!<请求任务
@property (nonatomic, assign) double        timeout;        //!<请求超时时间
@property (nonatomic, assign) HTTPMethod    reqMethod;      //!<请求方法
@property (nonatomic, copy)   NSString      * _Nullable reqUrl;        //!<请求的url地址
@property (nonatomic, copy)   NSDictionary  * _Nullable reqParams;     //!<请求参数

-(instancetype _Nonnull)initWithUrl:(NSString *_Nullable)url Params:(NSDictionary *_Nullable)dic;

-(NSString *_Nonnull)reqPrint;///<打印请求链接

@end
