//
//  LocalSegmentor.m
//  CCBigBang
//
//  Created by sischen on 2018/1/5.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

#import "LocalSegmentor.h"
#import "WordModel.h"
#import "Segmentor.h"

@implementation LocalSegmentor

+(void)initSegmentor{
    NSString *dictPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/jieba.dict.small.utf8"];
    NSString *hmmPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/hmm_model.utf8"];
    NSString *userDictPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"iosjieba.bundle/dict/user.dict.utf8"];
    
    NSLog(@"dictPath:%@",dictPath);
    NSLog(@"hmmPath:%@", hmmPath);
    NSLog(@"userDictPath:%@",userDictPath);
    
    const char *cDictPath = [dictPath UTF8String];
    const char *cHmmPath  = [hmmPath UTF8String];
    const char *cUserDictPath = [userDictPath UTF8String];
    
    JiebaInit(cDictPath, cHmmPath, cUserDictPath);
}

+(NSArray <NSString *> *)handleCutWithInput:(NSString *)input{
    const char* sentence = [input UTF8String];
    std::vector<std::string> words;
    JiebaCut(sentence, words);
    
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:input.length/2];
    for (int i = 0; i < words.size(); i++) {
        [arr addObject:[NSString stringWithUTF8String:words[i].c_str()]];
    }
    return arr;
}

+(NSArray <WordModel *> *)cutIntoModelWithInput:(NSString *)input{
    NSArray <NSString *> *strArr = [self handleCutWithInput:input];
    NSMutableArray <WordModel *> *modelArr = [NSMutableArray arrayWithCapacity:strArr.count];
    for (NSString *str in strArr) {
        WordModel *model = [WordModel new];
        model.id_  = [NSString stringWithFormat:@"%lu",(unsigned long)[strArr indexOfObject:str]];
        model.cont = str;
        [modelArr addObject:model];
    }
    return modelArr;
}

@end
