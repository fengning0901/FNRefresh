//
//  XER_ActivityIndicatorView.m
//  XER
//
//  Created by 冯宁 on 12/26/15.
//  Copyright © 2015 xfenzi. All rights reserved.
//

#import "FNActivityIndicatorView.h"
#import "FNEasingKeyFrame.h"
#import "UIColor+FNAdd.h"

@interface FNActivityIndicatorView ()
@property (nonatomic, strong) NSTimer* timer;
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, strong) CADisplayLink* displayLink;
@property (nonatomic, assign) unsigned long nowIndex;
@property (nonatomic, assign) unsigned long rotateNowIndex;
@end

@implementation FNActivityIndicatorView
#define screenRate ([UIScreen mainScreen].bounds.size.width  / 375.0)
#define animationLength 30
#define rotateAnimateLength 60
static NSArray<NSNumber*>* scaleArray;
static NSArray<NSNumber*>* rotateArray;

+ (void)initialize{
    if (self == [FNActivityIndicatorView class]) {
        NSMutableArray* mArray = [NSMutableArray array];
        for (int i = 0; i < animationLength; i++) {
            if (i < animationLength / 2) {
                [mArray addObject:[NSNumber numberWithFloat:[FNEasingKeyFrame singleKeyFrameForAnimationType:FNEasingKeyFrameAnimationTypeCubicEaseInOut withProgressRate:(float)i / (float)(animationLength / 2)] * (1.0 / 3.0) + (2.0 / 3.0)]];
            }else{
                [mArray addObject:[NSNumber numberWithFloat:[FNEasingKeyFrame singleKeyFrameForAnimationType:FNEasingKeyFrameAnimationTypeCubicEaseInOut withProgressRate:1.0 - ((float)i - ((float)animationLength / 2.0)) / (float)(animationLength / 2)] * (1.0 / 3.0) + (2.0 / 3.0)]];
            }
        }
        scaleArray = mArray.copy;
        mArray = [NSMutableArray array];
        for (int i = 0; i < rotateAnimateLength; i++) {
            [mArray addObject:[NSNumber numberWithDouble:(double)M_PI * 2.0 / 60.0 * i]];
        }
        rotateArray = mArray.copy;
    }
}

- (instancetype)init{
    if (self = [super init]) {
        self.animating = NO;
        self.backgroundColor = [UIColor clearColor];
        self.animateType = XER_ActivityIndicatorViewTypeScaleAnimate;
    }
    return self;
}

- (void)setAnimateType:(XER_ActivityIndicatorViewType)animateType{
    _animateType = animateType;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect{
    if (self.animateType == XER_ActivityIndicatorViewTypeScaleAnimate) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextAddArc(ctx, self.bounds.size.width / 2.0, self.bounds.size.height / 2.0, self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height / 2.0 : self.bounds.size.width / 2.0, 0, M_PI * 2.0, YES);
        CGContextSetFillColorWithColor(ctx, _color ? _color.CGColor : [UIColor colorWithHexValue:@"E8E8E8"].CGColor);
        CGContextFillPath(ctx);
    }else{
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextAddArc(ctx, self.bounds.size.width / 2.0, self.bounds.size.height / 2.0, self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height / 2.0 - 2.0 : self.bounds.size.width / 2.0 - 2.0, 0 + rotateArray[_rotateNowIndex].doubleValue, M_PI * 1.5 + rotateArray[_rotateNowIndex].doubleValue, NO);
        CGContextSetStrokeColorWithColor(ctx,_color ? _color.CGColor : [UIColor colorWithHexValue:@"E8E8E8"].CGColor);
        CGContextSetLineWidth(ctx, 1.0);
        CGContextStrokePath(ctx);
    }
}

- (CGSize)sizeThatFits:(CGSize)size{
    return CGSizeMake(22.5*screenRate, 22.5*screenRate);
}

- (void)startAnimating{
    self.animating = YES;
    [self addTimer];
}

- (void)stopAnimating{
    self.animating = NO;
    if (self.displayLink) {
        [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [self.displayLink invalidate];
        self.displayLink = nil;
    }
}

- (BOOL)isAnimating{
    return self.animating;
}

- (void)addTimer {
    if (!self.displayLink) {
        self.nowIndex = 0;
        self.rotateNowIndex = 0;
        if (self.animateType == XER_ActivityIndicatorViewTypeScaleAnimate) {
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(scaleAnimate)];
        }else{
            self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(rotateAnimate)];
        }
        self.displayLink.preferredFramesPerSecond = 30;
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)scaleAnimate{
    if (self.window && CGRectIntersectsRect(self.window.frame, [self convertRect:self.bounds toView:self.window])  && self.animating) {
        self.nowIndex = self.nowIndex + 1;
    }
}

- (void)rotateAnimate{
    if (self.window && CGRectIntersectsRect(self.window.frame, [self convertRect:self.bounds toView:self.window])  && self.animating) {
        self.rotateNowIndex = self.rotateNowIndex + 1;
    }
}

- (void)setRotateNowIndex:(unsigned long)rotateNowIndex{
    if (rotateNowIndex >= rotateAnimateLength) {
        _rotateNowIndex = 0;
    }else{
        _rotateNowIndex = rotateNowIndex;
    }
    [self setNeedsDisplay];
}

- (void)setNowIndex:(unsigned long)nowIndex{
    if (nowIndex >= animationLength) {
        _nowIndex = 0;
    }else{
        _nowIndex = nowIndex;
    }
    self.transform = CGAffineTransformMake(scaleArray[_nowIndex].floatValue, 0, 0, scaleArray[_nowIndex].floatValue, 0, 0);
}


@end
