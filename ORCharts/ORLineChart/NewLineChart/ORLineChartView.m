//
//  ORLineChartView.m
//  ORChartView
//
//  Created by OrangesAL on 2019/5/1.
//  Copyright © 2019年 OrangesAL. All rights reserved.
//

#import "ORLineChartView.h"
#import "ORLineChartCell.h"
#import "ORChartUtilities.h"

@implementation NSObject (ORLineChartView)

- (NSInteger)numberOfVerticalLinesOfChartView:(ORLineChartView *)chartView {return 5;};

- (id)chartView:(ORLineChartView *)chartView titleForHorizontalAtIndex:(NSInteger)index {return nil;};

- (NSDictionary<NSAttributedStringKey,id> *)labelAttrbutesForHorizontalOfChartView:(ORLineChartView *)chartView {
    return @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
}
- (NSDictionary<NSAttributedStringKey,id> *)labelAttrbutesForVerticalOfChartView:(ORLineChartView *)chartView {
    return @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
}

- (NSAttributedString *)chartView:(ORLineChartView *)chartView attributedStringForIndicaterAtIndex:(NSInteger)index {return nil;}

@end

#pragma mark - ORLineChartHorizontal
@interface ORLineChartHorizontal : NSObject

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, copy) NSAttributedString *title;

@end

@interface ORLineChartValue : NSObject

@property (nonatomic, assign, readonly) CGFloat max;
@property (nonatomic, assign, readonly) CGFloat min;
@property (nonatomic, assign, readonly) CGFloat middle;
@property (nonatomic, copy, readonly) NSArray <NSNumber *>* separatedValues;//等分值 由低到高
@property (nonatomic, copy) NSArray <NSNumber *>* ramValues;

- (instancetype)initWithData:(NSArray<NSNumber *> *)values numberWithSeparate:(NSInteger)separate customMin:(CGFloat)min;
- (instancetype)initWithData:(NSArray<NSNumber *> *)values numberWithSeparate:(NSInteger)separate;
- (instancetype)initWithHorizontalData:(NSArray<ORLineChartHorizontal *> *)horizontals numberWithSeparate:(NSInteger)separate;

@end

@implementation ORLineChartHorizontal
@end

#pragma mark - ORLineChartValue
@implementation ORLineChartValue {
    NSInteger _separate;
}

- (instancetype)initWithData:(NSArray<NSNumber *> *)values numberWithSeparate:(NSInteger)separate customMin:(CGFloat)min
{
    self = [super init];
    if (self) {
        _separate = separate;
        _min = min;
        self.ramValues = values;
    }
    return self;
}

- (instancetype)initWithData:(NSArray<NSNumber *> *)values numberWithSeparate:(NSInteger)separate {
    return  [self initWithData:values numberWithSeparate:separate customMin:CGFLOAT_MAX];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _separate = 5;
    }
    return self;
}

- (void)setRamValues:(NSArray<NSNumber *> *)ramValues {
    _ramValues = ramValues;
    [self valueSortedWithRamData:ramValues numberWithSeparate:_separate];
}

- (void)valueSortedWithRamData:(NSArray <NSNumber *> *)data numberWithSeparate:(NSInteger)separate {
    
    __block CGFloat max = [data.firstObject floatValue];
    __block CGFloat min = [data.firstObject floatValue];
    
    [data enumerateObjectsUsingBlock:^(NSNumber *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.doubleValue > max) {
            max = obj.doubleValue;
        }
        if (obj.doubleValue < min) {
            min = obj.floatValue;
        }
    }];
    
    _middle = (max - min) / 2.0;
    
    NSMutableArray *array = [NSMutableArray array];
    NSInteger average = 0;
    
    if (min > 0 && max > 10) {
        
        min = floorf(min / 10.0) * 10;
        max = ceilf(max / 10.0) * 10;
        average = ceilf((max - min) / (separate - 1.0));
    }else {
        average = (max - min) / (separate - 2.0);
        if (average - (int)average > 0.5) {
            average += 1;
        }
    }
    
    for (int i = 0; i < separate; i ++) {
        [array addObject:@(min + i * (int)average)];
    }
    
    _min = min;
    _max = [array.lastObject floatValue];
    _separatedValues = [array copy];
}

