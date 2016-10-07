//
//  MenuExampleViewController.m
//  iOS-Example
//
//  Created by Mats Hauge on 07.10.2016.
//  Copyright © 2016 Agens AS. All rights reserved.
//

#import "ListViewController.h"

#import <Anymotion/Anymotion.h>

@interface ListViewController ()
@property (nonatomic, strong) NSMutableArray *views;
@property (nonatomic, strong) UIView *containerView;
@end

@implementation ListViewController

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.title = @"List Animation";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:containerView];
    self.containerView = containerView;
    
    [self showListAfterDelay:0.5];
}

- (void)showListAfterDelay:(NSTimeInterval)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSUInteger numberOfItems = 3;
        CGFloat padding = 100.0;
        CGFloat width = self.containerView.frame.size.width - padding;
        CGFloat height = (self.containerView.frame.size.height - self.navigationController.navigationBar.frame.size.height - padding) / numberOfItems;
        CGRect frame = CGRectMake((padding / 2.0) - (width / 2.0), self.navigationController.navigationBar.frame.size.height + padding / 2.0, width, height);
        
        NSMutableArray *views = [NSMutableArray array];
        CATransform3D transform = CATransform3DMakeScale(0.0, 1.0, 1.0);
        NSTimeInterval delay = 0.0;
        CGFloat hue = [self randomNumberBetween:0.0 maxNumber:255.0];
        CGFloat saturation = 255.0;
        
        for (NSUInteger index = 0; index < numberOfItems; index++)
        {
            CGFloat brighness = (((double)index / (double)numberOfItems) * 100.0) + 155;
            UIColor *color = [UIColor colorWithHue:hue/255.0 saturation:saturation/255.0 brightness:brighness/255.0 alpha:1.0];
            
            UIView *view = [self viewWithFrame:frame color:color];
            view.layer.transform = transform;
            [self.containerView addSubview:view];
            [views addObject:view];
            
            NSValue *toValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
            CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.19 : 1.0 : 0.22 : 1.0];
            [[[[[[[[[ANYCABasic keyPath:@"transform"] toValue:toValue] timingFunction:timingFunction] updateModel] animationFor:view.layer] before:^{
                view.layer.anchorPoint = CGPointMake(0.0, 0.5);
            }] after:^{
                CGPoint center = view.center;
                center.x = self.containerView.center.x;
                view.layer.anchorPoint = CGPointMake(0.5, 0.5);
                view.center = center;
            }] delay:delay] start];
            
            frame.origin.y += frame.size.height;
            delay += 0.1;
        }
        
        self.views = views;
        
    });
}

- (void)hideListAfterDelay:(NSTimeInterval)delay
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableArray *animations = [NSMutableArray array];
        NSTimeInterval delay = 0.0;
        
        for (UIView *view in self.views)
        {
            CATransform3D transform = CATransform3DMakeScale(0.0, 1.0, 1.0);
            NSValue *toValue = [NSValue valueWithCATransform3D:transform];
            CAMediaTimingFunction *timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.95 : 0.05 : 0.795 : 0.035];
            
            ANYAnimation *animation = [[[[[[[[ANYCABasic keyPath:@"transform"] toValue:toValue] timingFunction:timingFunction] updateModel] animationFor:view.layer] before:^{
                CGPoint center = view.center;
                center.x = self.containerView.center.x + (view.frame.size.width / 2.0);
                view.layer.anchorPoint = CGPointMake(1.0, 0.5);
                view.center = center;
            }] onCompletion:^{
                [view removeFromSuperview];
            }] delay:delay];
            
            [animations addObject:animation];
            
            delay += 0.1;
        }
        
        [[[ANYAnimation group:animations] onCompletion:^{
            [self showListAfterDelay:1.0];
        }] start];
        
    });
}

- (UIView *)viewWithFrame:(CGRect)frame color:(UIColor *)color
{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapView:)];
    UIView *view = [[UIView alloc] initWithFrame:frame];
    [view addGestureRecognizer:tapGesture];
    view.backgroundColor = color;
    return view;
}

- (void)didTapView:(UIGestureRecognizer *)gesture
{
    CGRect frame = self.view.bounds;
    frame.origin.y = frame.size.height / 2.0;
    
    UIColor *backgroundColor = gesture.view.backgroundColor;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = backgroundColor;
    view.layer.transform = CATransform3DMakeScale(1.0, 0.0, 1.0);
    view.layer.anchorPoint = CGPointMake(0.5, 1.0);
    [self.view addSubview:view];
    
    [[[ANYUIView animationWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut block:^{
        view.layer.transform = CATransform3DIdentity;
        self.containerView.transform = CGAffineTransformMakeScale(0.8, 0.8);
    }] onCompletion:^{
        
        for (UIView *v in self.views)
        {
            [v removeFromSuperview];
        }
        
        self.containerView.transform = CGAffineTransformIdentity;
        self.containerView.backgroundColor = backgroundColor;
        [view removeFromSuperview];
        
        [self showListAfterDelay:2.0];
        
    }] start];
}

- (NSInteger)randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max
{
    return min + arc4random() % (max - min);
}

@end