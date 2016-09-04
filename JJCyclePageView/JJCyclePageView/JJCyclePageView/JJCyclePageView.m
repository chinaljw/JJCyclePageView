//
//  JJCyclePageView.m
//  JJCyclePageView
//
//  Created by ljw on 16/9/3.
//  Copyright © 2016年 ljw. All rights reserved.
//

#import "JJCyclePageView.h"

//默认identifier
static NSString *const kDefaultCellIdentifier = @"kDefaultCellIdentifier";

//默认自动滚动时间间隔
static CGFloat const kDefaultautoScrollTimeInterval = 5.f;

@interface JJCyclePageView () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
{
    //真是pageIndex
    NSUInteger _realPageIndex;
    //是否在滚
    BOOL _isScrolling;
    //是否等待改变滚动方向
    BOOL _isWaitingToChangeScrollDirection;
    //临时方向
    JJCyclePageViewScrollDirection _tempDirection;
}

@property (nonatomic, strong) UICollectionView *mainCollectionView;

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation JJCyclePageView

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initSelf];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSelf];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.mainCollectionView.frame = self.bounds;
}

//视图消失时停止计时器，否则无法释放
- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [self endAutoScroll];
}

//当视图出现时判断是否要自动滚
- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if ([self canAutoScroll]) {
        [self beginAutoScroll];
    }
}

#pragma mark - Initialize
//初始化
- (void)initSelf
{
    _scrollDirection = JJCyclePageViewScrollDirectionHorizontal;
    _pagingEnabled = YES;
    _scrollAbleWhenOneCell = YES;
    _autoScrollDirection = JJCyclePageViewAutoScrollDirectionAscending;
    _autoScrollTimeInterval = kDefaultautoScrollTimeInterval;
    _scrollEnabled = YES;
    [self addSubview:self.mainCollectionView];
}

#pragma mark - Setter & Getter
- (UICollectionView *)mainCollectionView
{
    if (!_mainCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0.f;
        layout.minimumInteritemSpacing = 0.f;
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        _mainCollectionView.backgroundColor = [UIColor clearColor];
        _mainCollectionView.pagingEnabled = YES;
        _mainCollectionView.showsVerticalScrollIndicator = NO;
        _mainCollectionView.showsHorizontalScrollIndicator = NO;
    }
    return _mainCollectionView;
}

- (void)setScrollDirection:(JJCyclePageViewScrollDirection)scrollDirection
{
    //为了处理滚动时换方向的问题
    if (scrollDirection != _scrollDirection && _isScrolling) {
        _isWaitingToChangeScrollDirection = YES;
        _tempDirection = scrollDirection;
        return;
    }
    _scrollDirection = scrollDirection;
    [(UICollectionViewFlowLayout *)self.mainCollectionView.collectionViewLayout
     setScrollDirection:scrollDirection == JJCyclePageViewScrollDirectionHorizontal ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical];
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    _pagingEnabled = pagingEnabled;
    self.mainCollectionView.pagingEnabled = _pagingEnabled;
}

- (void)setScrollAbleWhenOneCell:(BOOL)scrollAbleWhenOneCell
{
    _scrollAbleWhenOneCell = scrollAbleWhenOneCell;
    //设置完后重新加载才起作用，暂时这样吧
    [self reloadData];
}

- (void)setShouldAutoScroll:(BOOL)shouldAutoScroll
{
    _shouldAutoScroll = shouldAutoScroll;
    if ([self canAutoScroll]) {
        [self beginAutoScroll];
    }
    else
    {
        [self endAutoScroll];
    }
    
}

- (NSTimer *)timer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(didTimeGo:) userInfo:nil repeats:YES];
    }
    return _timer;
}

