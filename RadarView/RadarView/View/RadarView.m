//
//  RadarView.m
//  RadarView
//
//  Created by 张思槐 on 2019/1/14.
//  Copyright © 2019 张思槐. All rights reserved.
//

#import "RadarView.h"

static const NSInteger kDefaultRegionCount = 5;

@interface RadarView ()

@property (nonatomic, strong) UIColor *outLineColor;

@property (nonatomic, strong) UIColor *shadowColor;

@property (nonatomic, copy) NSArray <UIColor *> *gradientColors;

@end

@implementation RadarView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setRegionCount:kDefaultRegionCount];
        
        _outLineColor = [UIColor blackColor];
        
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGFloat padding = 10;
    
    CGFloat radius = MIN(rect.size.width, rect.size.height) / 2;
    radius -= padding;
    
    [self _drawRadarBackgroundWithRadius:radius];
    
    [self _drawRadarContentWithRadius:radius];
    
}

- (void)setValues:(NSArray<NSNumber *> *)values {
    NSParameterAssert(values.count >= 3);
    _values = values.copy;
    [self setNeedsDisplay];
}

- (void)setRegionCount:(NSInteger)regionCount {
    NSParameterAssert(regionCount > 0);
    _regionCount = regionCount;
    [self setNeedsDisplay];
}

- (void)setOutLineColor:(UIColor *)outLineColor shadowColor:(UIColor *)shadowColor beginInnerColor:(UIColor *)innerColor1 endInnerColor:(UIColor *)innerColor2 {
    
    _outLineColor = outLineColor ?: [UIColor blackColor];
    
    _shadowColor = shadowColor ?: [UIColor lightGrayColor];
    
    NSMutableArray *gradientColors = @[].mutableCopy;
    if (innerColor1) {
        [gradientColors addObject:innerColor1];
    }
    
    if (innerColor2) {
        [gradientColors addObject:innerColor2];
    }
    
    _gradientColors = [gradientColors copy];
    
    [self setNeedsDisplay];
}

- (void)_drawRadarBackgroundWithRadius:(CGFloat)radius {
    NSParameterAssert(radius > FLT_EPSILON);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) { return; }
    
    CGFloat diameter = radius * 2;
    
    CGSize boundsSize = self.bounds.size;
    CGFloat regionLength = diameter / _regionCount;
    
    [[UIColor lightGrayColor] setStroke];
    
    for (NSInteger i = 0; i < _regionCount; i ++ ) {
        
        CGFloat _radius = diameter - i * regionLength;
        CGFloat x = (boundsSize.width - _radius) / 2;
        CGFloat y = (boundsSize.height - _radius) / 2;
        CGRect targetRect = CGRectMake(x, y, _radius, _radius);
        
        if (i == 0) {
            // 最外层实线
            UIBezierPath *linePath = [UIBezierPath bezierPathWithOvalInRect:targetRect];
            [linePath stroke];
            continue;
        }
        
        UIBezierPath *dashLinePath = [UIBezierPath bezierPathWithOvalInRect:targetRect];
        CGFloat dash[] = {5.0, 3.0};
        [dashLinePath setLineDash:dash count:2 phase:0];
        [dashLinePath stroke];
    }
    
}

- (void)_drawRadarContentWithRadius:(CGFloat)radius {
    NSParameterAssert(radius > FLT_EPSILON);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) { return; }
    
    NSUInteger valuesCount = _values.count;
    CGFloat degree = (M_PI * 2) / valuesCount;
    
    CGContextSaveGState(context);
    
    CGPoint center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    CGContextTranslateCTM(context, center.x, center.y);
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    
    __block CGFloat minY = CGFLOAT_MAX;
    __block CGFloat maxY = 0;
    
    __block CGFloat angle = 0;
    
    [_values enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat _radius = obj.floatValue * radius;
        
        angle = degree * idx;
        CGFloat x = _radius * cos(angle);
        CGFloat y = _radius * sin(angle);
        CGPoint point = CGPointMake(x, y);
        
        if (y < minY) {
            minY = y;
        }
        
        if (y >= maxY) {
            maxY = y;
        }
        
        if (idx == 0) {
            [bezierPath moveToPoint:point];
        } else {
            [bezierPath addLineToPoint:point];
        }
        
    }];
    
    [bezierPath closePath];
    
    [_outLineColor setStroke];
    [bezierPath stroke];
    
    CGPoint fromPoint = CGPointMake(0, minY);
    CGPoint toPoint = CGPointMake(0, maxY);

    [self _drawGradientInPath:bezierPath fromPoint:fromPoint toPoint:toPoint];
    
    [self _drawShadowInPath:bezierPath];
    
    CGContextRestoreGState(context);
    
}

- (void)_drawGradientInPath:(UIBezierPath *)path fromPoint:(CGPoint)fromPoint toPoint:(CGPoint)toPoint {
    NSParameterAssert(path != nil);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) { return; }
    
    if (_gradientColors.count == 0) {
        [[UIColor whiteColor] setFill];
        [path fill];
        return;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (!colorSpace) { return; }
    
    CGFloat locations[] = {0.0, 1.0};
    
    NSMutableArray *gradientColors = [NSMutableArray arrayWithCapacity:2];
    for (UIColor *color in _gradientColors) {
        [gradientColors addObject:(id)color.CGColor];
    }
    
    CGGradientRef gradientRef = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, locations);
    CFRelease(colorSpace);
    
    if (!gradientRef) { return; }
    
    CGContextSaveGState(context);
    
    [path addClip];
    
    CGContextDrawLinearGradient(context, gradientRef, fromPoint, toPoint, kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation);
    
    CGContextRestoreGState(context);
}

- (void)_drawShadowInPath:(UIBezierPath *)path{
    NSParameterAssert(path != nil);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) { return; }
    
    CGContextSaveGState(context);
    
    CGContextSetBlendMode(context, kCGBlendModeMultiply);
    
    UIBezierPath *inversePath = [UIBezierPath bezierPath];
    [inversePath appendPath:path];
    [inversePath appendPath:[UIBezierPath bezierPathWithRect:CGRectInfinite]];
    inversePath.usesEvenOddFillRule = YES;
    
    [inversePath addClip];
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, 8), 8, _shadowColor.CGColor);
    [[UIColor whiteColor] setFill];
    [path fill];

    CGContextRestoreGState(context);
    
}



@end
