//
//  RoundColorPicker.h
//  CCBigBang
//
//  Created by sischen on 2018/1/17.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ColorPickerDelegate

-(void)currentColorChangedTo:(UIColor *)color;
-(void)colorPickCompletedWith:(UIColor *)color;

@end


/**
 拾色器
 */
@interface RoundColorPicker : UIView

@property (nonatomic, weak) id <ColorPickerDelegate> delegate;

-(instancetype)initWithColor:(UIColor *)color;

-(void)showInView:(UIView *)superView;

@end
