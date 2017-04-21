//
//  TouchPlotViewController.m
//  CoreplotSimple
//
//  Created by xxx on 13-7-26.
//  Copyright (c) 2013年 jz. All rights reserved.
//
//Core Plot官网地址：https://code.google.com/p/core-plot/
//现在最新版本1.3 话说Coreplot版本更新的越来越快了。
//这次主要演示的是在折线图上添加滑动的线以及指示的标题，类似于iphone上的股票上的图
//添加到项目时注意记得设置 other linker flag  -all_load -Objc 链接静态库
//
//对了，我在获取数据时 需要复合条件查询，所以用到了NSPredicate
//  NSPredicate * predicate=[NSPredicate predicateWithFormat:@"(outputDate >= $startTime) AND (outputDate <= $endTime) AND mineCode == $mineCode"];
//NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:startTime,@"startTime",sendTime,@"endTime",appDelegate.mineCoal.mineCode, @"mineCode", nil];
//predicate=[predicate predicateWithSubstitutionVariables:dic];
//
#import "TouchPlotViewController.h"

/**
 * 通过labelNumberFormatter 这个可以格式化 x/y
 */
//@interface  LabelNumberFormatter : NSNumberFormatter
//    @property (nonatomic, weak) NSArray *chartData;
//@end
//@implementation LabelNumberFormatter
//- (NSString *)stringForObjectValue:(NSDecimalNumber *)coordinateValue {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"dd"];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
//    NSDictionary *dic    =  [self.chartData objectAtIndex:coordinateValue.intValue];
//    NSString *day= [dateFormatter stringFromDate:outputreport.outputDate];
//
//    if (title) {
//        return title;
//    } else {
//        return [super stringForObjectValue:coordinateValue];
//    }
//}
//@end

@interface TouchPlotViewController ()
@property (nonatomic, strong) NSMutableArray *chartData;

@property (nonatomic, strong) CPTMutableLineStyle *majorGridLineStyle;
@property (nonatomic, strong) CPTMutableLineStyle *minorGridLineStyle;
@property (nonatomic, strong) NSNumberFormatter *defaultNumberFormat;

@property (nonatomic) CPTGraph *graph;

@property (nonatomic,strong) CPTMutableTextStyle *textStyle;

////////////////手指触摸
@property (nonatomic, strong) NSNumber *selectedCoordination;
@property (nonatomic, strong) NSNumber *secondSelectedCoordination;

@property (nonatomic, strong) CPTScatterPlot *touchPlot;
@property (nonatomic, strong) CPTScatterPlot *secondTouchPlot;
@property (nonatomic, strong) CPTScatterPlot *highlightTouchPlot;

@property (nonatomic, weak) UIView * conditionView;
@property (nonatomic, weak) UIView * switchView;
@property (nonatomic, weak) UIView * touchView;

@property (nonatomic,weak) UIButton * swipeButton;

@property (nonatomic,strong) CPTGraphHostingView *defaultLayerHostingView;
@end