- (void)setAutoScrollTimeInterval:(CGFloat)autoScrollTimeInterval
{
    _autoScrollTimeInterval = autoScrollTimeInterval;
    if ([self canAutoScroll]) {
        //设置时间后要重新生成timer
        [self restartAutoScroll];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    _scrollEnabled = scrollEnabled;
    self.mainCollectionView.scrollEnabled = _scrollEnabled;
}

#pragma mark - Public
- (void)registerCellWithClass:(Class)cellClass identifier:(NSString *)identifier
{
    [self.mainCollectionView registerClass:cellClass forCellWithReuseIdentifier:identifier];
}

- (void)registerCellWithClass:(Class)cellClass
{
    [self registerCellWithClass:cellClass identifier:kDefaultCellIdentifier];
}

- (void)registerCellWithNib:(UINib *)cellNib identifier:(NSString *)identifier
{
    [self.mainCollectionView registerNib:cellNib forCellWithReuseIdentifier:identifier];
}

- (void)registerCellWithNib:(UINib *)cellNib
{
    [self registerCellWithNib:cellNib identifier:kDefaultCellIdentifier];
}

- (void)reloadData
{
    [self.mainCollectionView reloadData];
    
    //如果当前输出的页码大于最大页码重置为最大页码
    if (self.currentPageIndex > [self.dataSource numberOfItem] - 1) {
        _currentPageIndex = [self.dataSource numberOfItem] - 1;
        [self scrollToIndex:self.currentPageIndex animated:NO];
    }
    
    //如果当前输出的页码和实际的页码不同重置为当前输出页码
    if (self.currentPageIndex != _realPageIndex) {
        _realPageIndex = self.currentPageIndex;
        [self scrollToIndex:self.currentPageIndex animated:NO];
    }
    
    //判断是否能够自动滚能的话开启，不能的话关闭
    if ([self canAutoScroll]) {
        [self beginAutoScroll];
    }
    else
    {
        [self endAutoScroll];
    }
}

- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self.mainCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:animated];
    //友情提示：哪天要是滚着滚着越界了，崩溃了，go die 了，可以试试注释上面的方法打开下面的方法来急救
//    CGPoint contentOffset = {0,0};
//    if (self.scrollDirection == JJCyclePageViewScrollDirectionHorizontal) {
//        contentOffset.x = index * self.bounds.size.width;
//    }
//    if (self.scrollDirection == JJCyclePageViewScrollDirectionVertical) {
//        contentOffset.y = index * self.bounds.size.height;
//    }
//    [self.mainCollectionView setContentOffset:contentOffset animated:animated];
}

#pragma mark - Private
//根据pageIndex获取对应offset，区分滚动方向
- (CGPoint)contentOffsetForIndex:(NSUInteger)index
{
    return self.scrollDirection == JJCyclePageViewScrollDirectionHorizontal ? CGPointMake(index * [self boundsWidth], 0.f) : CGPointMake(0.f, index * [self boundsHeight]);
}

//根据真实的index获取输出到外部的index
- (NSUInteger)outputIndexForRealIndex:(NSUInteger)realIndex
{
    return realIndex == [self.dataSource numberOfItem] ? 0 : realIndex;
}

//根据offset获取真实的index，区分滚动方向
- (NSUInteger)realIndexForContentOffset:(CGPoint)contentOffset
{
    return self.scrollDirection == JJCyclePageViewScrollDirectionHorizontal ? contentOffset.x / [self boundsWidth] : contentOffset.y / [self boundsHeight];
}

//单位宽
- (CGFloat)boundsWidth
{
    return self.mainCollectionView.bounds.size.width;
}

//单位高
- (CGFloat)boundsHeight
{
    return self.mainCollectionView.bounds.size.height;
}

//开始自动滚
- (void)beginAutoScroll
{
    if (!_timer) {
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    }
}