- (instancetype)initWithHorizontalData:(NSArray<ORLineChartHorizontal *> *)horizontals numberWithSeparate:(NSInteger)separate {
    
    NSMutableArray *number = [NSMutableArray arrayWithCapacity:horizontals.count];
    [horizontals enumerateObjectsUsingBlock:^(ORLineChartHorizontal * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [number addObject:@(obj.value)];
    }];
    return [self initWithData:number numberWithSeparate:separate];
}

@end

#pragma mark - ORIndicatorView
@interface ORIndicatorView : UIView
@end

@implementation ORIndicatorView {
    UILabel *_label;
    CAShapeLayer *_backLayer;
    CALayer *_shadowLayer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _or_initailizeUI];
    }
    return self;
}

- (void)_or_initailizeUI{
    _label = ({
        UILabel *label = [UILabel new];
        label;
    });
    [self addSubview:_label];

    
    _backLayer = ({
        CAShapeLayer *layer = [CAShapeLayer new];
        layer.fillColor = [UIColor redColor].CGColor;
        layer;
    });
    
    [self.layer insertSublayer:_backLayer atIndex:0];
    
    _shadowLayer = ({
        CALayer *layer = [CALayer new];
        layer;
    });
    [self.layer insertSublayer:_shadowLayer atIndex:0];
}

- (void)or_setTitle:(NSAttributedString *)title {
    _label.attributedText = title;
    [_label sizeToFit];
    CGFloat width = _label.bounds.size.width + 10;
    CGFloat height = _label.bounds.size.height + 10;
    self.bounds = CGRectMake(0, 0, width, height);
    _label.center = CGPointMake(width / 2.0, (height - 3.78) / 2.0);
    
    _backLayer.path = ({
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, width, height - 3.78) cornerRadius:3];
        UIBezierPath *anglePath = [UIBezierPath bezierPath];
        [anglePath moveToPoint:CGPointMake(width / 2.0f, height)];
        [anglePath addLineToPoint:CGPointMake(width / 2.0 - 3.5, height - 3.78)];
        [anglePath addLineToPoint:CGPointMake(width / 2.0 + 3.5, height - 3.78)];
        [anglePath addLineToPoint:CGPointMake(width / 2.0f, height)];
        [path appendPath:anglePath];
        path.CGPath;
    });
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    _backLayer.fillColor = backgroundColor.CGColor;
}

@end

#pragma mark - ORLineChartView
@interface ORLineChartView ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource> {
    NSInteger _lastIndex;
}

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray <UILabel *>*leftLabels;

@property (nonatomic, strong) NSMutableArray <ORLineChartHorizontal *>*horizontalDatas;

@property (nonatomic, strong) ORLineChartConfig *config;
@property (nonatomic, strong) ORLineChartValue *lineChartValue;
@property (nonatomic, strong) CAShapeLayer *bottomLineLayer;
@property (nonatomic, strong) CAShapeLayer *bgLineLayer;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAShapeLayer *closeLayer;

@property (nonatomic, strong) CAShapeLayer *lineLayer;
@property (nonatomic, strong) CAShapeLayer *shadowLineLayer;

@property (nonatomic, strong) CAShapeLayer *circleLayer;

@property (nonatomic, strong) CALayer *animationLayer;
@property (nonatomic, strong) ORIndicatorView *indicator;
@property (nonatomic, strong) CALayer *indicatorLineLayer;

@property (nonatomic, strong) CALayer *contenLayer;

@property (nonatomic, assign) CGFloat bottomTextHeight;

@end

