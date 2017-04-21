//
//  ViewController.m
//  CorePlot画图
//
//  Created by YuXiang on 2017/4/20.
//  Copyright © 2017年 Rookie.YXiang. All rights reserved.
//  http://www.tuicool.com/articles/eQVNNv

#import "ViewController.h"
#import "CorePlot-CocoaTouch.h"

@interface ViewController ()<CPTPlotDataSource,CALayerDelegate>
@property (nonatomic, strong) NSMutableArray *arr;
@property (nonatomic, strong) CPTXYGraph *graph;
@property (nonatomic, strong) CPTPieChart *piePlot;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // 创建画布
    self.graph = [[CPTXYGraph alloc] initWithFrame:self.view.bounds];
    // 设置画布主题
    CPTTheme *theme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
    [self.graph applyTheme:theme];
    // 画布与周围的距离
    self.graph.paddingTop = 10.0f;
    self.graph.paddingLeft = 5.0f;
    self.graph.paddingRight = 5.0f;
    self.graph.paddingBottom = 10.0f;
    // 将画布的坐标轴设置为空
    self.graph.axisSet = nil;
    
    // 创建画板
    CPTGraphHostingView *hostView= [[CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    // 设置画板的画布
    hostView.hostedGraph =  self.graph;
    // 设置画布标题的风格
    CPTMutableTextStyle *whiteText = [CPTMutableTextStyle textStyle];
    whiteText.color = [CPTColor blackColor];
    whiteText.fontName = @"Helvetica-Bold";
    whiteText.fontSize = 18.0;
    self.graph.titleTextStyle = whiteText;
    self.graph.title = @"饼状图";
    
    // 创建饼图对象
    self.piePlot = [[CPTPieChart alloc] initWithFrame:CGRectMake(10, 10, 200, 200)];
    // 设置数据源
    self.piePlot.dataSource = self;
    // 设置饼状图半径
    self.piePlot.pieRadius = 100.0;
    //设置饼图表示符
    self.piePlot.identifier =@"pie chart";
    //饼图开始绘制的位置
    self.piePlot.startAngle =M_PI_4;
    //饼图绘制的方向（顺时针/逆时针）
    self.piePlot.sliceDirection = CPTPieDirectionCounterClockwise;
    //饼图的重心
    self.piePlot.centerAnchor =CGPointMake(0.5,0.38);
    //饼图的线条风格
    self.piePlot.borderLineStyle = [CPTLineStyle lineStyle];
    //设置代理
    self.piePlot.delegate =self;
    //将饼图加到画布上
    [self.graph addPlot:self.piePlot];
    
    //将画板加到视图上
    [self.view addSubview:hostView];
    
    //创建图例
    CPTLegend *theLegeng = [CPTLegend legendWithGraph:self.graph];
    theLegeng.numberOfColumns =1;
    theLegeng.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegeng.borderLineStyle = [CPTLineStyle lineStyle];
    theLegeng.cornerRadius =5.0;
    theLegeng.delegate =self;
    
    self.graph.legend = theLegeng;
    self.graph.legendAnchor = CPTRectAnchorRight;
    self.graph.legendDisplacement =CGPointMake(-10,100);

}

//返回扇形数目
- (NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.arr.count;
}
//返回每个扇形的比例
- (NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx {
    return [self.arr objectAtIndex:idx];
}

//凡返回每个扇形的标题
- (CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx
{
    CPTTextLayer *label = [[CPTTextLayer alloc]initWithText:[NSString stringWithFormat:@"hello,%@",[self.arr objectAtIndex:idx]]];
    CPTMutableTextStyle *text = [label.textStyle mutableCopy];
    text.color = [CPTColor whiteColor];
    return label;
}

//选中某个扇形时的操作
- (void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)idx
{
    self.graph.title = [NSString stringWithFormat:@"比例:%@",[self.arr objectAtIndex:idx]];
}



//返回图例
- (NSAttributedString *)attributedLegendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)idx
{
    NSAttributedString *title = [[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"hi:%lu",(unsigned long)idx]];
    
    return title;
}

- (NSMutableArray *)arr {
    if (!_arr) {
        _arr = [NSMutableArray arrayWithObjects:@"1.0",@"3.0",@"1.0",@"2.0",@"2.0", nil];
    }
    return _arr;
}

@end
