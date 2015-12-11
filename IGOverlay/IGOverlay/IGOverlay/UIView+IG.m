//
//  UIView+IG.m
//  IGOverlay
//
//  Created by iGalactus on 15/12/4.
//  Copyright © 2015年 一斌. All rights reserved.
//

#import "UIView+IG.h"

@implementation UIView (IG)

-(CGFloat)centerX:(CGFloat)width
{
    return (self.frame.size.width - width ) / 2;
}

-(CGFloat)centerY:(CGFloat)height
{
    return (self.frame.size.height - height) / 2;
}

-(CGFloat)maxY
{
    return CGRectGetMaxY(self.frame);
}

-(CGFloat)clipW:(CGFloat)width
{
    return self.frame.size.width - 2 * width;
}

@end
