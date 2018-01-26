//
//  UIImage+CC_Category.h
//  CCBigBang
//
//  Created by sischen on 2018/1/8.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 UIImage分类
 */
@interface UIImage (CC_Category)

/**
 *  用UIColor画一张image
 */
+(UIImage *)imageWithColor:(UIColor *)color Size:(CGSize)size;

/**
 *    为图片加上圆角,UIImage尺寸小可以在主线程调用，尺寸大则可能卡顿，需异步处理
 */
- (UIImage *)roundCorner:(CGFloat)radius;


/**
 高斯模糊图片

 @param blurRadius 模糊半径
 @param saturationDeltaFactor 饱和度因子
 @return 模糊后的图片
 */
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius saturationDeltaFactor:(CGFloat)saturationDeltaFactor;

@end