@implementation TouchPlotViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)generateData
{
    if ( self.chartData == nil ) {
        NSMutableArray *contentArray = [NSMutableArray array];
        for ( NSUInteger i = 0; i <= 20; i++ ) {
            [contentArray addObject:[NSDecimalNumber numberWithDouble:10.0 * rand() / (double)RAND_MAX + 5.0]];
        }
        self.chartData = contentArray;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self generateData];  //生成数据
    
    CGRect frame=CGRectMake(0, 20, 480, 280);
    UIView *view=[[UIView alloc]initWithFrame:frame];
    [view setTag:100];
    [self.view addSubview:view];
    
    
    //背景格子的样式
    self.majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    self.majorGridLineStyle.lineWidth = 1.0f;
    self.majorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.75];
    
    self.minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    self.minorGridLineStyle.lineWidth = 1.0f;
    self.minorGridLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.25];
    
    
    // 准备数字格式
    self.defaultNumberFormat = [[NSNumberFormatter alloc] init];
    [self.defaultNumberFormat setMaximumFractionDigits:0];
    
    //Core Plot所在 view 类型必须为 CPTGraphHostingView 类型
    self.defaultLayerHostingView=[(CPTGraphHostingView *)[CPTGraphHostingView alloc] initWithFrame:CGRectMake(0, 0, 480, 280)];
    self.defaultLayerHostingView.collapsesLayers = NO;
    [view addSubview:self.defaultLayerHostingView];
    
    
    // 创建图表
    self.defaultLayerHostingView.hostedGraph = [(CPTXYGraph *)[CPTXYGraph alloc] initWithFrame:self.defaultLayerHostingView.frame];
    self.graph = self.defaultLayerHostingView.hostedGraph;
    // [self.graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
    
    
    //字体的样式
    CPTMutableTextStyle *titleTextStyle = [CPTMutableTextStyle textStyle];
    titleTextStyle.color                = [CPTColor grayColor];
    titleTextStyle.fontName             = @"Helvetica-Bold";
    titleTextStyle.fontSize             = 13;
    
    [self.graph setCornerRadius:10];
    // 设置标题
    self.graph.titleTextStyle           = titleTextStyle;
    self.graph.titlePlotAreaFrameAnchor=CPTRectAnchorTop;
    self.graph.titleDisplacement=CPTPointMake(0, 20);
    //设置图表的padding
    self.graph.plotAreaFrame.paddingTop =0;
    self.graph.plotAreaFrame.paddingBottom = 20;
    self.graph.plotAreaFrame.paddingLeft = 20.0;
    
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) self.graph.defaultPlotSpace;
    // 创建坐标轴
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)self.graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    {
        x.labelingPolicy=CPTAxisLabelingPolicyAutomatic;  //自动计算拖动后的 刻度
        x.orthogonalCoordinateDecimal=CPTDecimalFromInt(0); //从0开始 即：交叉点
        x.minorTicksPerInterval=4;  //一个大的间隔里有几个小的间隔
        //x.majorIntervalLength         = CPTDecimalFromInteger(1); // 因为用了自动计算 所以这个不起作用 这个代表一个大的间隔的值
        x.majorGridLineStyle = self.majorGridLineStyle;
        //x轴 显示到指定的刻度
        x.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(25.0f)];
        x.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(15.0f)];
        //        设置x轴格式化
        //        LabelNumberFormatter *labelFormatter=[[LabelNumberFormatter alloc]init];
        //        [labelFormatter setChartData:self.chartData];
        //        x.labelFormatter = labelFormatter;
        x.labelFormatter=self.defaultNumberFormat;
        x.labelTextStyle = titleTextStyle;
        x.plotSpace = plotSpace;
    }
    
    CPTXYAxis *y = axisSet.yAxis;
    {
        y.majorIntervalLength         = CPTDecimalFromFloat(1.0f);
        y.minorTicksPerInterval       = 0;
        y.orthogonalCoordinateDecimal = CPTDecimalFromFloat(-1.0f);
        y.majorGridLineStyle          = self.majorGridLineStyle;
        y.visibleRange   = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0.0f) length:CPTDecimalFromFloat(15.0f)];
        y.gridLinesRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(25.0f)];
        
        y.labelFormatter=self.defaultNumberFormat;
        y.labelTextStyle = titleTextStyle;
        y.plotSpace = plotSpace;
    }
    //添加 x/y 轴
    self.graph.axisSet.axes = @[x,y];
    
    // 创建折线样式
    CPTMutableLineStyle *lineStyle = [[CPTMutableLineStyle alloc] init];
    lineStyle.lineWidth              = 2.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    
    //创建折线
    CPTScatterPlot *plot =[self addScatterPlot:@"coreplot simple" lineStyle:lineStyle dataSource:self];
    //设置填充颜色
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0f;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    plot.areaFill      = areaGradientFill;
    plot.areaBaseValue = CPTDecimalFromDouble(0.0);
    
    // 添加折线点的提示 就是蓝色的小点点
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill               = [CPTFill fillWithColor:[[CPTColor blueColor] colorWithAlphaComponent:0.5]];
    plotSymbol.lineStyle          = symbolLineStyle;
    plotSymbol.size               = CGSizeMake(8.0, 8.0);
    plot.plotSymbol = plotSymbol;
    
    //设置范围: 比如y轴 从-1开始显示到15
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-1.0f) length:CPTDecimalFromFloat(15.0f)];
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(-2.0f) length:CPTDecimalFromFloat(25.0f)];
    
    //添加触摸功能
    [self addTouchPlot:view];
    
     // 添加图例
    self.graph.legendAnchor=CPTRectAnchorBottomLeft;  //位置
    self.graph.legendDisplacement = CGPointMake(50.0,3.0);
    [self addLegend:@[plot]];
    
    //黑色的长条
    UIView *swipeTitleView=[[UIView alloc]initWithFrame:CGRectMake(self.graph.plotAreaFrame.paddingLeft+20, self.graph.plotAreaFrame.paddingTop+5, ScreenHeight-self.graph.plotAreaFrame.paddingLeft-self.graph.plotAreaFrame.paddingRight-20, 8)];
    [swipeTitleView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"zsbj"]]];
    [view addSubview:swipeTitleView];
    
    //滑动的button
    UIButton * swipeBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [swipeBtn setBackgroundImage:[UIImage imageNamed:@"button_bj"] forState:UIControlStateNormal];
    [swipeBtn setFrame:CGRectMake(ScreenHeight/2-25, self.graph.plotAreaFrame.paddingTop, 100, 20)];
    [swipeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [swipeBtn.titleLabel setTextColor:[UIColor blackColor]];
    [swipeBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
    [swipeBtn setHidden:YES];
    [view addSubview:swipeBtn];
    self.swipeButton=swipeBtn;
}



#pragma  mark 添加折线图
- (CPTScatterPlot *)addScatterPlot:(NSString *)identifier lineStyle:(CPTMutableLineStyle *)lineStyle dataSource:(id<CPTPlotDataSource>)dataSource
{
    //添加折线图到图表
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = identifier;
    dataSourceLinePlot.dataLineStyle = lineStyle;
    dataSourceLinePlot.dataSource = dataSource;
    [self.graph addPlot:dataSourceLinePlot];
    return dataSourceLinePlot;
}
#pragma  mark 添加触摸折线图
-(void) addTouchPlot:(UIView *)hostingView{
    // 处理触摸操作
    BaseTouchesView *touchView = [[BaseTouchesView alloc] initWithFrame:hostingView.bounds];
    [touchView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [touchView setAutoresizesSubviews:YES];
    touchView.delegate=self;
    [hostingView addSubview:touchView];
    self.touchView = touchView;
    
    // 手指选择
    CPTMutableLineStyle *lineStyle = [[CPTMutableLineStyle alloc] init];
    lineStyle.lineWidth              = 2.0;
    lineStyle.lineColor              = [CPTColor orangeColor];
    
    //滑动的折线，触摸屏幕会有橙色的线可以滑动 第一次触摸屏幕出现的线是touchPlot 第二次是secondTouchPlot
    //出现两条线的时候设置highlightTouchPlot会有填充的一块。具体的可以在真机上试试，再结合代码。
    self.touchPlot = [self addScatterPlot:@"当前选择" lineStyle:lineStyle dataSource:self];
    self.secondTouchPlot = [self addScatterPlot:@"第二选择" lineStyle:lineStyle dataSource:self];
    self.highlightTouchPlot = [self addScatterPlot:@"突出选择" lineStyle:lineStyle dataSource:self];
    
    CPTPlotSymbol *touchPlotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    touchPlotSymbol.fill = [CPTFill fillWithColor:[CPTColor orangeColor]];
    touchPlotSymbol.lineStyle = lineStyle;
    touchPlotSymbol.size = CGSizeMake(8.0f, 8.0f);
    
    self.touchPlot.plotSymbol = touchPlotSymbol;
    self.secondTouchPlot.plotSymbol = touchPlotSymbol;
    self.highlightTouchPlot.plotSymbol = touchPlotSymbol;
    
    CPTColor *areaColor       = [CPTColor colorWithComponentRed:1.0 green:1.0 blue:1.0 alpha:0.6];
    CPTGradient *areaGradient = [CPTGradient gradientWithBeginningColor:areaColor endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0f;
    CPTFill *areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    
    areaGradient = [CPTGradient gradientWithBeginningColor:[CPTColor blueColor] endingColor:[CPTColor clearColor]];
    areaGradient.angle = -90.0f;
    areaGradientFill = [CPTFill fillWithGradient:areaGradient];
    self.highlightTouchPlot.areaFill      = areaGradientFill;
    self.highlightTouchPlot.areaBaseValue = CPTDecimalFromDouble(0.0);
}
#pragma mark 添加图例
-(void) addLegend:(NSArray*)array{
    
    CPTMutableTextStyle *titleTextStyle = [CPTMutableTextStyle textStyle];
    titleTextStyle.color                = [CPTColor blackColor];
    titleTextStyle.fontName             = @"Helvetica-Bold";
    titleTextStyle.fontSize             = 13;

    
    CPTMutableLineStyle *legendLineStyle = [[CPTMutableLineStyle alloc] init];
    legendLineStyle.lineWidth = 1.0;
    legendLineStyle.lineColor = [CPTColor blackColor];
    
    CPTLegend *legend = [CPTLegend legendWithPlots:array];
    legend.textStyle       = titleTextStyle;
    legend.borderLineStyle = legendLineStyle;
    legend.fill            = [CPTFill fillWithColor:[CPTColor clearColor]];
    legend.cornerRadius    = 5.0;
    legend.swatchSize      = CGSizeMake(15.0, 15.0);
    
    self.graph.legend = legend;
    self.graph.legendAnchor = CPTRectAnchorBottom;
}

-(void)killGraph
{
    // Remove the CPTLayerHostingView 这块代码来自官网的demo，coreplot占用内存还是很大的。
    if ( self.defaultLayerHostingView ) {
        [self.defaultLayerHostingView removeFromSuperview];
        self.defaultLayerHostingView.hostedGraph = nil;
        self.defaultLayerHostingView = nil;
    }
    
    [self.touchPlot removeFromSuperlayer];
    [self.secondTouchPlot removeFromSuperlayer];
    [self.highlightTouchPlot removeFromSuperlayer];
    
    self.graph=nil;
    [self.graph removeFromSuperlayer];
    // CPTAnimation
    // [[CPTAnnotation sharedInstance] removeAllAnimationOperations];
}


#pragma mark - Plot Data Source Methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    if([plot.identifier isEqual:@"当前选择"]) {
        return 3;
    } else if([plot.identifier isEqual:@"第二选择"]) {
        return 3;
    } else {
        return self.chartData.count;
    }
    return 0;
}


-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if ([self.chartData count]>0) {
        
        NSNumber *num = nil;
        
        switch (fieldEnum) { //x轴
            case CPTScatterPlotFieldX: {
                if([plot.identifier isEqual:@"当前选择"]) {
                    num = self.selectedCoordination;
                } else if([plot.identifier isEqual:@"第二选择"]) {
                    num = self.secondSelectedCoordination;
                } else if([plot.identifier isEqual:@"突出选择"]) {
                    if (self.secondSelectedCoordination &&  index >= self.selectedCoordination.intValue && index <= self.secondSelectedCoordination.intValue) {
                        num = [NSDecimalNumber numberWithInt:index];
                    }
                } else {
                    num = [NSDecimalNumber numberWithInt:index];
                }
                break;
            }
            case CPTScatterPlotFieldY:{ //y轴
                if ([plot.identifier isEqual:@"coreplot simple"]) {
                    num= [self.chartData objectAtIndex:index];
                }else if([plot.identifier isEqual:@"当前选择"]){
                    switch (index) {
                        case 0:
                            num = [NSNumber numberWithInt:0];
                            break;
                        case 2:
                            num = [NSNumber numberWithInt:15];
                            break;
                        default:
                        {
                            num= [self.chartData objectAtIndex:self.selectedCoordination.intValue];
                            break;
                        }
                    }
                } else if([plot.identifier isEqual:@"第二选择"]) {
                    switch (index) {
                        case 0:
                            num = [NSNumber numberWithInt:0];
                            break;
                        case 2:
                            num = [NSNumber numberWithInt:15];
                            break;
                        default:
                        {
                            num= [self.chartData objectAtIndex:self.secondSelectedCoordination.intValue];
                            NSLog(@"%f",[num floatValue]);
                            break;
                        }
                    }
                }else if([plot.identifier isEqual:@"突出选择"]) {
                    if (self.secondSelectedCoordination && index >= self.selectedCoordination.intValue && index <= self.secondSelectedCoordination.intValue) {
                        num= [self.chartData objectAtIndex:index];
                    }
                }
                break;
            }
        }
        return num;
    }
    return 0;
}
#pragma mark - 图标的Touch事件处理

