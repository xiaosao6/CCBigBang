//
//  WordModel.h
//  CCBigBang
//
//  Created by sischen on 2017/12/30.
//  Copyright © 2017年 pcbdoor.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 文本模型
 */
@interface WordModel : NSObject

/**
 文本标识
 */
@property (nonatomic, copy) NSString *id_;
/**
 文本内容
 */
@property (nonatomic, copy) NSString *cont;
/**
 文字显示尺寸
 */
@property (nonatomic, readonly) CGSize rectSize;
/**
 圆角背景图片
 */
@property (nonatomic, readonly) UIImage *cornerBgImg;

@end
