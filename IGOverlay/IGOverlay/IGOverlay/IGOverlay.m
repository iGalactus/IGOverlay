//
//  YBOverlay.m
//  xiangdemei
//
//  Created by iGalactus on 15/12/3.
//  Copyright © 2015年 一斌. All rights reserved.
//

#if !__has_feature(objc_arc)
#error TAOverlay is ARC only. Please turn on ARC for the project or use -fobjc-arc flag
#endif

#import "IGOverlay.h"
#import "UIView+IG.h"
#import "IGIndicator.h"

#define keyWindow [UIApplication sharedApplication].keyWindow

#define IGDEFAULT_LABEL_FONT 15
#define IGDEFAULT_ICON_SIZE 35

#define IGMAX_OVERLAY_WIDTH 100

#define IGPADDING_ICON_SLIDE 10
#define IGPADDING_ICON_TOP 20
#define IGPADDING_ICON_BOTTOM 10

#define IGPADDING_LABEL_DISTACEN 10

#define IGDISMISS_ANIMATION_TIME 0.3f

//////////////////MATH

#define IGCLIPW(a,b)  a - 2 * b
#define IGCENTERX(a,b) (a - b) / 2

@interface IGOverlay()

@property (nonatomic,strong) UIToolbar *overlay;
@property (nonatomic,strong) IGIndicator *indicator;
@property (nonatomic,strong) UILabel *label;
@property (nonatomic,strong) CAShapeLayer *shapeLayer;
@property (nonatomic,strong) NSTimer *scheduleTimer;

//是否包含头部信息
@property (nonatomic) BOOL isContainsHeader;

//是否选择视图根据文字来规定高度
@property (nonatomic) BOOL isResizeLabelByStatus;

//是否能让用户点击
@property (nonatomic) BOOL isUserInteraction;

@end

@implementation IGOverlay

+(IGOverlay *)sharedInstance
{
    static IGOverlay *overlay = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ overlay = [[IGOverlay alloc] init];});
    return overlay;
}

-(instancetype)init
{
    if (self = [super init])
    {
        [self initOverlayUI];
        
        self.userInteractionEnabled = YES;
        
        self.shapeLayerColor = [UIColor redColor];
        
        self.dismissTimeInterval = 0;
    }
    return self;
}

-(void)initOverlayUI
{
    if (!self.overlay)
    {
        self.overlay = [[UIToolbar alloc] initWithFrame:CGRectZero];
        self.overlay.translucent = YES;
        self.overlay.layer.cornerRadius = 8;
        self.overlay.layer.masksToBounds = YES;
        self.overlay.barTintColor = [UIColor blackColor];
        [self addSubview:self.overlay];
    }
    
    if (!self.label)
    {
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.numberOfLines = 0;
        self.label.lineBreakMode = NSLineBreakByCharWrapping;
        [self.overlay addSubview:self.label];
    }
    
    if (!self.shapeLayer)
    {
        self.shapeLayer = [CAShapeLayer layer];
        self.shapeLayer.frame = [self resizeIconFrame];
        self.shapeLayer.borderWidth = 3.0f;
        self.shapeLayer.fillColor = [UIColor whiteColor].CGColor;
        self.shapeLayer.borderColor = [UIColor whiteColor].CGColor;
        self.shapeLayer.cornerRadius = IGDEFAULT_ICON_SIZE / 2;
        self.shapeLayer.strokeColor = [UIColor clearColor].CGColor;
        [self.shapeLayer setStrokeEnd:0.0];
        [self.overlay.layer addSublayer:self.shapeLayer];
    }
    
    if (!self.indicator)
    {
        self.indicator = [[IGIndicator alloc] init];
        self.indicator.tintColor = [UIColor redColor];
        self.indicator.lineWidth = 3.0f;
        [self.overlay addSubview:self.indicator];
    }
}

-(void) initializeOverlay
{
    self.alpha = 1.f;
    
    self.overlay.frame = [self resizeOverlayFrame];
    
    self.label.text = self.status;
    
    [self.indicator stopAnimating];
    
    self.isContainsHeader = NO;
    
    self.isResizeLabelByStatus = NO;
    
    self.isUserInteraction = YES;
    
    self.label.textColor = self.overlayTextColor ? self.overlayTextColor : [UIColor whiteColor];
    
    self.label.font = self.overlayTextFont ? self.overlayTextFont : [UIFont systemFontOfSize:IGDEFAULT_LABEL_FONT];
    
    self.indicator.tintColor = self.shapeLayerColor ? self.shapeLayerColor : [UIColor redColor];
    
    self.shapeLayer.fillColor = self.shapeLayer.borderColor = self.shapeLayerColor.CGColor;
}

