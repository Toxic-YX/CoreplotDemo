//
//  ViewController.m
//  CorePlot画曲线图
// 
//  Created by YuXiang on 2017/4/24.
//  Copyright © 2017年 Rookie.YXiang. All rights reserved.
//

#import "ViewController.h"
#import "CorePlot-CocoaTouch.h"

@interface ViewController ()<CPTPlotSpaceDelegate,CALayerDelegate,CPTPlotDataSource> {
    NSArray * _coordunatesX;
    NSArray * _coordunatesY;
}
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self initSetData];
    // 创建宿主HostView
    [self initSetupUI];
    // 创建图表，用于显示的画布
    [self createGraph];
    //  创建绘图空间
    [self createPlotSpace];
    // 创建坐标
    [self createAxis];
    //创建平面图，折线图
    [self createPlots];
    // 创建图例
    [self createLegend];
}

#pragma mark - 自定义方法
- (void)initSetData {
    for (int i = 0; i < 10; i++) {
        [self.dataSource addObject:[NSNumber numberWithInt:arc4random() %10]];
    }
    
    _coordunatesX = @[@"第1次",@"第2次",@"第3次",@"第4次",@"第5次",@"第6次",@"第7次",@"第8次",@"第9次",@"第10次"];
    _coordunatesY = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10"];
}

#pragma mark - 创建宿主HostView
- (void)initSetupUI {
     //  图形要放在CPTGraphHostingView宿主中，因为UIView无法加载CPTGraph
    _hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    //  默认值：NO，设置为YES可以减少GPU的使用，但是渲染图形的时候会变慢
    _hostView.collapsesLayers = NO;
    //  允许捏合缩放 默认值：YES
    _hostView.allowPinchScaling = NO;
    //  背景色 默认值：clearColor
    _hostView.backgroundColor = [UIColor whiteColor];
    
    // 添加到View中
    [self.view addSubview:_hostView];
}

#pragma mark - 创建图表，用于显示的画布
- (void)createGraph {
    // 基于xy轴的图表创建
    CPTXYGraph *graph=[[CPTXYGraph alloc] initWithFrame:_hostView.bounds];
    // 使宿主视图的hostedGraph与CPTGraph关联
    _hostView.hostedGraph = graph;
    
    // 设置主题, 类似于 皮肤
    /**
     kCPTDarkGradientTheme、
     kCPTPlainBlackTheme、
     kCPTPlainWhiteTheme、
     kCPTSlateTheme、
     kCPTStocksTheme
     */
    CPTTheme *theme = [CPTTheme themeNamed:kCPTSlateTheme];
    [graph applyTheme:theme];
    
    // 标题设置
    graph.title = @"标题：曲线图";
    // 标题对齐于图框的位置，可以用CPTRectAnchor枚举类型，指定标题向图框的4角、4边（中点）对齐标题位置 默认值：CPTRectAnchorTop（顶部居中）
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    // 标题对齐时的偏移距离（相对于titlePlotAreaFrameAnchor的偏移距离）默认值：CGPointZero
    graph.titleDisplacement = CGPointZero;
    // 标题文本样式 默认值：nil
    CPTMutableTextStyle *textStyle = [[CPTMutableTextStyle alloc] init];
    textStyle.fontSize = CPTFloat(25);
    textStyle.textAlignment = CPTTextAlignmentLeft;
    graph.titleTextStyle = textStyle;
    
    // CPGGraph内边距，默认值：20.0f
    graph.paddingLeft = CPTFloat(0);
    graph.paddingTop = CPTFloat(0);
    graph.paddingRight = CPTFloat(0);
    graph.paddingBottom = CPTFloat(0);
    
    // CPTPlotAreaFrame绘图区域设置
    // 内边距设置，默认值：0.0f
    graph.plotAreaFrame.paddingLeft = CPTFloat(0);
    graph.plotAreaFrame.paddingTop = CPTFloat(0);
    graph.plotAreaFrame.paddingRight = CPTFloat(0);
    graph.plotAreaFrame.paddingBottom = CPTFloat(0);
    // 边框样式设置 默认值：nil
    graph.plotAreaFrame.borderLineStyle=nil;
}