- (int)getXFromPoint:(CGPoint)point
{
    CGPoint pointInPlotArea = [self.graph convertPoint:point toLayer:self.graph.plotAreaFrame];
    NSDecimal newPoint[2];
    [self.graph.defaultPlotSpace plotPoint:newPoint forPlotAreaViewPoint:pointInPlotArea];
    
    NSDecimalRound(&newPoint[0], &newPoint[0], 0, NSRoundPlain);
    
    int x = [[NSDecimalNumber decimalNumberWithDecimal:newPoint[0]] intValue];
    if (x < 0) {
        x = 0;
    } else if (x >= [self.self.chartData count]) {
        x = [self.chartData count] - 1;
        // NSLog(@"123");
    }
    return x;
}
/**
 *  一个手指 滑动 首先触发
 */
- (void)updateTouchPlot:(CGPoint)point
{
    int x = [self getXFromPoint:point];
    self.selectedCoordination = [NSNumber numberWithInt:x];
    
    [self.touchPlot reloadData];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:@"move" context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    CGRect rect = [self.swipeButton frame];
    rect.origin.x=point.x-25;
    [self.swipeButton setFrame:rect];
    [UIView commitAnimations];
    
    
    NSNumber *value = [self.chartData objectAtIndex:self.selectedCoordination.intValue];
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:2];
    [self.swipeButton setTitle:[NSString stringWithFormat:@"%@", [formatter stringFromNumber:value]] forState:UIControlStateNormal];
}
//两个 手指
- (void)updateTouchPlot:(CGPoint)pointA andSecondTouchPlot:(CGPoint)pointB
{
    int xa = [self getXFromPoint:pointA];
    int xb = [self getXFromPoint:pointB];
    
    if (xb < xa) {
        int temp = xa;
        xa = xb;
        xb = temp;
    }
    
    //NSLog(@"updateTouchPlot, pointa: %d, pointb: %d", xa, xb);
    
    self.selectedCoordination = [NSNumber numberWithInt:xa];
    self.secondSelectedCoordination = [NSNumber numberWithInt:xb];
    
    [self.touchPlot reloadData];
    [self.secondTouchPlot reloadData];
    [self.highlightTouchPlot reloadData];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:@"move" context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];
    CGRect rect = [self.swipeButton frame];
    if (pointA.x>pointB.x) {
        rect.origin.x= pointB.x+(pointA.x-pointB.x)/2;
    }else{
        rect.origin.x= pointA.x+(pointB.x-pointA.x)/2;
    }
    rect.origin.x-=25;
    [self.swipeButton setFrame:rect];
    [UIView commitAnimations];
    
    
    NSNumber *value1  = [self.chartData objectAtIndex:self.selectedCoordination.intValue];
    NSNumber *value2 = [self.chartData objectAtIndex:self.secondSelectedCoordination.intValue];
    
    NSNumber *value = [NSNumber numberWithFloat:value2.floatValue - value1.floatValue];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:2];
    
    [self.swipeButton setTitle:[NSString stringWithFormat:@"变化：%@", [formatter stringFromNumber:value]] forState:UIControlStateNormal];
}

