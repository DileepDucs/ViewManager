//
//  ViewManager.m
//  IUVConnect
//
//  Created by Taj Ahmed on 05/01/16.
//  Copyright © 2016 MOBINEERS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ViewManager.h"
#import "UIColor+fromHex.h"

//Class level variables
static UIView* waitingContainerView = nil;
static UIActivityIndicatorView *waitingIndicator = nil;

static UIView* waitingContainerViewForSubView = nil;
static UIActivityIndicatorView *waitingIndicatorForSubView = nil;

static UIImageView* loaderImageView = nil;

@implementation ViewManager

+ (void)initialize
{
    if (self == [ViewManager class]) {
        if (!waitingIndicator) {
            waitingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            waitingIndicatorForSubView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            loaderImageView = [[UIImageView alloc] init];
        }
    }
}

+(void)showAlert:(NSString *)title message:(NSString *)message buttons:(NSArray<NSString *> *)buttons{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIViewController *viewController = [((UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController) visibleViewController];
    for (NSString* actionName in buttons) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:actionName
                                                         style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * _Nonnull action) {}];
        [alert addAction:action];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [viewController presentViewController:alert animated:YES completion:nil];
    });
}

+(void)showAlert:(NSString *)title message:(NSString *)message buttons:(NSArray<NSString *> *)buttons handlers:(NSArray<AlertHandler>*) handlers {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIViewController *viewController = [((UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController) visibleViewController];
    if (handlers && [handlers count]) {
        for (NSString* actionName in buttons) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:actionName
                                                             style:UIAlertActionStyleCancel
                                                           handler:[handlers objectAtIndex:[buttons indexOfObject:actionName]]];
            [alert addAction:action];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController presentViewController:alert animated:YES completion:nil];
        });
    } else {
        [ViewManager showAlert:title message:message buttons:buttons];
    }
}

+ (void)showWaitingIndicator:(BOOL)showWaitingIndicator{
    __block UIViewController *viewController = ((UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController).visibleViewController;
    dispatch_async(dispatch_get_main_queue(), ^{
        static dispatch_once_t onceToken = 0;
        dispatch_once(&onceToken, ^{
            CGRect viewFrame = CGRectMake(CGRectMinXEdge, CGRectMinYEdge, viewController.view.frame.size.width, viewController.view.frame.size.height);
            waitingContainerView = [[UIView alloc] initWithFrame:viewFrame];
            loaderImageView.frame = CGRectMake((waitingContainerView.frame.size.width - 30)/2, (waitingContainerView.frame.size.height - 30)/2, 30, 30);
            [loaderImageView setImage:[[UIImage imageNamed:@"loading2"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
            [loaderImageView setTintColor:[UIColor whiteColor]];
            [ViewManager startAnimation];
            [waitingContainerView addSubview:loaderImageView];
            [waitingContainerView addSubview:waitingIndicator];
            [waitingContainerView.layer setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.3].CGColor];
        });
        if (showWaitingIndicator) {
            [viewController.view addSubview:waitingContainerView];
             [ViewManager startAnimation];
        } else {
            [waitingContainerView removeFromSuperview];
        }
        [waitingContainerView setHidden:!showWaitingIndicator];
    });
}

+ (void)showUploadWaitingIndicator:(BOOL)showWaitingIndicator {
    __block UIViewController *viewController = ((UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController);
    dispatch_sync(dispatch_get_main_queue(), ^{
            CGRect viewFrame = CGRectMake(CGRectMinXEdge, CGRectMinYEdge, viewController.view.frame.size.width, viewController.view.frame.size.height);
            waitingContainerView = [[UIView alloc] initWithFrame:viewFrame];
            waitingIndicator.center=waitingContainerView.center;
            [waitingIndicator setHidesWhenStopped:YES];
            [waitingIndicator startAnimating];
            [waitingContainerView addSubview:waitingIndicator];
            [waitingContainerView.layer setBackgroundColor:[[UIColor alloc] initWithWhite:0 alpha:0.5].CGColor];
        
        if (showWaitingIndicator) {
            [viewController.view addSubview:waitingContainerView];
            [waitingIndicator startAnimating];
        } else {
            [waitingIndicator stopAnimating];
            [waitingContainerView removeFromSuperview];
        }
        [waitingContainerView setHidden:!showWaitingIndicator];
    });
    
}

+ (void)showWaitingIndicator:(BOOL)showWaitingIndicator onView:(UIView*)indicatorView{
    if (showWaitingIndicator) {
        CGRect indicatorFrame = indicatorView.frame;
        indicatorFrame.origin = CGPointZero;
        waitingContainerViewForSubView = [[UIView alloc] initWithFrame:indicatorFrame];
        waitingIndicatorForSubView.center=waitingContainerViewForSubView.center;
        [waitingIndicatorForSubView setHidesWhenStopped:YES];
        [waitingIndicatorForSubView startAnimating];
        [waitingContainerViewForSubView addSubview:waitingIndicatorForSubView];
        [waitingContainerViewForSubView.layer setBackgroundColor:[[UIColor alloc] initWithWhite:0 alpha:0.5].CGColor];
        [indicatorView addSubview:waitingContainerViewForSubView];
        [waitingIndicatorForSubView startAnimating];
    } else {
        [waitingIndicatorForSubView stopAnimating];
        [waitingContainerViewForSubView removeFromSuperview];
    }
    [waitingContainerViewForSubView setHidden:!showWaitingIndicator];
}


+ (void)showImage:(UIImage*)image onView:(UIView*)onView{
    if (!image) {
        [self showAlert:@"Image Not Found" message:@"selected Image not available please try again" buttons:@[@"OK"]];
        return;
    }
    [UIView beginAnimations:@"curldown" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:.6];
    CGRect indicatorFrame = onView.frame;
    indicatorFrame.origin = CGPointZero;
    waitingContainerViewForSubView = [[UIView alloc] initWithFrame:indicatorFrame];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.tag = 1289;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setFrame:[self getSubFrameForImage:imageView forView:waitingContainerViewForSubView]];
    imageView.center = waitingContainerViewForSubView.center;
    waitingContainerViewForSubView.contentMode = UIViewContentModeScaleAspectFit;
    [waitingContainerViewForSubView.layer setBackgroundColor:[[UIColor alloc] initWithWhite:0 alpha:0.5].CGColor];
    [waitingContainerViewForSubView addSubview:imageView];
    [onView addSubview:waitingContainerViewForSubView];
    [UIView commitAnimations];
}

+ (BOOL)removeImagefromView:(UIView*)fromView{
    UIView* imageView = [fromView viewWithTag:1289];
    if (!imageView) {
        return NO;
    }
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:imageView cache:YES];
        waitingContainerViewForSubView.alpha = 0;
    } completion:^(BOOL finished) {
        [waitingContainerViewForSubView setHidden:YES];
        [imageView removeFromSuperview];
    }];
    return imageView!=nil;
}