#pragma mark - 创建绘图空间
- (void)createPlotSpace {
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)_hostView.hostedGraph.defaultPlotSpace;
    // 绘图空间是否允许与用户交互 默认值：NO
    plotSpace.allowsUserInteraction = YES;
    // 委托事件
    plotSpace.delegate = self;
    
    // 开启用户交互
     plotSpace.allowsUserInteraction = YES;
    
    // 可显示大小 一屏内横轴／纵轴的显示范围
    // 横轴
    // location表示坐标的显示起始值，length表示要显示的长度 类似于NSRange
    CPTMutablePlotRange *xRange = [CPTMutablePlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(-1) length:CPTDecimalFromCGFloat(_coordunatesX.count + 1)];
    // 横轴显示的收缩／扩大范围 1：不改变  <1:收缩范围  >1:扩大范围
    [xRange expandRangeByFactor:CPTDecimalFromCGFloat(1)];
    
    plotSpace.xRange = xRange;
    
    // 纵轴
    CPTMutablePlotRange *yRange = [CPTMutablePlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(-1) length:CPTDecimalFromCGFloat(11)];
    [yRange expandRangeByFactor:CPTDecimalFromCGFloat(1)];
    
    plotSpace.yRange = yRange;
    
    
    // 绘图空间的最大显示空间，滚动范围
    CPTMutablePlotRange *xGlobalRange = [CPTMutablePlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(-2) length:CPTDecimalFromCGFloat(_coordunatesX.count + 5)];
    
    CPTMutablePlotRange *yGlobalRange = [CPTMutablePlotRange plotRangeWithLocation:CPTDecimalFromCGFloat(-2) length:CPTDecimalFromCGFloat(16)];
    
    plotSpace.globalXRange = xGlobalRange;
    plotSpace.globalYRange = yGlobalRange;
    
}