/**
 *  加载视图相关
 */

+(void)showOverlayWithIndicatorInView:(UIView *)view
{
    [self showOverlayWithIndicatorWithStatus:nil showInView:view];
}

+(void)showOverlayWithStatus:(NSString *)status showInView:(UIView *)view
{
    [self showOverlayWithStatus:status options:IGOverlayOptionNone showInView:view];
}

+(void)showOverlayWithIndicatorWithStatus:(NSString *)status showInView:(UIView *)view
{
    [self showOverlayWithStatus:status options:IGOverlayOptionHeaderTypeIndicator showInView:view];
}

+(void)showOverlayWithStatus:(NSString *)status options:(IGOverlayOptions)options showInView:(UIView *)view
{
    [self showOverlayWithStatus:status options:options afterDelay:MAXFLOAT showInView:view];
}

+(void)showOverlayWithStatus:(NSString *)status options:(IGOverlayOptions)options afterDelay:(NSTimeInterval)afterDelay showInView:(UIView *)view
{
    [self showOverlayWithStatus:status options:options afterDelay:afterDelay showInView:view completeBlock:nil];
}

+(void)showOverlayWithStatus:(NSString *)status options:(IGOverlayOptions)options afterDelay:(NSTimeInterval)afterDelay showInView:(UIView *)view completeBlock:(IGOverlayCompleteBlock)block
{
    [IGOverlay destoryOverlayInView:view];
    
    IGOverlay *overlay = [self overlayInView:view];
    
    overlay.completeBlock = block ? block : nil;
    
    if (status && status.length > 0 && ![status isEqualToString:@"<null>"])
    {
        overlay.status = status;
    }
    else
    {
        overlay.status = @"";
    }
    
    overlay.options = options;
    
    overlay.dismissTimeInterval = (afterDelay == 0.f) ? MAXFLOAT : afterDelay;
    
    [overlay analyze];
}

-(void)showInView:(UIView *)view
{
    if (view == nil)
    {
        NSLog(@"IGOverlay 加载的视图为nil !");
        return;
    }
    
    for (UIView *subOverlay in view.subviews)
    {
        if ([subOverlay isKindOfClass:[IGOverlay class]])
        {
            [IGOverlay destoryOverlay:(IGOverlay *)subOverlay];
            
            break;
        }
    }
    
    [view addSubview:self];
    
    IGOverlay *overlay = [IGOverlay overlayInView:view];
    
    [overlay analyze];
}

-(void) analyze
{
    [self initializeOverlay];
    
    [self handleOptions:self.options];
    
    [self initializeTimer];
}

/**
 移除视图
 */

+(void)removeOverlayInView:(UIView *)view
{
    IGOverlay *overlay;
    
    if (view == nil)
    {
        overlay = [IGOverlay sharedInstance];
    }
    else if (view != nil)
    {
        for (UIView *subOverlay in view.subviews)
        {
            if ([subOverlay isKindOfClass:[IGOverlay class]])
            {
                overlay = (IGOverlay *)subOverlay;
                
                break;
            }
        }
    }
    
    if (overlay != nil)
    {
        [overlay removeOverlay];
    }
}

+(void)removeOverlayWithStatus:(NSString *)status inView:(UIView *)view
{
    [self removeOverlayWithStatus:status options:IGOverlayOptionNone inView:view];
}

+(void)removeOverlayWithStatus:(NSString *)status options:(IGOverlayOptions)options inView:(UIView *)view
{
    [self removeOverlayWithStatus:status options:options InView:view afterDelay:2.0f completeBlock:nil];
}

+(void)removeOverlayWithStatus:(NSString *)status options:(IGOverlayOptions)options InView:(UIView *)view afterDelay:(NSTimeInterval)afterDelay completeBlock:(IGOverlayCompleteBlock)block
{
    [self showOverlayWithStatus:status options:options afterDelay:afterDelay showInView:view completeBlock:block];
}

+(void) destoryOverlayInView:(UIView *)view
{
    if (view == nil)
    {
        view = keyWindow;
    }
    
    for (UIView *subOverlay in view.subviews)
    {
        if ([subOverlay isKindOfClass:[IGOverlay class]])
        {
            [self destoryOverlay:(IGOverlay *)subOverlay];
        }
    }
}

+(void) destoryOverlay:(IGOverlay *)overlay
{
    [overlay.scheduleTimer invalidate];
    
    overlay.scheduleTimer = nil;
    
    [overlay removeFromSuperview];
    
    overlay = nil;
}