//结束自动滚
- (void)endAutoScroll
{
    if (_timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

//判断是否能滚
- (BOOL)canScroll
{
    return [self.dataSource numberOfItem] != 0 && !( !self.scrollAbleWhenOneCell && [self.dataSource numberOfItem] == 1);
}

//是否能自动滚
- (BOOL)canAutoScroll
{
    //要自动滚 & 出现在window上 & 能滚
    return self.shouldAutoScroll && self.window && [self canScroll] && self.autoScrollTimeInterval != 0;
}

//重启自动滚动
- (void)restartAutoScroll
{
    if (_timer) {
        [self endAutoScroll];
        [self beginAutoScroll];
    }
}

//结束滚动时的处理
- (void)handleScrollingEnd
{
    _isScrolling = NO;
    if (_isWaitingToChangeScrollDirection) {
        self.scrollDirection = _tempDirection;
        _isWaitingToChangeScrollDirection = NO;
    }
}

//处理滚动开始
- (void)handleScrolling
{
    _isScrolling = YES;
}

#pragma mark - TimerAction
- (void)didTimeGo:(NSTimer *)timer
{
    NSUInteger nextPageIndex = self.currentPageIndex;
    
    switch (self.autoScrollDirection) {
        case JJCyclePageViewAutoScrollDirectionAscending:
        {
            nextPageIndex ++;
            //如果处于真实的最后一个，且下一个是输出的第二个
            if (_realPageIndex == [self.dataSource numberOfItem])
            {
                //移动到输出的第一个
                self.mainCollectionView.contentOffset = [self contentOffsetForIndex:0];
            }
        }
            break;
        case JJCyclePageViewAutoScrollDirectionDescending:
        {
            //如果处于第一个
            if (self.currentPageIndex == 0) {
                nextPageIndex = [self.dataSource numberOfItem] - 1;
                //移动到真实的最后一个
                self.mainCollectionView.contentOffset = [self contentOffsetForIndex:[self.dataSource numberOfItem]];
            }
            else
            {
                nextPageIndex --;
            }
            
        }
            break;
            
        default:
            break;
    }
    
    //翻滚吧
    [self scrollToIndex:nextPageIndex animated:YES];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSUInteger count = [self.dataSource numberOfItem];
    //判断是否能滚
    return [self canScroll] ? count + 1: count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger outputIndex = [self outputIndexForRealIndex:indexPath.row];
    
    NSString *identifier = kDefaultCellIdentifier;
    if ([self.dataSource respondsToSelector:@selector(cellIdentifierAtIndex:)]) {
        identifier = [self.dataSource cellIdentifierAtIndex:outputIndex];
    }
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [self.dataSource configForCell:cell atIndex:outputIndex];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    [self handleScrolling];
    
    //设置真是的pageindex
    _realPageIndex = [self realIndexForContentOffset:scrollView.contentOffset];
    
    switch (self.scrollDirection) {
            //横向滚动
        case JJCyclePageViewScrollDirectionHorizontal:
        {
            //往左滚到头
            if (scrollView.contentOffset.x < 0.f) {
                CGPoint contentOffset = [self contentOffsetForIndex:[self.dataSource numberOfItem]];
                contentOffset.x += scrollView.contentOffset.x - 0.f;
                scrollView.contentOffset = contentOffset;
                return;
            }
            //往右滚到头
            if (scrollView.contentOffset.x > scrollView.contentSize.width - 1 * [self boundsWidth]) {
                CGPoint contentOffset = [self contentOffsetForIndex:0];
                contentOffset.x += scrollView.contentOffset.x - (scrollView.contentSize.width - 1 * [self boundsWidth]);
                scrollView.contentOffset = contentOffset;
                return;
            }
        }
            break;
            //竖直滚动
        case JJCyclePageViewScrollDirectionVertical:
        {
            //往上滚到头
            if (scrollView.contentOffset.y < 0.f) {
                CGPoint contentOffset = [self contentOffsetForIndex:[self.dataSource numberOfItem]];
                contentOffset.y += scrollView.contentOffset.y - 0.f;
                scrollView.contentOffset = contentOffset;
                return;
            }
            //往下滚到头
            if (scrollView.contentOffset.y > scrollView.contentSize.height - 1 * [self boundsHeight]) {
                CGPoint contentOffset = [self contentOffsetForIndex:0];
                contentOffset.y += scrollView.contentOffset.y - (scrollView.contentSize.height - 1 * [self boundsHeight]);
                scrollView.contentOffset = contentOffset;
                return;
            }
        }
            break;
        default:
            break;
    }
    
    //设置outputpageindex
    NSUInteger pageIndex = [self outputIndexForRealIndex:_realPageIndex];
    if (pageIndex != _currentPageIndex) {
        _currentPageIndex = pageIndex;
        if ([self.delegate respondsToSelector:@selector(didScrollToIndex:)]) {
            [self.delegate didScrollToIndex:pageIndex];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    //拖拽时销毁timer
    [self endAutoScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //结束拖拽创建timer
    if ([self canAutoScroll]) {
        [self beginAutoScroll];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self handleScrollingEnd];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self handleScrollingEnd];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(didSelectItemAtIndex:)]) {
        [self.delegate didSelectItemAtIndex:[self outputIndexForRealIndex:indexPath.row]];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.bounds.size;
}

@end
