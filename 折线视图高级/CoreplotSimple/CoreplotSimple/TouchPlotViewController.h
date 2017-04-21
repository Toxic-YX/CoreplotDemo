//
//  TouchPlotViewController.h
//  CoreplotSimple
//
//  Created by thx01 on 13-7-26.
//  Copyright (c) 2013年 jz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot-CocoaTouch.h"
#import "BaseTouchesView.h"
@interface TouchPlotViewController : UIViewController<CPTPlotDataSource,CPTPlotSpaceDelegate,BaseTouchesViewDelegate>

@end