#pragma mark 实现CPTPlotSpaceDelegate  拖动事件监测 判断是几个手指触摸的
-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    if (event.allTouches.count >= 2) {
        // 2个指头
        UITouch *touch = [event.allTouches.allObjects objectAtIndex:0];
        CGPoint pointA = [touch locationInView:self.touchView];
        
        touch = [event.allTouches.allObjects objectAtIndex:1];
        CGPoint pointB = [touch locationInView:self.touchView];
        
        [self updateTouchPlot:pointA andSecondTouchPlot:pointB];
        
    } else {
        // 1个指头
        [self updateTouchPlot:point];
    }
    
    return YES;
}


-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    // NSLog(@"DrapEvent: %d", event.allTouches.count);
    
    if (event.allTouches.count >= 2) {
        // 2个指头
        UITouch *touch = [event.allTouches.allObjects objectAtIndex:0];
        CGPoint pointA = [touch locationInView:self.touchView];
        
        touch = [event.allTouches.allObjects objectAtIndex:1];
        CGPoint pointB = [touch locationInView:self.touchView];
        
        [self updateTouchPlot:pointA andSecondTouchPlot:pointB];
        
    } else {
        // 1个指头
        [self updateTouchPlot:point];
    }
    
    return YES;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceUpEvent:(CPTNativeEvent *)event atPoint:(CGPoint)point
{
    //  NSLog(@"UpEvent: %d", event.allTouches.count);
    for (CPTScatterPlot *plot in space.graph.allPlots) {
        NSLog(@"%@",plot.identifier);
        NSLog(@"%u",[plot indexOfVisiblePointClosestToPlotAreaPoint:point]);
    }
    
    self.selectedCoordination = nil;
    self.secondSelectedCoordination = nil;
    
    [self.touchPlot reloadData];
    [self.secondTouchPlot reloadData];
    [self.highlightTouchPlot reloadData];
    
    //[self resetGraphTitle];
    return YES;
}


