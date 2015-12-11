//
//  YBOverlay.h
//  xiangdemei
//
//  Created by iGalactus on 15/12/3.
//  Copyright © 2015年 一斌. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ IGOverlayCompleteBlock) ();


@interface IGOverlay : UIView

typedef NS_OPTIONS(NSInteger, IGOverlayOptions)
{
    IGOverlayOptionNone                = 1 << 0,
    
    IGOverlayOptionHeaderTypeWarning   = 1 << 1,
    IGOverlayOptionHeaderTypeError     = 1 << 2,
    IGOverlayOptionHeaderTypeSuccess   = 1 << 3,
    IGOverlayOptionHeaderTypeIndicator = 1 << 4,

    IGOverlayOptionLabelHeightByText   = 1 << 5,
    
    IGOverlayOptionsUserInteraction    = 1 << 6, //禁止用户点击
};

/**
 加载在特定的View上
 @prama afterDelay 延迟消失时间 没有改选项则说明时间为无限大
 */

+(void) showOverlayWithIndicatorInView:(UIView *)view;

+(void) showOverlayWithIndicatorWithStatus:(NSString *)status showInView:(UIView *)view;

/**
 该方法只会显示文字 并且两秒钟后消失
 */
+(void) showOverlayWithStatus:(NSString *)status showInView:(UIView *)view;

+(void) showOverlayWithStatus:(NSString *)status options:(IGOverlayOptions)options showInView:(UIView *)view;

+(void) showOverlayWithStatus:(NSString *)status options:(IGOverlayOptions)options afterDelay:(NSTimeInterval)afterDelay showInView:(UIView *)view;

+(void) showOverlayWithStatus:(NSString *)status options:(IGOverlayOptions)options afterDelay:(NSTimeInterval)afterDelay showInView:(UIView *)view completeBlock:(IGOverlayCompleteBlock)block;

+(void) removeOverlayInView:(UIView *)view;

+(void) removeOverlayWithStatus:(NSString *)status inView:(UIView *)view;

+(void) removeOverlayWithStatus:(NSString *)status options:(IGOverlayOptions)options inView:(UIView *)view;

+(void) removeOverlayWithStatus:(NSString *)status options:(IGOverlayOptions)options InView:(UIView *)view afterDelay:(NSTimeInterval)afterDelay completeBlock:(IGOverlayCompleteBlock)block;

/**
 实例方法
 */
-(void) showInView:(UIView *)view;

-(void) removeOverlay;



/**
 *  显示的文字
 */
@property (nonatomic,copy) NSString *status;

/**
 *  选择的类型
 */
@property (nonatomic) IGOverlayOptions options;

/**
 *  消失的时间
 */
@property (nonatomic) NSTimeInterval dismissTimeInterval;

/**
 *  头部的颜色
 */
@property (nonatomic,strong) UIColor *shapeLayerColor;

/**
 *  字体的颜色
 */
@property (nonatomic,strong) UIColor *overlayTextColor;

/**
 *  字体的大小
 */
@property (nonatomic,strong) UIFont *overlayTextFont;

/**
 *  结束的回调
 */
@property (nonatomic,copy) IGOverlayCompleteBlock completeBlock;

@end
