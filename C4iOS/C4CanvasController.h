//
//  ViewController.h
//  C4iOSDevelopment
//
//  Created by Travis Kirton on 11-10-06.
//  Copyright (c) 2011 mediart. All rights reserved.
//

@class C4Window;

#import <UIKit/UIKit.h>

@interface C4CanvasController : UIViewController {
}
-(void)setup;
@property (readonly, weak, nonatomic) C4Window *canvas;
@end