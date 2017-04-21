//
//  ViewController.m
//  Coreplot画折线图
//
//  Created by YuXiang on 2017/4/21.
//  Copyright © 2017年 Rookie.YXiang. All rights reserved.
//

#import "ViewController.h"
#import "CorePlot-CocoaTouch.h"
@interface ViewController ()<CPTPlotDataSource>
{
    NSMutableArray *_dataArray;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化数组, 并放入十个 0-20 间的随机数
    _dataArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < 10; i++) {
        [_dataArray addObject:[NSNumber numberWithInt:rand()%20]];
    }
    
    CGRect frame = CGRectMake(20, 100, self.view.bounds.size.width - 40, 200);
    
    // 图形要放在一个CPTGraphHostingView中, CPTGraphHostingView继承 UIView的
    // 创建画板
    CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:frame];
    // 把CPTGraphHostingView 加在自己的view中
    [self.view addSubview:hostView];
    hostView.backgroundColor = [UIColor grayColor];
    
    // 在 CPTGraph 中画图, 这里的CPTXYGraph 是个曲线图
    // 要指定CPTGraphHostingView 的hostteGraoh 属性来关联
    CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostView.frame];
    graph.identifier = @"test";
    hostView.hostedGraph = graph;
    
    // 设置曲线
    CPTScatterPlot *scatterPlot =[[CPTScatterPlot alloc] initWithFrame:graph.bounds];
    [graph addPlot:scatterPlot];
    scatterPlot.dataSource = self;//设定数据源，需应用CPTPlotDataSource 协议
    
    // 设置PlotSpace，这里的 xRange 和 yRange 要理解好，它决定了点是否落在图形的可见区域
    //location值表示坐标起始值，一般可以设置元素中的最小值
    //length值表示从起始值上浮多少，一般可以用最大值减去最小值的结果
    
    CPTXYPlotSpace
    *plotSpace = (CPTXYPlotSpace *) scatterPlot.plotSpace;
    
    plotSpace.xRange= [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat([_dataArray count]-1)];
    
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0) length:CPTDecimalFromFloat(20)];
    
    //  每个折点用图片和文字展示具体数值  CPTTradingRangePlot
    /**
     CPTMutableLineStyle *whiteLineStyle = [CPTMutableLineStyle lineStyle]; whiteLineStyle.lineColor = [CPTColor whiteColor]; whiteLineStyle.lineWidth = 2.0;
     
     CPTTradingRangePlot *ohlcPlot = [[CPTTradingRangePlot alloc] initWithFrame:graph.bounds];
     
     ohlcPlot.identifier = @"OHLC";
     
     ohlcPlot.lineStyle = whiteLineStyle; //向上或向下的线条
     
     ohlcPlot.plotStyle = CPTTradingRangePlotStyleCandleStick;
     //ohlcPlot.shadow = whiteShadow;
     
     // ohlcPlot.labelShadow = whiteShadow;
     
     [graph addPlot:ohlcPlot];

     
     */
}
#pragma mark - CPTPlotDataSource
//询问有多少个数据
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return [_dataArray count];
}

// 询问一个个数据值, 在CPTPlotDataSource中声明的
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    if (fieldEnum == CPTScatterPlotFieldY) {  // 询问 Y值时
        return [_dataArray objectAtIndex:idx];
    }else {
        return [NSNumber numberWithInt:(int)idx];
    }
}

// 返回每个折点的y轴  数据
-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    NSLog(@"%lu",(unsigned long)index);
    if (index == 0 || index == (_dataArray.count - 1)) {  // 去除 第一个  和最后一个 y轴数据
        CPTTextLayer *label = [[CPTTextLayer alloc]initWithText:@""];
        CPTMutableTextStyle *text = [ label.textStyle mutableCopy];
        text.color = [CPTColor whiteColor];
        return label;
    }else{
        CPTTextLayer *label = [[CPTTextLayer alloc]initWithText:[NSString stringWithFormat:@"%@",_dataArray[index]]];
        CPTMutableTextStyle *text = [ label.textStyle mutableCopy];
        text.color = [CPTColor whiteColor];
        return label;
    }
 }

@end