#pragma mark - 创建坐标
- (void)createAxis {
    // 轴线样式
    CPTMutableLineStyle *axisLineStyle = [[CPTMutableLineStyle alloc] init];
    axisLineStyle.lineWidth = CPTFloat(1);
    axisLineStyle.lineColor = [CPTColor blackColor];
    
    // 标题样式
    CPTMutableTextStyle *titelStyle = [CPTMutableTextStyle textStyle];
    titelStyle.color = [CPTColor redColor];
    titelStyle.fontSize = CPTFloat(20);
    
    // 主刻度线样式
    CPTMutableLineStyle *majorLineStyle = [CPTMutableLineStyle lineStyle];
    majorLineStyle.lineColor = [CPTColor purpleColor];
    
    // 细分刻度线样式
    CPTMutableLineStyle *minorLineStyle = [CPTMutableLineStyle lineStyle];
    minorLineStyle.lineColor = [CPTColor blueColor];
    
    // 轴标签样式
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor blueColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = CPTFloat(11);
    
    // 轴标签样式
    CPTMutableTextStyle *axisLabelTextStyle = [[CPTMutableTextStyle alloc] init];
    axisLabelTextStyle.color=[CPTColor greenColor];
    axisLabelTextStyle.fontSize = CPTFloat(17);
    
    // 坐标系
    CPTXYAxisSet *axis = (CPTXYAxisSet *)_hostView.hostedGraph.axisSet;
    
     //X轴设置
    
    // 获取X轴线
    CPTXYAxis *xAxis = axis.xAxis;
    
    // 轴线设置
    xAxis.axisLineStyle = axisLineStyle;
    
    // 显示的刻度范围 默认值：nil
    xAxis.visibleRange=[CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(_coordunatesX.count - 1)];
    
     // 标题设置
    xAxis.title =@ "X轴";
    // 文本样式
    xAxis.titleTextStyle = titelStyle;
    // 位置 与刻度有关,
    xAxis.titleLocation = CPTDecimalFromFloat(2);
    // 方向设置
    xAxis.tickDirection = CPTSignNegative;
    // 偏移量,在方向上的偏移量
    xAxis.titleOffset = CPTFloat(25);
    
     // 位置设置
    
    // 固定坐标 默认值：nil
    //xAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:50.0];
    // 坐标原点所在位置，默认值：CPTDecimalFromInteger(0)（在Y轴的0点位置）
    xAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0);
    
    
    // 主刻度线设置
    // X轴大刻度线，线型设置
    xAxis.majorTickLineStyle = majorLineStyle;
    // 刻度线的长度
    xAxis.majorTickLength = CPTFloat(5);
    // 刻度线位置
    NSMutableSet *majorTickLocations =[NSMutableSet setWithCapacity:_coordunatesX.count];
    for (int i= 0 ;i< _coordunatesX.count ;i++) {
        [majorTickLocations addObject:[NSNumber numberWithInt:(i)]];
    }
    xAxis.majorTickLocations = majorTickLocations;
    
    // 细分刻度线设置
    // 刻度线的长度
    xAxis.minorTickLength = CPTFloat(3);
    // 刻度线样式
    xAxis.minorTickLineStyle = minorLineStyle;
    // 刻度线位置
    NSInteger minorTicksPerInterval = 3;
    CGFloat minorIntervalLength = CPTFloat(1) / CPTFloat(minorTicksPerInterval + 1);
    NSMutableSet *minorTickLocations =[NSMutableSet setWithCapacity:(_coordunatesX.count - 1) * minorTicksPerInterval];
    for (int i= 0 ;i< _coordunatesX.count - 1;i++) {
        for (int j = 0; j < minorTicksPerInterval; j++) {
            [minorTickLocations addObject:[NSNumber numberWithFloat:(i + minorIntervalLength * (j + 1))]];
        }
    }
    xAxis.minorTickLocations = minorTickLocations;
    
    // 网格线设置
    //xAxis.majorGridLineStyle = majorLineStyle;
    //xAxis.minorGridLineStyle = minorLineStyle;
    //xAxis.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(9)];
    
     // 轴标签设置
    //清除默认的方案，使用自定义的轴标签、刻度线；
    xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
    // 轴标签偏移量
    xAxis.labelOffset = 0.f;
    // 轴标签样式
    xAxis.labelTextStyle = axisTextStyle;
    
    // 存放x轴自定义的轴标签
    NSMutableSet *xAxisLabels = [NSMutableSet setWithCapacity:_coordunatesX.count];
    for ( int i= 0 ;i< _coordunatesX.count ;i++) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:_coordunatesX[i] textStyle:axisLabelTextStyle];
        // 刻度线的位置
        newLabel.tickLocation = CPTDecimalFromInt(i);
        newLabel.offset = xAxis.labelOffset + xAxis.majorTickLength;
        newLabel.rotation = M_PI_4;
        [xAxisLabels addObject :newLabel];
    }
    xAxis.axisLabels = xAxisLabels;
    
     //Y轴设置
    // 获取Y轴坐标
    CPTXYAxis *yAxis = axis.yAxis;
    
    // 委托事件
    yAxis.delegate = self;
    
    //轴线样式
    yAxis.axisLineStyle = axisLineStyle;
    
    //显示的刻度
    yAxis.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(9)];
    
    // 存放x轴自定义的轴标签
    NSMutableSet *yAxisLabels = [NSMutableSet setWithCapacity:_coordunatesY.count];
    for ( int i= 0 ;i< _coordunatesY.count ;i++) {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText:_coordunatesY[i] textStyle:axisLabelTextStyle];
        // 刻度线的位置
        newLabel.tickLocation = CPTDecimalFromInt(i);
        newLabel.offset = yAxis.labelOffset + yAxis.majorTickLength;
        //newLabel.rotation = M_PI_4;
        [yAxisLabels addObject :newLabel];
    }
    yAxis.axisLabels = yAxisLabels;
    
    // 标题设置
    
    yAxis.title = @"Y轴";
    // 文本样式
    yAxis.titleTextStyle = titelStyle;
    // 位置 与刻度有关,
    yAxis.titleLocation = CPTDecimalFromFloat(2.4);
    // 方向设置
    yAxis.tickDirection = CPTSignNegative;
    // 偏移量,在方向上的偏移量
    yAxis.titleOffset = CPTFloat(18);
    // 旋转方向
    yAxis.titleRotation = CPTFloat(M_PI_2);
    
    // 位置设置
    // 获取X轴原点即0点的坐标
    CGPoint zeroPoint = [xAxis viewPointForCoordinateDecimalNumber:CPTDecimalFromFloat(0)];
    
    // 固定坐标 默认值：nil
    yAxis.axisConstraints = [CPTConstraints constraintWithLowerOffset:CPTFloat(zeroPoint.x)];
    
    // 坐标原点所在位置，默认值：CPTDecimalFromInteger(0)（在X轴的0点位置）
    //yAxis.orthogonalCoordinateDecimal = CPTDecimalFromFloat(0);
    
    
   // 主刻度线设置
    // 显示数字标签的量度间隔
    yAxis.majorIntervalLength = CPTDecimalFromFloat(1);
    // 刻度线，线型设置
    yAxis.majorTickLineStyle = majorLineStyle;
    // 刻度线的长度
    yAxis.majorTickLength = 6;
    
    // 细分刻度线设置
    // 每一个主刻度范围内显示细分刻度的个数
    yAxis.minorTicksPerInterval = 5;
    // 刻度线的长度
    yAxis.minorTickLength = CPTFloat(3);
    // 刻度线，线型设置
    yAxis.minorTickLineStyle = minorLineStyle;
    
    // 网格线设置 默认不显示
    yAxis.majorGridLineStyle = majorLineStyle;
    yAxis.minorGridLineStyle = minorLineStyle;
    yAxis.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(_coordunatesY.count)];
    
    // 轴标签设置
    // 轴标签偏移量
    yAxis.labelOffset = CPTFloat(5);
    // 轴标签样式
    yAxis.labelTextStyle = axisTextStyle;
    
    // 排除不显示的标签
    NSArray *exclusionRanges = [NSArray arrayWithObjects:
                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(0.99) length:CPTDecimalFromDouble(0.02)],
                                [CPTPlotRange plotRangeWithLocation:CPTDecimalFromDouble(2.99) length:CPTDecimalFromDouble(0.02)],
                                nil];
    yAxis.labelExclusionRanges = exclusionRanges;
    
    // 因为没有清除默认的轴标签（CPTAxisLabelingPolicyNone）,如果想要自定义轴标签，需实现委托方法
}

