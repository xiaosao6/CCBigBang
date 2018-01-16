//
//  WordModel.m
//  CCBigBang
//
//  Created by sischen on 2017/12/30.
//  Copyright © 2017年 pcbdoor.com. All rights reserved.
//

#import "WordModel.h"
#import <MJExtension/NSObject+MJKeyValue.h>


@interface WordModel ()

@property (nonatomic, readwrite) CGSize rectSize;

@end

@implementation WordModel

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{NSStringFromSelector(@selector(id_)) : @"id"};
}

-(void)setCont:(NSString *)cont{
    _cont = [cont copy];
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:[[NSUserDefaults standardUserDefaults] floatForKey:@"SegmentFontSizeSettingKey"]]};
    CGSize size = [_cont boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 0) options:
                   NSStringDrawingTruncatesLastVisibleLine
                   | NSStringDrawingUsesLineFragmentOrigin
                   | NSStringDrawingUsesFontLeading
                                       attributes:attribute context:nil].size;
    self.rectSize = CGSizeMake(size.width + 18, size.height + 18 * 0.5);
}

@end