+(IGOverlay *) overlayInView:(UIView *)view
{
    IGOverlay *overlay;
    
    if (view == nil)
    {
        overlay = [IGOverlay sharedInstance];
        
        [keyWindow addSubview:overlay];
        
        if (keyWindow.frame.size.width == 0 && keyWindow.frame.size.height == 0)
        {
            overlay.frame = [UIScreen mainScreen].bounds;
        }
        else
        {
            overlay.frame = keyWindow.bounds;
        }
    }
    else if (view != nil)
    {
        for (UIView *subOverlay in view.subviews)
        {
            if ([subOverlay isKindOfClass:[IGOverlay class]])
            {
                overlay = (IGOverlay *)subOverlay;
                
                break;
            }
        }
        
        if (overlay == nil)
        {
            overlay = [[IGOverlay alloc] init];
            
            [view addSubview:overlay];
        }
        
        overlay.frame = overlay.superview.bounds;
    }
    
    return overlay;
}

-(void)removeOverlay
{
    __block IGOverlay *overlay = self;
    
    [self runExitAnimationWithCompleteBlock:^{
        
        if (overlay.completeBlock)
        {
            overlay.completeBlock();
        }
        
        [overlay removeFromSuperview];
        
        overlay = nil;
        
    }];
}

-(void)initializeTimer
{
    [self.scheduleTimer invalidate];
    
    self.scheduleTimer = nil;
    
    if (self.dismissTimeInterval > 0)
    {
        self.scheduleTimer = [NSTimer scheduledTimerWithTimeInterval:self.dismissTimeInterval target:self selector:@selector(removeOverlay) userInfo:nil repeats:NO];
    }
}

-(void)runExitAnimationWithCompleteBlock:(void (^) ())completeBlock
{
    [self.scheduleTimer invalidate];
    
    self.scheduleTimer = nil;
    
    [UIView animateWithDuration:IGDISMISS_ANIMATION_TIME animations:^{
        
        self.alpha = 0.f;
        
    } completion:^(BOOL finished) {
        
        if (finished)
        {
            if (completeBlock)
            {
                completeBlock();
            }
        }
        
    }];
}

-(void)handleOptions:(IGOverlayOptions)options
{
    [self.shapeLayer removeFromSuperlayer];
    
    if (options & IGOverlayOptionLabelHeightByText)
    {
        self.isResizeLabelByStatus = YES;
    }
    
    if (options & IGOverlayOptionsUserInteraction)
    {
        self.isUserInteraction = NO;
    }
    
    if (options & IGOverlayOptionHeaderTypeSuccess || options & IGOverlayOptionHeaderTypeError || options & IGOverlayOptionHeaderTypeWarning)
    {
        self.shapeLayer.frame = self.status.length > 0 ? [self resizeIconFrame] : [self resizeShareLayerFrame];
        
        self.isContainsHeader = YES;
        
        [self.overlay.layer addSublayer:self.shapeLayer];
    }
    
    if (options & IGOverlayOptionHeaderTypeIndicator)
    {
        [self.shapeLayer removeFromSuperlayer];
        
        self.isContainsHeader = YES;
        
        self.indicator.frame = self.status.length > 0 ? [self resizeIconFrame] : [self resizeShareLayerFrame];
        
        [self.indicator startAnimating];
    }
    else if (options & IGOverlayOptionHeaderTypeSuccess)
    {
        self.shapeLayer.path = [self bezierPathForCheckSymbolWithLayerRect:self.shapeLayer.frame andLineW:5.f].CGPath;
    }
    else if (options & IGOverlayOptionHeaderTypeError)
    {
        self.shapeLayer.path = [self bezierPathForWrongSymbolWithLayerRect:self.shapeLayer.frame andLineW:3.f].CGPath;
    }
    else if (options & IGOverlayOptionHeaderTypeWarning)
    {
        self.shapeLayer.path = [self bezierPathForWarnSymbolWithLayerRect:self.shapeLayer.frame andLineW:4.f].CGPath;
    }
    
    [self resizeOverlaySubViewFrame];
}

