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
        self.cornerBgImg = [[UIImage imageWithColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] Size:self.rectSize] roundCorner:8];

        NSString *cString = [[NSUserDefaults standardUserDefaults] stringForKey:@"SegmentCellBgColorSettingKey"];
        if (cString.length < 6)
            cString = @"000000";
        if ([cString hasPrefix:@"0X"] || [cString hasPrefix:@"0x"])
            cString = [cString substringFromIndex:2];
        if ([cString hasPrefix:@"#"])
            cString = [cString substringFromIndex:1];
        if (cString.length != 6)
            cString = @"000000";
        unsigned int r, g, b;
        [[NSScanner scannerWithString:[cString substringWithRange:NSMakeRange(0, 2)]] scanHexInt:&r];
        [[NSScanner scannerWithString:[cString substringWithRange:NSMakeRange(2, 2)]] scanHexInt:&g];
        [[NSScanner scannerWithString:[cString substringWithRange:NSMakeRange(4, 2)]] scanHexInt:&b];
        UIColor *color = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1];
        
        self.cornerBgImg_Selected = [[UIImage imageWithColor:color Size:self.rectSize] roundCorner:8];
    });
}

@end
