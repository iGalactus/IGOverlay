//
//  IGIndicator.h
//  xiangdemei
//
//  Created by iGalactus on 15/12/8.
//  Copyright © 2015年 一斌. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IGIndicator : UIView

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) BOOL hidesWhenStopped;
@property (nonatomic, readonly) BOOL isAnimating;
@property (nonatomic, strong) CAMediaTimingFunction *timingFunction;


- (void)setAnimating:(BOOL)animate;

- (void)startAnimating;

- (void)stopAnimating;

@end
