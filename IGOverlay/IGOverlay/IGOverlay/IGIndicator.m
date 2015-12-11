//
//  IGIndicator.m
//  xiangdemei
//
//  Created by iGalactus on 15/12/8.
//  Copyright © 2015年 一斌. All rights reserved.
//

#import "IGIndicator.h"

@interface IGIndicator ()

@property (nonatomic,strong) CAShapeLayer *progressLayer;
@property (nonatomic) BOOL isAnimating;

@end

@implementation IGIndicator

-(instancetype)init
{
    if (self = [super init])
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [self.layer addSublayer:self.progressLayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAnimations) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.progressLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    
    [self updatePath];
}

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    self.progressLayer.strokeColor = self.tintColor.CGColor;
}

- (void)resetAnimations
{
    if (self.isAnimating)
    {
        [self stopAnimating];
        
        [self startAnimating];
    }
}

- (void)setAnimating:(BOOL)animate
{
    (animate ? [self startAnimating] : [self stopAnimating]);
}

- (void)startAnimating
{
    if (self.isAnimating) return;
    
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.rotation";
    animation.duration = 4.f;
    animation.fromValue = @(0.f);
    animation.toValue = @(2 * M_PI);
    animation.repeatCount = INFINITY;
    [self.progressLayer addAnimation:animation forKey:@"rotationKey"];
    
    CABasicAnimation *headAnimation = [CABasicAnimation animation];
    headAnimation.keyPath = @"strokeStart";
    headAnimation.duration = 1.f;
    headAnimation.fromValue = @(0.f);
    headAnimation.toValue = @(0.25f);
    headAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *tailAnimation = [CABasicAnimation animation];
    tailAnimation.keyPath = @"strokeEnd";
    tailAnimation.duration = 1.f;
    tailAnimation.fromValue = @(0.f);
    tailAnimation.toValue = @(1.f);
    tailAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *endHeadAnimation = [CABasicAnimation animation];
    endHeadAnimation.keyPath = @"strokeStart";
    endHeadAnimation.beginTime = 1.f;
    endHeadAnimation.duration = 0.5f;
    endHeadAnimation.fromValue = @(0.25f);
    endHeadAnimation.toValue = @(1.f);
    endHeadAnimation.timingFunction = self.timingFunction;
    
    CABasicAnimation *endTailAnimation = [CABasicAnimation animation];
    endTailAnimation.keyPath = @"strokeEnd";
    endTailAnimation.beginTime = 1.f;
    endTailAnimation.duration = 0.5f;
    endTailAnimation.fromValue = @(1.f);
    endTailAnimation.toValue = @(1.f);
    endTailAnimation.timingFunction = self.timingFunction;
    
    CAAnimationGroup *animations = [CAAnimationGroup animation];
    [animations setDuration:1.5f];
    [animations setAnimations:@[headAnimation, tailAnimation, endHeadAnimation, endTailAnimation]];
    animations.repeatCount = INFINITY;
    [self.progressLayer addAnimation:animations forKey:@"strokeKey"];
    
    self.isAnimating = true;
    
    if (self.hidesWhenStopped)
    {
        self.hidden = NO;
    }
}

- (void)stopAnimating
{
    if (!self.isAnimating)
    {
        return;
    }
    
    [self.progressLayer removeAnimationForKey:@"rotationKey"];
    [self.progressLayer removeAnimationForKey:@"strokeKey"];
    
    self.isAnimating = NO;
    
    if (self.hidesWhenStopped)
    {
        self.hidden = YES;
    }
}

- (void)updatePath
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGFloat radius = MIN(CGRectGetWidth(self.bounds) / 2, CGRectGetHeight(self.bounds) / 2) - self.progressLayer.lineWidth / 2;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0 endAngle:2 * M_PI clockwise:YES];
    self.progressLayer.path = path.CGPath;
    self.progressLayer.strokeStart = 0.f;
    self.progressLayer.strokeEnd = 0.f;
    self.progressLayer.shadowOffset = CGSizeMake(0, 0);
    self.progressLayer.shadowColor = [UIColor whiteColor].CGColor;
    self.progressLayer.shadowRadius = 3.f;
    self.progressLayer.shadowOpacity = 0.4f;
}

- (CAShapeLayer *)progressLayer
{
    if (!_progressLayer) {
        _progressLayer = [CAShapeLayer layer];
        _progressLayer.strokeColor = self.tintColor.CGColor;
        _progressLayer.fillColor = nil;
        _progressLayer.lineWidth = 1.5f;
    }
    return _progressLayer;
}

- (BOOL)isAnimating
{
    return _isAnimating;
}

- (CGFloat)lineWidth
{
    return self.progressLayer.lineWidth;
}

- (void)setLineWidth:(CGFloat)lineWidth
{
    self.progressLayer.lineWidth = lineWidth;
    
    [self updatePath];
}

- (void)setHidesWhenStopped:(BOOL)hidesWhenStopped
{
    _hidesWhenStopped = hidesWhenStopped;
    
    self.hidden = !self.isAnimating && hidesWhenStopped;
}

@end