#pragma mark 创建平面图，折线图
- (void)createPlots{
    // 创建折线图
    CPTScatterPlot *scatterPlot = [[CPTScatterPlot alloc] init];
    
    // 添加图形到绘图空间
    [_hostView.hostedGraph addPlot:scatterPlot];
    
    // 标识,根据此@ref identifier来区分不同的plot,也是图例显示名称,
    scatterPlot.identifier = @"scatter";
    
    // 设定数据源，需应用CPTScatterPlotDataSource协议
    scatterPlot.dataSource = self;
    
    // 委托事件
    scatterPlot.delegate = self;
    
    // 线性显示方式设置 默认值：CPTScatterPlotInterpolationLinear（折线图）
    // CPTScatterPlotInterpolationCurved（曲线图）
    // CPTScatterPlotInterpolationStepped／CPTScatterPlotInterpolationHistogram（直方图）
    scatterPlot.interpolation = CPTScatterPlotInterpolationCurved;
    
    
    // 数据标签设置，如果想用自定义的标签，则需要数据源方法：dataLabelForPlot:recordIndex:
    // 偏移量设置
    scatterPlot.labelOffset = 15;
    // 数据标签样式
    CPTMutableTextStyle *labelTextStyle = [[CPTMutableTextStyle alloc] init];
    labelTextStyle.color = [CPTColor magentaColor];
    scatterPlot.labelTextStyle = labelTextStyle;
    
    
    // 线条样式设置
    
    CPTMutableLineStyle * scatterLineStyle = [[ CPTMutableLineStyle alloc ] init];
    scatterLineStyle.lineColor = [CPTColor blackColor];
    scatterLineStyle.lineWidth = 3;
    // 破折线
    scatterLineStyle.dashPattern = @[@(10.0),@(5.0)];
    
    // 如果设置为nil则为散点图
    scatterPlot.dataLineStyle = scatterLineStyle;
    
    // 添加拐点
    // 符号类型：椭圆
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    // 符号大小
    plotSymbol.size = CPTSizeMake(8.0f, 8.f);
    // 符号填充色
    plotSymbol.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    // 边框设置
    CPTMutableLineStyle *symboLineStyle = [[ CPTMutableLineStyle alloc ] init];
    symboLineStyle.lineColor = [CPTColor blackColor];
    symboLineStyle.lineWidth = 3;
    plotSymbol.lineStyle = symboLineStyle;
    
    // 向图形上加入符号
    scatterPlot.plotSymbol = plotSymbol;
    
    // 设置拐点的外沿范围，以用来扩大检测手指的触摸范围
    scatterPlot.plotSymbolMarginForHitDetection = CPTFloat(5);
    
    // 创建渐变区
    
    // 创建一个颜色渐变：从渐变色BeginningColor渐变到色endingColor
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:[CPTColor blueColor] endingColor:[CPTColor clearColor]];
    // 渐变角度：-90 度（顺时针旋转）
    areaGradient.angle = -90.0f ;
    // 创建一个颜色填充：以颜色渐变进行填充
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    // 为图形设置渐变区
    scatterPlot.areaFill = areaGradientFill;
    // 渐变区起始值，小于这个值的图形区域不再填充渐变色
    scatterPlot.areaBaseValue = CPTDecimalFromString (@"0.0" );
    
    // 显示动画
    scatterPlot.opacity = 0.0f;
    CABasicAnimation *fadeInAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeInAnimation.duration            = 3.0f;
    fadeInAnimation.removedOnCompletion = NO;
    fadeInAnimation.fillMode            = kCAFillModeForwards;
    fadeInAnimation.toValue             = [NSNumber numberWithFloat:1.0];
    [scatterPlot addAnimation:fadeInAnimation forKey:@"animateOpacity"];
    
}

