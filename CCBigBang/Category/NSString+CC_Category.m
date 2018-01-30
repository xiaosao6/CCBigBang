//
//  NSString+CC_Category.m
//  CCBigBang
//
//  Created by sischen on 2018/1/30.
//  Copyright © 2018年 pcbdoor.com. All rights reserved.
//

#import "NSString+CC_Category.h"

@implementation NSString (CC_Category)

-(BOOL)isPunctuation{
    if (!self || 0 == self.length) {
        return false;
    }
    NSString *symbols = @"。，、＇：∶；?‘’“”〝〞ˆˇ﹕︰﹔﹖﹑·¨….¸;！´？！～—ˉ｜‖＂〃｀@﹫¡¿﹏﹋﹌︴々﹟#﹩$﹠&﹪%*﹡﹢﹦﹤‐￣¯―﹨ˆ˜﹍﹎+=<＿_-\\ˇ~﹉﹊（）〈〉‹›﹛﹜『』〖〗［］《》〔〕{}「」【】︵︷︿︹︽_﹁﹃︻︶︸﹀︺︾ˉ﹂﹄︼";
    return [symbols containsString:self];
}

@end