-(void)resizeOverlaySubViewFrame
{
    CGFloat labelHeight = [self.label sizeThatFits:CGSizeMake(IGCLIPW(IGMAX_OVERLAY_WIDTH,IGPADDING_LABEL_DISTACEN), MAXFLOAT)].height;
    
    if (self.isContainsHeader) //包含头部
    {
        if (labelHeight > 0.f) //有文字
        {
            CGFloat top = IGPADDING_ICON_TOP + IGDEFAULT_ICON_SIZE + IGPADDING_ICON_BOTTOM;
            
            if (self.isResizeLabelByStatus)
            {
                self.label.frame = CGRectMake(IGPADDING_ICON_SLIDE,
                                              top,
                                              IGCLIPW(IGMAX_OVERLAY_WIDTH, IGPADDING_LABEL_DISTACEN),
                                              labelHeight);
                
                CGFloat overlayHeight = (CGRectGetMaxY(self.label.frame) + IGPADDING_LABEL_DISTACEN);
                
                self.overlay.frame = CGRectMake([self.superview centerX:IGMAX_OVERLAY_WIDTH],
                                                [self.superview centerY:overlayHeight],
                                                IGMAX_OVERLAY_WIDTH,
                                                overlayHeight);
            }
            else
            {
                
                
                CGFloat minLabelH = IGMAX_OVERLAY_WIDTH - top - IGPADDING_LABEL_DISTACEN;
                
                self.label.frame = CGRectMake(IGPADDING_ICON_SLIDE,
                                              top,
                                              IGCLIPW(IGMAX_OVERLAY_WIDTH,IGPADDING_LABEL_DISTACEN) ,
                                              MAX(minLabelH , labelHeight));
                
                if (minLabelH < labelHeight)
                {
                    CGFloat overlayHeight = [self.label maxY] + IGPADDING_LABEL_DISTACEN;
                    
                    self.overlay.frame = CGRectMake([self.superview centerX:IGMAX_OVERLAY_WIDTH],
                                                    [self.superview centerY:overlayHeight],
                                                    IGMAX_OVERLAY_WIDTH,
                                                    overlayHeight);
                }
                else
                {
                    self.overlay.frame = [self resizeOverlayFrame];
                }
            }
        }
        else //没有文字
        {
            self.label.frame = CGRectZero;
        }
    }
    else //没有头部
    {
        if (labelHeight > 0.f) //有文字
        {
            CGFloat overlayHeight = 0;
            CGFloat labelFinalHeight = 0;
            
            if (self.isResizeLabelByStatus) //内容最小高度根据文字
            {
                labelFinalHeight = labelHeight;
                
                overlayHeight = labelHeight + 2 * IGPADDING_LABEL_DISTACEN;
            }
            else //内容最小高度不根据文字 设定一个最小值
            {
                labelFinalHeight = MAX(IGMAX_OVERLAY_WIDTH - 2 * IGPADDING_LABEL_DISTACEN, labelHeight);
                
                if (IGMAX_OVERLAY_WIDTH - 2 * IGPADDING_LABEL_DISTACEN < labelHeight)
                {
                    overlayHeight = labelHeight + IGPADDING_LABEL_DISTACEN * 2;
                }
                else
                {
                    overlayHeight = IGMAX_OVERLAY_WIDTH;
                }
            }
            
            self.label.frame = CGRectMake(IGPADDING_LABEL_DISTACEN,
                                          IGPADDING_LABEL_DISTACEN,
                                          IGCLIPW(IGMAX_OVERLAY_WIDTH, IGPADDING_ICON_SLIDE),
                                          labelFinalHeight);
            
            self.overlay.frame = CGRectMake([self.superview centerX:IGMAX_OVERLAY_WIDTH],
                                            [self.superview centerY:overlayHeight],
                                            IGMAX_OVERLAY_WIDTH,
                                            overlayHeight);
        }
        else //没有文字
        {
            self.label.frame = CGRectZero;
        }
    }
    
    if (self.isUserInteraction)
    {
        self.frame = self.overlay.frame;
        self.overlay.frame = self.bounds;
    }
    else
    {
        if ([self.superview isKindOfClass:[UIWindow class]])
        {
            self.frame = keyWindow.bounds;
        }
        else
        {
            self.frame = self.superview.bounds;
        }
    }
}

-(CGRect)resizeOverlayFrame
{
    return CGRectMake([self.superview centerX:IGMAX_OVERLAY_WIDTH],
                      [self.superview centerY:IGMAX_OVERLAY_WIDTH],
                      IGMAX_OVERLAY_WIDTH,
                      IGMAX_OVERLAY_WIDTH);
}

-(CGRect)resizeIconFrame
{
    return CGRectMake(IGCENTERX(IGMAX_OVERLAY_WIDTH,IGDEFAULT_ICON_SIZE),
                      IGPADDING_ICON_TOP,
                      IGDEFAULT_ICON_SIZE,
                      IGDEFAULT_ICON_SIZE);
}