#pragma mark 创建图例
- (void)createLegend
{
    // 图例样式设置
    NSMutableArray *plots = [NSMutableArray array];
    for (int i = 0; i < _hostView.hostedGraph.allPlots.count; i++) {
        CPTScatterPlot *scatterPlot = _hostView.hostedGraph.allPlots[i];
        
        CPTScatterPlot *plot = [[CPTScatterPlot alloc] init];
        plot.dataLineStyle = scatterPlot.dataLineStyle;
        plot.plotSymbol = scatterPlot.plotSymbol;
        plot.identifier = @"折线图";
        [plots addObject:plot];
    }
    // 图例初始化
    CPTLegend *legend = [CPTLegend legendWithPlots:plots];
    // 图例的列数。有时图例太多，单列显示太长，可分为多列显示
    legend.numberOfColumns = 1;
    // 图例外框的线条样式
    legend.borderLineStyle = nil;
    // 图例的填充属性，CPTFill 类型
    legend.fill = [CPTFill fillWithColor:[CPTColor clearColor]];
    // 图例中每个样本的大小
    legend.swatchSize = CGSizeMake(40, 10);
    // 图例中每个样本的文本样式
    CPTMutableTextStyle *titleTextStyle = [CPTMutableTextStyle textStyle];
    titleTextStyle.color = [CPTColor blackColor];
    titleTextStyle.fontName = @"Helvetica-Bold";
    titleTextStyle.fontSize = 13;
    legend.textStyle = titleTextStyle;
    
    // 把图例于图表关联起来
    _hostView.hostedGraph.legend = legend;
    // 图例对齐于图框的位置，可以用 CPTRectAnchor 枚举类型，指定图例向图框的4角、4边（中点）对齐，默认值：CPTRectAnchorBottom（底部居中）
    _hostView.hostedGraph.legendAnchor = CPTRectAnchorTopRight;
    // 图例对齐时的偏移距离（相对于legendAnchor的偏移距离），默认值：CGPointZeor
    _hostView.hostedGraph.legendDisplacement = CGPointMake(-10, 0);
}

#pragma mark 是否使用系统的轴标签样式 并可改变标签样式 可用于任何标签方案(labelingPolicy)
- (BOOL)axis:(CPTAxis *)axis shouldUpdateAxisLabelsAtLocations:(NSSet *)locations
{
    // 返回NO，使用自定义，返回YES，使用系统的标签
    return NO;
}

#pragma mark - CPTPlotSpace 代理
#pragma mark 替换移动坐标
- (CGPoint)plotSpace:(CPTPlotSpace *)space willDisplaceBy:(CGPoint)proposedDisplacementVector
{
    //    NSLog(@"\n============willDisplaceBy==========\n");
    //    NSLog(@"原始的将要移动的坐标:%@", NSStringFromCGPoint(proposedDisplacementVector));
    //
    return proposedDisplacementVector;
}

#pragma mark 是否允许缩放
- (BOOL)plotSpace:(CPTPlotSpace *)space shouldScaleBy:(CGFloat)interactionScale aboutPoint:(CGPoint)interactionPoint
{
    //    NSLog(@"\n============shouldScaleBy==========\n");
    //    NSLog(@"缩放比例:%lf", interactionScale);
    //    NSLog(@"缩放的中心点:%@", NSStringFromCGPoint(interactionPoint));
    return YES;  
}  

