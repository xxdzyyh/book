### 自定义present动画



1. 实现 UIViewControllerAnimatedTransitioning 协议，决定动画怎么做

   ```
   #import <UIKit/UIKit.h>
   @interface BouncePresentAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>
   
   @end
   
   
   #import "BouncePresentAnimatedTransitioning.h"
   
   @implementation BouncePresentAnimatedTransitioning
   
   - (void)animateTransition:(nonnull id<UIViewControllerContextTransitioning>)transitionContext {
   	UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
   	CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
   	
   	UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
   	UIView *containerView = [transitionContext containerView];
   	CGRect screenBounds = [UIScreen mainScreen].bounds;
   	toVC.view.frame = CGRectOffset(finalFrame, 0, screenBounds.size.height);
   	[containerView addSubview:toVC.view];
   	
   	NSTimeInterval duration = [self transitionDuration:transitionContext];
   	
   //	// 改成弹性动画
   //    [UIView animateWithDuration:duration delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
   //        fromVC.view.alpha = 0.5;
   //        toVC.view.frame = finalFrame;
   //    } completion:^(BOOL finished) {
   //		fromVC.view.alpha = 1.0;
   //		[transitionContext completeTransition:YES];
   //	}];
   	
   	// 将动画改为p类似push动画
   	toVC.view.frame = CGRectOffset(finalFrame, screenBounds.size.width, 0);
   	[UIView animateWithDuration:duration animations:^{
   		fromVC.view.alpha = 0.5;
   		toVC.view.frame = finalFrame;
   	} completion:^(BOOL finished) {
   		fromVC.view.alpha = 1.0;
   		[transitionContext completeTransition:YES];
   	}];
   }
   
   - (NSTimeInterval)transitionDuration:(nullable id<UIViewControllerContextTransitioning>)transitionContext {
   	return 1.0;
   }
   
   @end
   ```

2. 要弹出视图的VC，实现 UIViewControllerTransitioningDelegate，

   ```
   @interface CustomTransitionVC () <UIViewControllerTransitioningDelegate> 
   
   @end
   
   @implementation CustomTransitionVC
   
   - (void)presentSomeVC {
   	KeywordVC *vc = [KeywordVC new];
   
   	vc.transitioningDelegate = self;
   	
   	// present调用还是和以前一样，但是动画已经由BouncePresentAnimatedTransitioning决定
   	[self presentViewController:vc animated:YES completion:nil];
   }
   
   - (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
   	return [BouncePresentAnimatedTransitioning new];
   }
   ```

   