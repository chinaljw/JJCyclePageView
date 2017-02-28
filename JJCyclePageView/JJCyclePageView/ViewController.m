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
    
//    self.colorList = @[];
    
//    [self.view addSubview:self.pageView];
    
    [self configPageView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStylePlain target:self action:@selector(didClickNextItem:)];
    
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
//    _pageView.dataSource = self;
//    _pageView.delegate = self;
    [_pageView registerCellWithNib:[UINib nibWithNibName:NSStringFromClass([CollectionViewCell class]) bundle:[NSBundle mainBundle]] identifier:@"cell"];
    [_pageView registerCellWithNib:[UINib nibWithNibName:NSStringFromClass([OtherCollectionViewCell class]) bundle:[NSBundle mainBundle]] identifier:@"otherCell"];
//    _pageView.scrollDirection = JJCyclePageViewScrollDirectionVertical;
//    _pageView.scrollAbleWhenOneCell = YES;
//    _pageView.shouldAutoScroll = YES;
//    _pageView.autoScrollTimeInterval = .0f;
//    _pageView.autoScrollDirection = JJCyclePageViewAutoScrollDirectionDescending;
}

#pragma mark - JJCyclePageViewDataSource
- (NSUInteger)numberOfItemForPageView:(JJCyclePageView *)pageView
{
    return self.colorList.count;
}

- (void)configCell:(__kindof UICollectionViewCell *)cell atIndex:(NSUInteger)index forPageView:(JJCyclePageView *)pageView
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

- (NSString *)cellIdentifierAtIndex:(NSUInteger)index forPageView:(JJCyclePageView *)pageView
{
    return index % 2 == 0 ? @"cell" : @"otherCell";
}

#pragma mark - JJCyclePageViewDelegate
- (void)didScrollToIndex:(NSUInteger)index forPageView:(JJCyclePageView *)pageView
{
    NSLog(@"scroll to index %lul", index);
}

- (void)didSelectItemAtIndex:(NSUInteger)index forPageView:(JJCyclePageView *)pageView
{
    NSLog(@"select index %lul", index);
}

#pragma mark - Actions
- (IBAction)didClickStopButton:(UIButton *)sender {
//    self.pageView.shouldAutoScroll = !self.pageView.shouldAutoScroll;
    [self.pageView removeFromSuperview];
    self.pageView = nil;
}

- (IBAction)didClickReloadButton:(UIButton *)sender {
    if (self.colorList.count > 0) {
        self.colorList = nil;
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
//    self.colorList = @[];
    [self.pageView reloadData];
}

- (IBAction)didChangeValue:(UISwitch *)sender {
    
    self.pageView.scrollDirection = sender.isOn ? JJCyclePageViewScrollDirectionVertical : JJCyclePageViewScrollDirectionHorizontal;
    
}
- (IBAction)didChangeAutoScrollValue:(UISwitch *)sender {
    self.pageView.autoScrollDirection = sender.on ? JJCyclePageViewAutoScrollDirectionDescending : JJCyclePageViewAutoScrollDirectionAscending;
}

- (void)didClickNextItem:(UIBarButtonItem *)barButtonItem
{
    UIViewController *vc = [UIViewController new];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