@implementation ORLineChartView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _or_initData];
        [self _or_initUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _or_initData];
        [self _or_initUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self _or_layoutSubviews];
}

- (void)_or_initUI {
    
    self.backgroundColor = [UIColor whiteColor];
    
    _collectionView = ({
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.scrollsToTop = NO;
        [collectionView registerClass:[ORLineChartCell class] forCellWithReuseIdentifier:NSStringFromClass([ORLineChartCell class])];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView;
    });
    [self addSubview:_collectionView];
    
    _bgLineLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_bgLineLayer];
    
    _bottomLineLayer = [CAShapeLayer layer];
    [self.layer addSublayer:_bottomLineLayer];
    
    
    
    _gradientLayer = ({
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(0, 1);
        gradientLayer.masksToBounds = YES;
        gradientLayer.locations = @[@(0.5f)];
        gradientLayer;
    });
//    [_collectionView.layer addSublayer:_gradientLayer];
    
    _closeLayer = [ORChartUtilities or_shapelayerWithLineWidth:1 strokeColor:nil];
    _closeLayer.fillColor = [UIColor blueColor].CGColor;

//    _gradientLayer.mask = _closeLayer;
    
    CALayer *baseLayer = [CALayer layer];
    [baseLayer addSublayer:_gradientLayer];
    [baseLayer setMask:_closeLayer];
    _contenLayer = baseLayer;
    [_collectionView.layer addSublayer:baseLayer];

    
    
    _lineLayer = [ORChartUtilities or_shapelayerWithLineWidth:1 strokeColor:nil];
    [_collectionView.layer addSublayer:_lineLayer];
    
    _shadowLineLayer = [ORChartUtilities or_shapelayerWithLineWidth:1 strokeColor:nil];
    [_collectionView.layer addSublayer:_shadowLineLayer];
    
    _indicatorLineLayer = ({
        CALayer *layer = [CALayer layer];
        layer;
    });
    
    [_collectionView.layer addSublayer:_indicatorLineLayer];

    
    _circleLayer = ({
        CAShapeLayer *layer = [ORChartUtilities or_shapelayerWithLineWidth:1 strokeColor:nil];
        layer.fillColor = self.backgroundColor.CGColor;
        layer.speed = 0.0f;
        layer;
    });
    [_collectionView.layer addSublayer:_circleLayer];
    
    
    _animationLayer = ({
        CALayer *layer = [CALayer new];
        layer.backgroundColor = [UIColor clearColor].CGColor;
        layer.speed = 0.0f;
        layer;
    });
    [_collectionView.layer addSublayer:_animationLayer];
    
    _indicator = [ORIndicatorView new];;
    [_collectionView addSubview:_indicator];

}

- (void)_or_initData {
    
    _leftLabels = [NSMutableArray array];
    _horizontalDatas = [NSMutableArray array];
    _config = [ORLineChartConfig new];
}

- (void)_or_configChart {
    
    _lineLayer.strokeColor = _config.chartLineColor.CGColor;
    _shadowLineLayer.strokeColor = _config.shadowLineColor.CGColor;
    _lineLayer.lineWidth = _config.chartLineWidth;
    _shadowLineLayer.lineWidth = _config.chartLineWidth * 0.8;
    
    
    _circleLayer.frame = (CGRect){{0,0},{_config.indicatorCircleWidth,_config.indicatorCircleWidth}};
    _circleLayer.path = [UIBezierPath bezierPathWithOvalInRect:_circleLayer.frame].CGPath;
    _circleLayer.lineWidth = _config.chartLineWidth;
    _circleLayer.strokeColor = _config.chartLineColor.CGColor;
    
    _gradientLayer.colors = _config.gradientCGColors;
    
    _bgLineLayer.strokeColor = _config.bgLineColor.CGColor;
    _bgLineLayer.lineDashPattern = @[@(1.5), @(_config.dottedBGLine ? 3 : 0)];
    _bgLineLayer.lineWidth = _config.bglineWidth;
    
    _bgLineLayer.hidden = !_config.showHorizontalBgline;
    
    _bottomLineLayer.strokeColor = _config.bgLineColor.CGColor;
    _bottomLineLayer.lineWidth = _config.bglineWidth;
    
    if (self.horizontalDatas.count > 0) {
        _bottomTextHeight = [self.horizontalDatas.firstObject.title boundingRectWithSize:CGSizeMake(_config.bottomLabelWidth, CGFLOAT_MAX) options:NSStringDrawingUsesFontLeading context:nil].size.height + _config.bottomLabelInset;
    }
    
    _indicator.backgroundColor = _config.indicatorTintColor;
    _indicatorLineLayer.backgroundColor = _config.indicatorLineColor.CGColor;

    [self.collectionView reloadData];
    [self setNeedsLayout];
}

