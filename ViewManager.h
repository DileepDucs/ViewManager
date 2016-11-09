//
//  ViewManager.h
//  IUVConnect
//
//  Created by Taj Ahmed on 05/01/16.
//  Copyright Â© 2016 MOBINEERS. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AlertHandler)(UIAlertAction* action);

@interface ViewManager : NSObject

+ (CGSize)screenSize;
+ (void)backgroundShadoView:(UIView *)view;
+ (void)showWaitingIndicator:(BOOL)showWaitingIndicator;
+ (void)showUploadWaitingIndicator:(BOOL)showWaitingIndicator;
+ (void)showWaitingIndicator:(BOOL)showWaitingIndicator onView:(UIView*)view;
+ (void)showAlert:(NSString *)title message:(NSString *)message buttons:(NSArray<NSString *>*) buttons;
+ (void)showAlert:(NSString *)title message:(NSString *)message buttons:(NSArray<NSString *> *)buttons handlers:(NSArray<AlertHandler>*) handlers;
+ (void)setAutoresizingMaskForView:(UIView*)view left:(BOOL)left right:(BOOL)right top:(BOOL)top bottom:(BOOL)bottom height:(BOOL)height width:(BOOL)width;
+ (void)showImage:(UIImage*)image onView:(UIView*)onView;
+ (BOOL)removeImagefromView:(UIView*)fromView;
+ (UIViewController*) currentController;
+ (NSString*) defaultFontName;
+ (void)setSelectedGridImageView:(UIView *)view;

// Animatino Methods
+(void)addViewAnimationFadeIn:(UIView*)view duration:(CGFloat)duration animation:(void(^)(void))animation completion:(void(^)(BOOL finished))completion;

@end