+ (CGRect)getSubFrameForImage:(UIView*)value forView:(UIView*)forView{
    float hfactor = value.bounds.size.width / forView.frame.size.width;
    float vfactor = value.bounds.size.height / forView.frame.size.height;
    float factor = fmax(hfactor, vfactor);
    float newWidth = value.bounds.size.width / factor;
    float newHeight = value.bounds.size.height / factor;
    return CGRectMake(0, 0, newWidth, newHeight);
}

+(void)setAutoresizingMaskForView:(UIView*)view
                             left:(BOOL)left
                            right:(BOOL)right
                              top:(BOOL)top
                           bottom:(BOOL)bottom
                           height:(BOOL)height
                            width:(BOOL)width {
    __block UIViewAutoresizing autoResizeMask = UIViewAutoresizingNone;
    autoResizeMask = [self setAutoresizing:top :autoResizeMask :UIViewAutoresizingFlexibleTopMargin];
    autoResizeMask = [self setAutoresizing:bottom :autoResizeMask :UIViewAutoresizingFlexibleBottomMargin];
    autoResizeMask = [self setAutoresizing:left :autoResizeMask :UIViewAutoresizingFlexibleLeftMargin];
    autoResizeMask = [self setAutoresizing:right :autoResizeMask :UIViewAutoresizingFlexibleRightMargin];
    autoResizeMask = [self setAutoresizing:height :autoResizeMask :UIViewAutoresizingFlexibleHeight];
    autoResizeMask = [self setAutoresizing:width :autoResizeMask :UIViewAutoresizingFlexibleWidth];
    [view setAutoresizingMask:autoResizeMask];
}

+(UIViewController*) currentController {
    return ((UINavigationController*)[UIApplication sharedApplication].delegate.window.rootViewController).visibleViewController;
}

+(UIViewAutoresizing) setAutoresizing:(BOOL)setResizing :(UIViewAutoresizing)autoresizingMask :(UIViewAutoresizing)newResizing{
    if (setResizing) {
        autoresizingMask |= newResizing;
    }
    return autoresizingMask;
}

+(CGSize)screenSize{
    CGFloat screenScale = [[UIScreen mainScreen] scale];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGSize screenSize = CGSizeMake(screenBounds.size.width * screenScale, screenBounds.size.height * screenScale);
    return screenSize;
}

+(NSString*) defaultFontName{
    return @"Times New Roman";
}

+ (void)startAnimation {
    [ViewManager runSpinAnimationOnView:loaderImageView duration:1 rotations:1.6 repeat:CGFLOAT_MAX];
}

+ (void) runSpinAnimationOnView:(UIView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;
{
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOffset = CGSizeZero;
    view.layer.shadowOpacity = 1.0;
    view.layer.shadowRadius = 4.0;
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 /* full rotation*/ * rotations * duration ];
    rotationAnimation.duration = duration;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = repeat;
    [view.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
#pragma mark - Animation Methods

+(void)addViewAnimationFadeIn:(UIView*)view duration:(CGFloat)duration animation:(void(^)(void))animation completion:(void(^)(BOOL finished))completion{
    [UIView animateKeyframesWithDuration:duration delay:0 options:UIViewKeyframeAnimationOptionCalculationModePaced animations:^{
        view.alpha = 0.0;
        view.layer.transform = CATransform3DMakeScale(0,0,1);
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1.0 animations:^{
            view.alpha = 1;
            view.layer.transform = CATransform3DIdentity;
            if (animation) {
                animation();
            }
        }];
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}

#pragma mark - Background shadow view.

+ (void)backgroundShadoView:(UIView *)view {
    view.layer.shadowColor = [UIColor blackColor].CGColor;
    view.layer.shadowOpacity = 0.5f;
    view.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
    view.layer.shadowRadius = 3.0f;
    view.layer.cornerRadius = 5.0;
    view.layer.masksToBounds = NO;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:view.bounds];
    view.layer.shadowPath = path.CGPath;
    
}

#pragma mark - set selected Grid Image.
+ (void)setSelectedGridImageView:(UIView *)view {
    UIImageView *selectimageView = [[UIImageView alloc] initWithFrame:CGRectMake(view.frame.size.width - 17, 2, 15, 22)];
    [selectimageView setImage:[[UIImage imageNamed:@"gridClickIcon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [selectimageView setTintColor:[UIColor darkGrayColor]];
    [view addSubview:selectimageView];
}
@end