- (void)_or_layoutSubviews {
    
    if (self.horizontalDatas.count == 0) {
        return;
    }
    
    _circleLayer.fillColor = self.backgroundColor.CGColor;
    
    self.collectionView.frame = CGRectMake(_config.leftWidth,
                                           _config.topInset,
                                           self.bounds.size.width - _config.leftWidth,
                                           self.bounds.size.height - _config.topInset - _config.bottomInset);
    
    
    
    _gradientLayer.frame = CGRectMake(0, 0, 0, self.collectionView.bounds.size.height);
    
    CGFloat indecaterHeight = _indicator.bounds.size.height;

    
    CGFloat topHeight = indecaterHeight * 2;
    
    CGFloat height = self.collectionView.bounds.size.height;
    
    CGFloat labelHeight = (height - topHeight - _bottomTextHeight) / (self.leftLabels.count - 1);
    
    CGFloat labelInset = 0;
    
    
    if (self.leftLabels.count > 0) {
        
        [self.leftLabels.firstObject sizeToFit];
        labelInset = labelHeight - self.leftLabels.firstObject.bounds.size.height;
        labelHeight =  self.leftLabels.firstObject.bounds.size.height;
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [self.leftLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        obj.frame = CGRectMake(0, self.bounds.size.height - self.bottomTextHeight - self.config.bottomInset - labelHeight * 0.5   - (labelHeight + labelInset) * idx, self.config.leftWidth, labelHeight);
        
        if (idx > 0) {
            [path moveToPoint:CGPointMake(self.config.leftWidth, obj.center.y)];
            [path addLineToPoint:CGPointMake(self.bounds.size.width, obj.center.y)];
        }else {
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(self.config.leftWidth, obj.center.y)];
            [path addLineToPoint:CGPointMake(self.bounds.size.width, obj.center.y)];
            self.bottomLineLayer.path = path.CGPath;
        }
    }];
    
    _bgLineLayer.path = path.CGPath;
    
    CGFloat ratio = (self.lineChartValue.max == self.lineChartValue.min) ? (float)1 :(CGFloat)(self.lineChartValue.min - self.lineChartValue.max);

    NSMutableArray *points = [NSMutableArray array];
    
    CGFloat maxX = _config.bottomLabelWidth * _horizontalDatas.count + _collectionView.contentInset.right;
    
    [self.horizontalDatas enumerateObjectsUsingBlock:^(ORLineChartHorizontal * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        

        CGFloat y = ORInterpolation(topHeight, height - self.bottomTextHeight, (obj.value - self.lineChartValue.max) / ratio);
        
        if (idx == 0) {
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(-self.collectionView.contentInset.left, y)]];
        }
        
        [points addObject:[NSValue valueWithCGPoint:CGPointMake(self.config.bottomLabelWidth * 0.5 + idx * self.config.bottomLabelWidth, y)]];
        
        if (idx == self.horizontalDatas.count - 1) {
            [points addObject:[NSValue valueWithCGPoint:CGPointMake(maxX, y)]];
        }
    }];
    
    BOOL isCurve = !self.config.isBreakLine;
    
    UIBezierPath *linePath = [ORChartUtilities or_pathWithPoints:points isCurve:isCurve];
    _lineLayer.path = [linePath.copy CGPath];
    
    [linePath applyTransform:CGAffineTransformMakeTranslation(0, 8)];
    _shadowLineLayer.path = [linePath.copy CGPath];
    
    _closeLayer.path = [ORChartUtilities or_closePathWithPoints:points isCurve:isCurve maxY: height - self.bottomTextHeight].CGPath;
    
    
    [points removeLastObject];
    [points removeObjectAtIndex:0];
    UIBezierPath *ainmationPath = [ORChartUtilities or_pathWithPoints:points isCurve:isCurve];
    
    [_circleLayer removeAnimationForKey:@"or_circleMove"];
    [_circleLayer addAnimation:[self _or_positionAnimationWithPath:[ainmationPath.copy CGPath]] forKey:@"or_circleMove"];
    