#pragma mark - 触摸事件处理  第一触发触摸事件 
- (void)theTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    [self.swipeButton setHidden:NO];
    CGPoint point;
    
    if (touches.count == 1) {
        UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
        point = [touch locationInView:self.touchView];
    }
    if (touches.count == 2) {
        UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:1];
        point = [touch locationInView:self.touchView];
    }
    
    [self plotSpace:self.graph.defaultPlotSpace shouldHandlePointingDeviceDownEvent:event atPoint:point];
}

- (void)theTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point;
    
    if (touches.count == 1) {
        UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
        point = [touch locationInView:self.touchView];
    }
    if (touches.count == 2) {
        UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:1];
        point = [touch locationInView:self.touchView];
    }
    
    [self plotSpace:self.graph.defaultPlotSpace shouldHandlePointingDeviceDraggedEvent:event atPoint:point];
}

- (void)theTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point;
    
    if (touches.count == 1) {
        UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:0];
        point = [touch locationInView:self.touchView];
    }
    if (touches.count == 2) {
        UITouch *touch = (UITouch *)[[touches allObjects] objectAtIndex:1];
        point = [touch locationInView:self.touchView];
    }
    
    [self.swipeButton setHidden:YES];
    [self plotSpace:self.graph.defaultPlotSpace shouldHandlePointingDeviceUpEvent:event atPoint:point];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
