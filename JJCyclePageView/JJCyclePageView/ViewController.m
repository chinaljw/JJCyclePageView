//
//  ViewController.m
//  JJCyclePageView
//
//  Created by ljw on 16/9/3.
//  Copyright © 2016年 ljw. All rights reserved.
//

#import "ViewController.h"
#import "JJCyclePageView.h"
#import "CollectionViewCell.h"
#import "OtherCollectionViewCell.h"

@interface ViewController () <JJCyclePageViewDataSource, JJCyclePageViewDelegate>

@property (nonatomic, strong) IBOutlet JJCyclePageView *pageView;

@property (nonatomic, strong) NSArray *colorList;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.colorList = @[
                       [UIColor orangeColor],
                       [UIColor whiteColor],
                       [UIColor greenColor],
                       [UIColor blueColor],
                       [UIColor grayColor],
                       ];
    
//    [self.view addSubview:self.pageView];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [_pageView scrollToIndex:4 animated:YES];
//    });
    [self configPageView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setter & Getter
//- (JJCyclePageView *)pageView
//{
//    if (!_pageView) {
//        CGRect frame = self.view.bounds;
//        frame.size.height = frame.size.width * 9 / 16;
//        frame.origin.y = 200.f;
//        _pageView = [[JJCyclePageView alloc] initWithFrame:frame];
//    }
//    return _pageView;
//}

#pragma mark - Private
- (void)configPageView
{
    _pageView.dataSource = self;
    _pageView.delegate = self;
    [_pageView registerCellWithNib:[UINib nibWithNibName:NSStringFromClass([CollectionViewCell class]) bundle:[NSBundle mainBundle]] identifier:@"cell"];
    [_pageView registerCellWithNib:[UINib nibWithNibName:NSStringFromClass([OtherCollectionViewCell class]) bundle:[NSBundle mainBundle]] identifier:@"otherCell"];
//    _pageView.scrollDirection = JJCyclePageViewScrollDirectionVertical;
//    _pageView.scrollAbleWhenOneCell = YES;
//    _pageView.shouldAutoScroll = YES;
//    _pageView.autoScrollTimeInterval = .0f;
//    _pageView.autoScrollDirection = JJCyclePageViewAutoScrollDirectionDescending;
}

#pragma mark - JJCyclePageViewDataSource
- (NSUInteger)numberOfItem
{
    return self.colorList.count;
}

- (void)configForCell:(__kindof UICollectionViewCell *)cell atIndex:(NSUInteger)index
{
    if (index % 2 == 0) {
        CollectionViewCell *testCell = cell;
        testCell.titleLabel.text = @(index).description;
        testCell.backgroundColor = self.colorList[index];
    }
    else
    {
        OtherCollectionViewCell *testCell = cell;
        testCell.otherTitleLabel.text = @(index).description;
        testCell.backgroundColor = self.colorList[index];
    }
    
}

- (NSString *)cellIdentifierAtIndex:(NSUInteger)index
{
    return index % 2 == 0 ? @"cell" : @"otherCell";
}

#pragma mark - JJCyclePageViewDelegate
- (void)didScrollToIndex:(NSUInteger)index
{
    NSLog(@"scroll to index %lul", index);
}

- (void)didSelectItemAtIndex:(NSUInteger)index
{
//    NSLog(@"select index %lul", index);
}

#pragma mark - Actions
- (IBAction)didClickStopButton:(UIButton *)sender {
//    self.pageView.shouldAutoScroll = !self.pageView.shouldAutoScroll;
    [self.pageView removeFromSuperview];
    self.pageView = nil;
}

- (IBAction)didClickReloadButton:(UIButton *)sender {
    if (self.colorList.count > 2) {
        self.colorList = @[
                           [UIColor orangeColor],
//                           [UIColor greenColor],
                           ];
    }
    else
    {
        self.colorList = @[
                           [UIColor orangeColor],
                           [UIColor whiteColor],
                           [UIColor greenColor],
                           [UIColor blueColor],
                           [UIColor grayColor],
                           ];
    }
    [self.pageView reloadData];
}

- (IBAction)didChangeValue:(UISwitch *)sender {
    
    self.pageView.scrollDirection = sender.isOn ? JJCyclePageViewScrollDirectionVertical : JJCyclePageViewScrollDirectionHorizontal;
    
}
- (IBAction)didChangeAutoScrollValue:(UISwitch *)sender {
    self.pageView.autoScrollDirection = sender.on ? JJCyclePageViewAutoScrollDirectionDescending : JJCyclePageViewAutoScrollDirectionAscending;
}
@end