#pragma mark 缩放绘图空间时调用，设置当前显示的大小
- (CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    //    NSLog(@"\n============willChangePlotRangeTo==========\n");
    //    NSLog(@"坐标类型:%d", coordinate);
    //    // CPTPlotRange 有比较方法 containsRange:
    //    NSLog(@"原始的坐标空间:location:%@,length:%@", [NSDecimalNumber decimalNumberWithDecimal:newRange.location].stringValue, [NSDecimalNumber decimalNumberWithDecimal:newRange.length].stringValue);
    //
    return newRange;
}

#pragma mark 结束缩放绘图空间时调用
- (void)plotSpace:(CPTPlotSpace *)space didChangePlotRangeForCoordinate:(CPTCoordinate)coordinate
{
    //    NSLog(@"\n============didChangePlotRangeForCoordinate==========\n");
    //    NSLog(@"坐标类型:%d", coordinate);
}

#pragma mark 开始按下 point是在hostedGraph中的坐标
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    NSLog(@"\n\n\n============shouldHandlePointingDeviceDownEvent==========\n");
    NSLog(@"坐标点：%@", NSStringFromCGPoint(point));
    
    return YES;
}

#pragma mark 开始拖动 point是在hostedGraph中的坐标
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    NSLog(@"\n\n\n============shouldHandlePointingDeviceDraggedEvent==========\n");
    NSLog(@"坐标点：%@", NSStringFromCGPoint(point));
    
    return YES;
}

#pragma mark 松开 point是在hostedGraph中的坐标
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    NSLog(@"\n\n\n============shouldHandlePointingDeviceUpEvent==========\n");
    NSLog(@"坐标点：%@", NSStringFromCGPoint(point));
    
    return YES;
}

#pragma mark 取消，如：来电时产生的取消事件
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceCancelledEvent:(CPTNativeEvent *)event
{
    NSLog(@"\n\n\n============shouldHandlePointingDeviceCancelledEvent==========\n");
    
    return YES;
}

#pragma mark - CPTScatterPlot的dataSource方法
#pragma mark 询问有多少个数据
- (NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.dataSource.count;
}

#pragma mark 询问一个个数据值 fieldEnum:一个轴类型，是一个枚举  idx：坐标轴索引
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx
{
    NSNumber *num = nil;
    if(fieldEnum == CPTScatterPlotFieldY){            //询问在Y轴上的值
        num = self.dataSource[idx];
    }else if (fieldEnum == CPTScatterPlotFieldX){     //询问在X轴上的值
        num = @(idx);
    }
    return num;
}

#pragma mark 添加数据标签，在拐点上显示的文本
- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    // 数据标签样式
    CPTMutableTextStyle *labelTextStyle = [[CPTMutableTextStyle alloc] init];
    labelTextStyle.color = [CPTColor magentaColor];
    
    // 定义一个 TextLayer
    CPTTextLayer *newLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%ld",(long)[self.dataSource[idx] integerValue]] style:labelTextStyle];
    
    return newLayer;
}

#pragma mark - CPTScatterPlot的delegate方法

- (void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)idx withEvent:(UIEvent *)event
{
    // 移除注释
    CPTPlotArea *plotArea = _hostView.hostedGraph.plotAreaFrame.plotArea;
    [plotArea removeAllAnnotations];
    
    // 创建拐点注释，plotSpace：绘图空间 anchorPlotPoint：坐标点
    CPTPlotSpaceAnnotation *symbolTextAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:_hostView.hostedGraph.defaultPlotSpace anchorPlotPoint:@[@(idx),self.dataSource[idx]]];
    
    // 文本样式
    CPTMutableTextStyle *annotationTextStyle = [CPTMutableTextStyle textStyle];
    annotationTextStyle.color = [CPTColor greenColor];
    annotationTextStyle.fontSize = 17.0f;
    annotationTextStyle.fontName = @"Helvetica-Bold";
    // 显示的字符串
    NSString *randomValue = [NSString stringWithFormat:@"折线图\n随即值：%@ \n", [self.dataSource[idx] stringValue]];
    // 注释内容
    CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:randomValue style:annotationTextStyle];
    // 添加注释内容
    symbolTextAnnotation.contentLayer = textLayer;
    
    // 注释位置
    symbolTextAnnotation.displacement = CGPointMake(CPTFloat(0), CPTFloat(20));
    
    // 把拐点注释添加到绘图区域中
    [plotArea addAnnotation:symbolTextAnnotation];
}



#pragma mark -  懒加载
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:20];
    }
    return _dataSource;
}
@end