//    CGFloat indecaterHeight = _indicator.bounds.size.height;
    _animationLayer.timeOffset = 0.0;
    [ainmationPath applyTransform:CGAffineTransformMakeTranslation(0, - indecaterHeight)];
    [_animationLayer removeAnimationForKey:@"or_circleMove"];
    [_animationLayer addAnimation:[self _or_positionAnimationWithPath:ainmationPath.CGPath] forKey:@"or_circleMove"];

    CGPoint fistValue = [points.firstObject CGPointValue];
    _indicator.center = CGPointMake(fistValue.x, fistValue.y - indecaterHeight);
    [self _or_updateIndcaterLineFrame];

    
    if (_config.animateDuration > 0) {
        [_lineLayer addAnimation:[ORChartUtilities or_strokeAnimationWithDurantion:_config.animateDuration] forKey:nil];
        [_shadowLineLayer addAnimation:[ORChartUtilities or_strokeAnimationWithDurantion:_config.animateDuration] forKey:nil];
        
        //    _gradientLayer.anchorPoint = CGPointMake(0, 0.5);
        CABasicAnimation *anmi1 = [CABasicAnimation animation];
        anmi1.keyPath = @"bounds.size.width";
        anmi1.duration = _config.animateDuration;
        anmi1.toValue = @(maxX * 2);
        
        anmi1.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        anmi1.fillMode = kCAFillModeForwards;
        anmi1.autoreverses = NO;
        anmi1.removedOnCompletion = NO;
        [_gradientLayer addAnimation:anmi1 forKey:@"bw"];
    }else {
        _gradientLayer.bounds = CGRectMake(0, 0, maxX * 2, self.collectionView.bounds.size.height);
    }
    
}

- (CAAnimation *)_or_positionAnimationWithPath:(CGPathRef)path {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = 1.0f;
    animation.path = path;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeBoth;
    return animation;
}

- (void)_or_updateIndcaterLineFrame {
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGFloat midY = CGRectGetMidY(self.leftLabels.firstObject.frame);
    _indicatorLineLayer.frame = CGRectMake(_indicator.center.x - _config.indicatorLineWidth / 2.0, CGRectGetMaxY(_indicator.frame), _config.indicatorLineWidth, midY - CGRectGetMaxY(_indicator.frame));
    [CATransaction commit];
}

