//
//  WordModel.m
//  CCBigBang
//
//  Created by sischen on 2017/12/30.
//  Copyright © 2017年 pcbdoor.com. All rights reserved.
//

#import "WordModel.h"
#import <MJExtension/NSObject+MJKeyValue.h>
#import "UIImage+CC_Category.h"


@interface WordModel ()

@property (nonatomic, readwrite) CGSize rectSize;
@property (nonatomic, readwrite) UIImage *cornerBgImg;
@property (nonatomic, readwrite) UIImage *cornerBgImg_Selected;

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
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.cornerBgImg = [[UIImage imageWithColor:[UIColor lightGrayColor] Size:self.rectSize] roundCorner:8];
        self.cornerBgImg_Selected = [[UIImage imageWithColor:[UIColor cyanColor] Size:self.rectSize] roundCorner:8];
    });
}

@end
