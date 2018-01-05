

#import <Foundation/Foundation.h>
@class HttpRequest;
@class WordModel;


NS_ASSUME_NONNULL_BEGIN

@protocol HttpReqProtocol <NSObject>

@property (nonatomic, assign, readonly) BOOL netReachable;

///< 发送网络请求 使用block实现回调
- (void)sendReq:(HttpRequest *)req finishBlock:(void(^)(NSArray<WordModel *> *_Nullable raw, NSError *_Nullable error))block;

@end



/**
 Http请求工具
 */
@interface HttpUtil : NSObject <HttpReqProtocol>

///< 获取单例
+ (id <HttpReqProtocol>)util;

@end

NS_ASSUME_NONNULL_END

