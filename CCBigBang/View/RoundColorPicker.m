//
//  RoundColorPicker.m
//  CCBigBang
//
//  Created by sischen on 2018/1/17.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

#import "RoundColorPicker.h"


@interface WSColorImageView : UIImageView
@property (copy, nonatomic) void(^currentColorBlock)(UIColor *color);
@end

@implementation WSColorImageView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width)];
    if (self) {
        self.image = [UIImage imageNamed:@"palette"];
        self.userInteractionEnabled = YES;
        self.layer.cornerRadius = frame.size.width/2;
        self.layer.masksToBounds = YES;
    } return self;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint pointL = [touch locationInView:self];
    
    if (pow(pointL.x - self.bounds.size.width/2, 2)+pow(pointL.y-self.bounds.size.width/2, 2) <= pow(self.bounds.size.width/2, 2)) {
        UIColor *color = [self colorAtPixel:pointL];
        if (self.currentColorBlock) {
            self.currentColorBlock(color);
        }
    }
}


- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint pointL = [touch locationInView:self];
    
    if (pow(pointL.x - self.bounds.size.width/2, 2)+pow(pointL.y-self.bounds.size.width/2, 2) <= pow(self.bounds.size.width/2, 2)) {
        UIColor *color = [self colorAtPixel:pointL];
        if (self.currentColorBlock) {
            self.currentColorBlock(color);
        }
    }
}



- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint pointL = [touch locationInView:self];
    
    if (pow(pointL.x - self.bounds.size.width/2, 2)+pow(pointL.y-self.bounds.size.width/2, 2) <= pow(self.bounds.size.width/2, 2)) {
        UIColor *color = [self colorAtPixel:pointL];
        if (self.currentColorBlock) {
            self.currentColorBlock(color);
        }
    }
}



//获取图片某一点的颜色
- (UIColor *)colorAtPixel:(CGPoint)point {
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, self.image.size.width, self.image.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = self.image.CGImage;
    NSUInteger width = self.image.size.width;
    NSUInteger height = self.image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    NSLog(@"R:%f   G:%f   B:%f   A:%f",red,green,blue,alpha);
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)setImage:(UIImage *)image {
    CGSize imageSize = CGSizeMake(self.frame.size.width, self.frame.size.width); //CGSizeMake(25, 25)
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    CGRect imageRect = CGRectMake(0.0, 0.0, imageSize.width, imageSize.height);
    [image drawInRect:imageRect];
    UIImage *outimage = UIGraphicsGetImageFromCurrentImageContext();
    
    [super setImage:outimage];
}

@end






@interface RoundColorPicker () {
    UIColor *_tmpColor;
}
@property (nonatomic, strong) WSColorImageView *colorImgv;
@end

static const CGFloat pickerHeight = 220;
static const CGFloat paletteSize  = 120;
static const CGFloat paletteLRGap = 30;

@implementation RoundColorPicker

-(instancetype)initWithColor:(UIColor *)color{
    if (self = [super init]) {
        _tmpColor = color;
    } return self;
}

-(void)showInView:(UIView *)superView{
    UIView *mask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(superView.bounds), CGRectGetHeight(superView.bounds))];
    mask.tag = 666;
    mask.backgroundColor = [UIColor colorWithWhite:0.5 alpha:0.3];
    [mask addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgMaskTapped:)]];
    [superView addSubview:mask];
    
    self.frame = CGRectMake(0.5*(superView.bounds.size.width-(paletteSize+2*paletteLRGap)), 0.5*(superView.bounds.size.height-pickerHeight), paletteSize+2*paletteLRGap, pickerHeight);
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = 10;
    [self addSubview:self.colorImgv];
    
    UILabel *infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 25, self.bounds.size.width-15*2, 60)];
    infoLabel.textAlignment = NSTextAlignmentCenter;
    infoLabel.numberOfLines = 0;
    infoLabel.text = @"触摸以修改颜色, 松开确定";
    [self addSubview:infoLabel];
    
    [superView addSubview:self];
}

-(void)dismiss{
    [[self.superview viewWithTag:666] removeFromSuperview];
    [self removeFromSuperview];
}

#pragma mark -
#pragma mark - Private
-(void)bgMaskTapped:(UITapGestureRecognizer *)tapgr{
    [self dismiss];
}

-(void)dealloc{
    NSLog(@"%@ 销毁了",self.class.description);
}

#pragma mark - getter/setter
-(WSColorImageView *)colorImgv{
    if (_colorImgv) { return _colorImgv; }
    _colorImgv = [[WSColorImageView alloc] initWithFrame:CGRectMake(paletteLRGap, pickerHeight-paletteSize-15, paletteSize, paletteSize)];
    return _colorImgv;
}

@end
