

#import "HttpRequest.h"

//超时设置
static const double HTTP_TIMEOUT = 15.0;

@implementation HttpRequest

-(instancetype)initWithUrl:(NSString *)url Params:(NSDictionary *)dic{
    if (self = [super init]) {
        self.timeout = HTTP_TIMEOUT;
        self.reqMethod = HTTPMethodPost; //默认访问为post方法
        self.reqUrl = url;
        self.reqParams = dic;
    } return self;
}

-(NSString *)reqPrint{
    NSString *paramStr  = [NSString string];
    NSArray  *paramKeys = [_reqParams allKeys];
    
    if (paramKeys.count) {
        NSMutableArray *paramArr = [NSMutableArray array];
        for (NSString *key in paramKeys) {
            NSString *value = _reqParams[key];
            [paramArr addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
            // [value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]
        }
        paramStr = [paramArr componentsJoinedByString:@"&"];
    }
    return [NSString stringWithFormat:@"%@?%@", _reqUrl, paramStr];
}


@end
