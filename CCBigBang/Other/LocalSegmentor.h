//
//  LocalSegmentor.h
//  CCBigBang
//
//  Created by sischen on 2018/1/5.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class WordModel;

/**
 封装的本地分词工具
 */
@interface LocalSegmentor : NSObject

+(void)initSegmentor;

+(NSArray <NSString *> *)handleCutWithInput:(NSString *)input;

+(NSArray <WordModel *> *)cutIntoModelWithInput:(NSString *)input;

@end
