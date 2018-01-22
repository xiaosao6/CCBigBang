//
//  RoundColorPicker.h
//  CCBigBang
//
//  Created by sischen on 2018/1/17.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 拾色器
 */
@interface RoundColorPicker : UIView

@property (nonatomic, weak) UIView *delegateView;

-(instancetype)initWithColor:(UIColor *)color;

-(void)showInView:(UIView *)superView;

@end
