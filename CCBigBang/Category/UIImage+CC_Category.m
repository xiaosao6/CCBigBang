//
//  UIImage+CC_Category.m
//  CCBigBang
//
//  Created by sischen on 2018/1/8.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

#import "UIImage+CC_Category.h"
#import <objc/runtime.h>

@implementation UIImage (CC_Category)


-(CGSize)cc_corneredSize{
    return [(NSValue *)objc_getAssociatedObject(self, @selector(cc_corneredSize)) CGSizeValue];
}

-(void)setCc_corneredSize:(CGSize)cc_corneredSize{
    objc_setAssociatedObject(self, @selector(cc_corneredSize), [NSValue valueWithCGSize:cc_corneredSize], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIColor *)cc_corneredBgColor{
    return objc_getAssociatedObject(self, @selector(cc_corneredBgColor));
}

-(void)setCc_corneredBgColor:(UIColor *)cc_corneredBgColor{
    objc_setAssociatedObject(self, @selector(cc_corneredBgColor), cc_corneredBgColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}




+(UIImage *)imageWithColor:(UIColor *)color Size:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *retimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    retimg.cc_corneredBgColor = color;
    retimg.cc_corneredSize = size;
    return retimg;
}

- (UIImage *)roundCorner:(CGFloat)radius{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, [UIScreen mainScreen].scale);
    CGPathRef path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(radius, radius)].CGPath;
    CGContextAddPath(UIGraphicsGetCurrentContext(), path);
    CGContextClip(UIGraphicsGetCurrentContext());
    
    [self drawInRect:rect];
    CGContextDrawPath(UIGraphicsGetCurrentContext(), kCGPathFillStroke);
    UIImage *output = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return output;
}

@end
