//
//  RadarView.h
//  RadarView
//
//  Created by 张思槐 on 2019/1/14.
//  Copyright © 2019 张思槐. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RadarView : UIView

/**
 value的值在0.0-1.0之间，至少三个值
 */
@property (nonatomic, copy) NSArray <NSNumber *> *values;

/**
 雷达图一共有几段，默认为5
 */
@property (nonatomic, assign) NSInteger regionCount;


/**
 @param outLineColor 外边框颜色
 @param shadowColor 阴影颜色
 @param innerColor1 渐变起始颜色
 @param innerColor2 渐变结束颜色
 */
- (void)setOutLineColor:(UIColor *)outLineColor
            shadowColor:(UIColor *)shadowColor
        beginInnerColor:(UIColor *)innerColor1
          endInnerColor:(UIColor *)innerColor2;


@end

NS_ASSUME_NONNULL_END
