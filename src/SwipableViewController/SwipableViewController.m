//
//  SwipableViewController.m
//
//  modified by dby 2016-04-03.
//

#import "SwipableViewController.h"
#import "SwipableConfig.h"

@interface SwipableViewController ()  <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *controllers;

@end

@implementation SwipableViewController

- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)subTitles andControllers:(NSArray *)controllers
{
    return [self initWithTitle:title andSubTitles:subTitles andControllers:controllers underTabbar:NO];
}

- (instancetype)initWithTitle:(NSString *)title andSubTitles:(NSArray *)subTitles andControllers:(NSArray *)controllers underTabbar:(BOOL)underTabbar
{
    self = [super init];
    if (self) {
        self.edgesForExtendedLayout                         = UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = YES;
        
        if (title) {self.title = title;}
        
        CGFloat titleBarHeight = 36;
        _titleBar = [[TitleBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, titleBarHeight) andTitles:subTitles];
        [self.view addSubview:_titleBar];
        
        _viewPager = [[HorizonalTableViewController alloc] initWithViewControllers:controllers];
        //CGFloat height = self.view.bounds.size.height - titleBarHeight - 64 - (underTabbar ? 49 : 0);
        CGFloat height          = self.view.bounds.size.height;
        _viewPager.view.frame   = CGRectMake(0, titleBarHeight, self.view.bounds.size.width, height);
        
        [self addChildViewController:self.viewPager];
        [self.view addSubview:_viewPager.view];
        
        __weak TitleBarView *weakTitleBar                   = _titleBar;
        __weak HorizonalTableViewController *weakViewPager  = _viewPager;
        
        _viewPager.changeIndex = ^(NSUInteger index) {
            
            weakTitleBar.currentIndex = index;
            for (UIButton *button in weakTitleBar.titleButtons) {
                if (button.tag != index) {
                    button.transform = CGAffineTransformIdentity;
                } else {
                    button.transform = CGAffineTransformMakeScale(1.2, 1.2);
                }
            }
            [weakViewPager scrollToViewAtIndex:index];
        };
        
        _viewPager.scrollView = ^(CGFloat offsetRatio, NSUInteger focusIndex, NSUInteger animationIndex) {
            
            UIButton *titleFrom = weakTitleBar.titleButtons[animationIndex];
            UIButton *titleTo   = weakTitleBar.titleButtons[focusIndex];
            debugLog(@"titleFrom: %@; titleTo: %@\n", titleFrom.titleLabel.text, titleTo.titleLabel.text);
            
            [UIView transitionWithView:titleFrom duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [titleFrom setTitleColor:[UIColor colorWithRed:TitleColorValue * (1-offsetRatio)
                                                         green:TitleColorValue
                                                          blue:TitleColorValue * (1-offsetRatio) alpha:1.0] forState:UIControlStateNormal];
                
                titleFrom.transform = CGAffineTransformMakeScale(1 + 0.2 * offsetRatio, 1 + 0.2 * offsetRatio);
            } completion:nil];
            
            [UIView transitionWithView:titleTo duration:0.1 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [titleTo setTitleColor:[UIColor colorWithRed:TitleColorValue * offsetRatio
                                                       green:TitleColorValue
                                                        blue:TitleColorValue * offsetRatio alpha:1.0] forState:UIControlStateNormal];
                
                titleTo.transform = CGAffineTransformMakeScale(1 + 0.2 * (1-offsetRatio), 1 + 0.2 * (1-offsetRatio));
            } completion:nil];
            
        };
        
        _titleBar.titleButtonClicked = ^(NSUInteger index) {
            [weakViewPager scrollToViewAtIndex:index];
        };
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)scrollToViewAtIndex:(NSUInteger)index
{
    _viewPager.changeIndex(index);
}

@end