-(CGRect)resizeShareLayerFrame
{
    return CGRectMake(IGCENTERX(IGMAX_OVERLAY_WIDTH,IGDEFAULT_ICON_SIZE),
                      IGCENTERX(IGMAX_OVERLAY_WIDTH,IGDEFAULT_ICON_SIZE),
                      IGDEFAULT_ICON_SIZE,
                      IGDEFAULT_ICON_SIZE);
}

-(UIBezierPath *)bezierPathForCheckSymbolWithLayerRect:(CGRect)layerRect andLineW:(CGFloat)lineW
{
    CGSize symbolSize = CGSizeMake(22, 28);
    
    CGFloat oriX = (layerRect.size.width - symbolSize.width) / 2;
    CGFloat oriY = (layerRect.size.height - symbolSize.height) / 2;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    [bezierPath moveToPoint:CGPointMake(oriX, oriY + 16)];
    [bezierPath addLineToPoint:CGPointMake(oriX + 7, oriY + 23)];
    [bezierPath addLineToPoint:CGPointMake(oriX + 21, oriY + 9)];
    [bezierPath addLineToPoint:CGPointMake(oriX + 21 - lineW / 2, oriY + 9 - lineW / 2)];
    [bezierPath addLineToPoint:CGPointMake(oriX + 7, oriY + 23 - lineW)];
    [bezierPath addLineToPoint:CGPointMake(oriX + lineW / 2, oriY + 16 - lineW / 2)];
    [bezierPath closePath];
    
    return bezierPath;
}

-(UIBezierPath *)bezierPathForWrongSymbolWithLayerRect:(CGRect)layerRect andLineW:(CGFloat)lineW
{
    CGSize symbolSize = CGSizeMake(20, 20);
    
    CGFloat oriX = (layerRect.size.width - symbolSize.width) / 2;
    CGFloat oriY = (layerRect.size.height - symbolSize.height) / 2;
    
    CGFloat marginX = lineW / sqrt(2.0);
    CGFloat marginY = marginX;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    [bezierPath moveToPoint:CGPointMake(oriX, oriY + marginY)];
    [bezierPath addLineToPoint:CGPointMake(oriX + marginX, oriY)];
    [bezierPath addLineToPoint:CGPointMake(oriX + symbolSize.width / 2, oriY + symbolSize.height / 2 - marginY)];
    [bezierPath addLineToPoint:CGPointMake(oriX + symbolSize.width - marginX, oriY)];
    [bezierPath addLineToPoint:CGPointMake(oriX + symbolSize.width, oriY + marginY)];
    [bezierPath addLineToPoint:CGPointMake(oriX + symbolSize.width / 2 + marginX, oriY + symbolSize.height / 2)];
    [bezierPath addLineToPoint:CGPointMake(oriX + symbolSize.width, oriY + symbolSize.height - marginY)];
    [bezierPath addLineToPoint:CGPointMake(oriX + symbolSize.width - marginX, oriY + symbolSize.height)];
    [bezierPath addLineToPoint:CGPointMake(oriX + symbolSize.width / 2, oriY + symbolSize.height / 2 + marginY)];
    [bezierPath addLineToPoint:CGPointMake(oriX + marginX, oriY + symbolSize.height)];
    [bezierPath addLineToPoint:CGPointMake(oriX, oriY + symbolSize.height - marginY)];
    [bezierPath addLineToPoint:CGPointMake(oriX + symbolSize.width / 2 - marginX, oriY + symbolSize.height / 2)];
    [bezierPath closePath];
    
    return bezierPath;
}

-(UIBezierPath *)bezierPathForWarnSymbolWithLayerRect:(CGRect)layerRect andLineW:(CGFloat)lineW
{
    CGSize symbolSize = CGSizeMake(25, 30);
    
    CGFloat oriX = (layerRect.size.width - symbolSize.width) / 2;
    CGFloat oriY = (layerRect.size.height - symbolSize.height) / 2;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    [bezierPath moveToPoint:CGPointMake(oriX + symbolSize.width / 2, oriY)];
    [bezierPath addArcWithCenter:CGPointMake(oriX + symbolSize.width / 2, oriY + 6) radius:lineW - 1.f startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    [bezierPath moveToPoint:CGPointMake(oriX + symbolSize.width / 2 - lineW / 2, oriY + 13)];
    [bezierPath addLineToPoint:CGPointMake(oriX + symbolSize.width / 2 + lineW / 2, oriY + 13)];
    [bezierPath addLineToPoint:CGPointMake(oriX + symbolSize.width / 2 + lineW / 2, oriY + 13 + 13)];
    [bezierPath addLineToPoint:CGPointMake(oriX + symbolSize.width / 2 - lineW / 2, oriY + 13 + 13)];
    [bezierPath closePath];
    
    return bezierPath;
}

@end