- (void)reloadData {
    
    if (!_dataSource) {
        return;
    }
    
    NSInteger items = [_dataSource numberOfHorizontalDataOfChartView:self];
    
    [self.horizontalDatas removeAllObjects];
    
    if (items == 0) {
        [_collectionView reloadData];
        return;
    }
    
    
    for (int i = 0; i < items; i ++) {
        
        ORLineChartHorizontal *horizontal = [ORLineChartHorizontal new];
        horizontal.value = [_dataSource chartView:self valueForHorizontalAtIndex:i];
        
        horizontal.title = [[NSAttributedString alloc] initWithString:[_dataSource chartView:self titleForHorizontalAtIndex:i] attributes:[_dataSource labelAttrbutesForHorizontalOfChartView:self]];
        
        [self.horizontalDatas addObject:horizontal];
    }
    
    NSInteger vertical = [_dataSource numberOfVerticalLinesOfChartView:self];
    
    _lineChartValue = [[ORLineChartValue alloc] initWithHorizontalData:self.horizontalDatas numberWithSeparate:vertical];
    
    if (self.leftLabels.count > vertical) {
        for (NSInteger i = vertical; i < _leftLabels.count; i ++) {
            UILabel *label = _leftLabels[i];
            [label removeFromSuperview];
            [_leftLabels removeObject:label];
        }
    }else if (self.leftLabels.count < vertical) {
        for (NSInteger i = self.leftLabels.count; i < vertical; i ++) {
            UILabel *label = [UILabel new];
            label.textAlignment = NSTextAlignmentCenter;
            [_leftLabels addObject:label];
            [self addSubview:label];
        }
    }
    
    [self.leftLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", self.lineChartValue.separatedValues[idx]] attributes:[self.dataSource labelAttrbutesForVerticalOfChartView:self]];
    }];
    
    
    NSAttributedString *lastTitle = [_dataSource chartView:self attributedStringForIndicaterAtIndex:items - 1];
    if (!lastTitle) {
        lastTitle = self.leftLabels.firstObject.attributedText;
    }
    [_indicator or_setTitle:lastTitle];
    CGFloat rightInset = MAX((_indicator.bounds.size.width - _config.bottomLabelWidth) / 2.0 + _config.contentMargin, 0);
    
    NSAttributedString *title = [_dataSource chartView:self attributedStringForIndicaterAtIndex:0];
    if (!title) {
        title = self.leftLabels.firstObject.attributedText;
    }
    [_indicator or_setTitle:title];
    CGFloat leftInset = MAX((_indicator.bounds.size.width - _config.bottomLabelWidth) / 2.0 + _config.contentMargin, 0);

    self.collectionView.contentInset = UIEdgeInsetsMake(0, leftInset, 0, rightInset);

    if (self.collectionView.contentOffset.x != -leftInset) {
        [self.collectionView setContentOffset:CGPointMake(-leftInset, 0) animated:YES];
    }

    
    [self _or_configChart];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.horizontalDatas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ORLineChartCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ORLineChartCell class]) forIndexPath:indexPath];
    cell.title = self.horizontalDatas[indexPath.row].title;
    cell.config = self.config;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(_config.bottomLabelWidth, collectionView.bounds.size.height);//collectionView.bounds.size.height
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat ratio = (scrollView.contentOffset.x + scrollView.contentInset.left) / (scrollView.contentSize.width + scrollView.contentInset.left + scrollView.contentInset.right - scrollView.bounds.size.width);
    ratio = fmin(fmax(0.0, ratio), 1.0);
    
    _circleLayer.timeOffset = ratio;
    _animationLayer.timeOffset = ratio;
    _indicator.center = _animationLayer.presentationLayer.position;
    [self _or_updateIndcaterLineFrame];
    
    NSInteger index = floor(_indicator.center.x / _config.bottomLabelWidth);
    
    if (index == _lastIndex) {
        return;
    }
    NSAttributedString *title = [_dataSource chartView:self attributedStringForIndicaterAtIndex:index];
    if (!title) {
        title = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%g", self.horizontalDatas[index].value]];
    }
    _lastIndex = index;
    [_indicator or_setTitle:title];
    
}

- (void)setDataSource:(id<ORLineChartViewDataSource>)dataSource {    
    if (_dataSource != dataSource) {
        _dataSource = dataSource;
        if (_dataSource) {
            [self reloadData];
        }
    }
}

- (void)setConfig:(ORLineChartConfig *)config {
    if (_config != config) {
        _config = config;
        if (_dataSource) {
            [self _or_configChart];
        }
    }
}

@end
