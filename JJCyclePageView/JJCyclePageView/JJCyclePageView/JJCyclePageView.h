//
//  JJCyclePageView.h
//  JJCyclePageView
//
//  Created by ljw on 16/9/3.
//  Copyright © 2016年 ljw. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @author 蔚哥哥, 16-09-03 22:09:33
 *
 *  滚动方向
 */
typedef NS_ENUM(NSInteger, JJCyclePageViewScrollDirection) {
    /**
     *  @author 蔚哥哥, 16-09-03 22:09:33
     *
     *  水平
     */
    JJCyclePageViewScrollDirectionHorizontal,
    /**
     *  @author 蔚哥哥, 16-09-03 22:09:33
     *
     *  竖直
     */
    JJCyclePageViewScrollDirectionVertical,
};

/**
 *  @author 蔚哥哥, 16-09-03 22:09:51
 *
 *  自动滚动的方向
 */
typedef NS_ENUM(NSInteger, JJCyclePageViewAutoScrollDirection) {
    /**
     *  @author 蔚哥哥, 16-09-03 22:09:51
     *
     *  index递增方向
     */
    JJCyclePageViewAutoScrollDirectionAscending,
    /**
     *  @author 蔚哥哥, 16-09-03 22:09:51
     *
     *  index递减方向
     */
    JJCyclePageViewAutoScrollDirectionDescending,
};

@class JJCyclePageView;
/**
 *  @author 蔚哥哥, 16-09-03 22:09:11
 *
 *  数据源协议
 */
@protocol JJCyclePageViewDataSource <NSObject>

/**
 *  @author 蔚哥哥, 16-09-03 22:09:25
 *
 *  item数
 *
 *  @return item数
 */
- (NSUInteger)numberOfItemForPageView:(JJCyclePageView *)pageView;

/**
 *  @author 蔚哥哥, 16-09-03 22:09:44
 *
 *  配置cell
 *
 *  @param cell  UICollectionViewCell
 *  @param index index
 */
- (void)configCell:(__kindof UICollectionViewCell *)cell atIndex:(NSUInteger)index forPageView:(JJCyclePageView *)pageView;

@optional;
/**
 *  @author 蔚哥哥, 16-09-03 22:09:11
 *
 *  index对应的identifier，不实现则使用默认的identifier
 *
 *  @param index index
 *
 *  @return index对应的identifier
 */
- (NSString *)cellIdentifierAtIndex:(NSUInteger)index forPageView:(JJCyclePageView *)pageView;

@end

/**
 *  @author 蔚哥哥, 16-09-03 22:09:26
 *
 *  代理协议
 */
@protocol JJCyclePageViewDelegate <NSObject>

@optional;
/**
 *  @author 蔚哥哥, 16-09-03 22:09:34
 *
 *  滚到index时会调用，相同的index不会调用
 *
 *  @param index index
 */
- (void)didScrollToIndex:(NSUInteger)index forPageView:(JJCyclePageView *)pageView;

/**
 *  @author 蔚哥哥, 16-09-03 22:09:12
 *
 *  选中item时回调
 *
 *  @param index index
 */
- (void)didSelectItemAtIndex:(NSUInteger)index forPageView:(JJCyclePageView *)pageView;

@end

IB_DESIGNABLE
@interface JJCyclePageView : UIView

/**
 *  @author 蔚哥哥, 16-09-03 22:09:06
 *
 *  数据源
 */
@property (nonatomic, weak) IBOutlet id<JJCyclePageViewDataSource> dataSource;

/**
 *  @author 蔚哥哥, 16-09-03 22:09:14
 *
 *  代理
 */
@property (nonatomic, weak) IBOutlet id<JJCyclePageViewDelegate> delegate;

/**
 *  @author 蔚哥哥, 16-09-03 22:09:18
 *
 *  滚动方向
 */
@property (nonatomic, assign) JJCyclePageViewScrollDirection scrollDirection;

/**
 *  @author 蔚哥哥, 16-09-03 17:09:46
 *
 *  是否分页，默认YES
 */
@property (nonatomic, assign) IBInspectable BOOL pagingEnabled;

/**
 *  @author 蔚哥哥, 16-09-03 17:09:17
 *
 *  只有一个cell时是否能滚动，默认YES（设置后会重新加载数据）
 */
@property (nonatomic, assign) IBInspectable BOOL scrollAbleWhenOneCell;

/**
 *  @author 蔚哥哥, 16-09-03 20:09:15
 *
 *  当前处于第几页
 */
@property (nonatomic, assign, readonly) NSUInteger currentPageIndex;

/**
 *  @author 蔚哥哥, 16-09-03 20:09:44
 *
 *  是否自动滚动，默认NO
 */
@property (nonatomic, assign) IBInspectable BOOL shouldAutoScroll;

/**
 *  @author 蔚哥哥, 16-09-03 20:09:57
 *
 *  自动滚动的方向，默认 JJCyclePageViewAutoScrollDirectionAscending
 */
@property (nonatomic, assign) JJCyclePageViewAutoScrollDirection autoScrollDirection;

/**
 *  @author 蔚哥哥, 16-09-03 20:09:06
 *
 *  自动滚动的时间间隔，默认5秒
 */
@property (nonatomic, assign) IBInspectable CGFloat autoScrollTimeInterval;

/**
 *  @author 蔚哥哥, 16-09-04 13:09:31
 *
 *  是否能人为滚动，默认YES
 */
@property (nonatomic, assign) IBInspectable BOOL scrollEnabled;

/**
 *  @author 蔚哥哥, 16-09-04 23:09:28
 *
 *  是否要滚到世界尽头
 */
@property (nonatomic, assign) IBInspectable BOOL shouldScrollForever;

/**
 *  @author 蔚哥哥, 16-09-03 22:09:48
 *
 *  通过class，identifier注册cell（UICollectionViewCell）
 *
 *  @param cellClass  clas
 *  @param identifier identifier
 */
- (void)registerCellWithClass:(Class)cellClass identifier:(NSString *)identifier;

/**
 *  @author 蔚哥哥, 16-09-03 22:09:44
 *
 *  通过class注册cell，使用默认的identifier（UICollectionViewCell）
 *
 *  @param cellClass clas
 */
- (void)registerCellWithClass:(Class)cellClass;

/**
 *  @author 蔚哥哥, 16-09-03 22:09:10
 *
 *  通过nib，identifier注册cell（UICollectionViewCell）
 *
 *  @param cellNib    nib
 *  @param identifier identifier
 */
- (void)registerCellWithNib:(UINib *)cellNib identifier:(NSString *)identifier;

/**
 *  @author 蔚哥哥, 16-09-03 22:09:02
 *
 *  通过nib注册cell，使用默认的identifier（UICollectionViewCell）
 *
 *  @param cellNib nib
 */
- (void)registerCellWithNib:(UINib *)cellNib;

/**
 *  @author 蔚哥哥, 16-09-03 22:09:30
 *
 *  重新加载数据
 */
- (void)reloadData;

/**
 *  @author 蔚哥哥, 16-09-03 22:09:41
 *
 *  滚到index
 *
 *  @param index    index
 *  @param animated 直接滚还是动画着滚
 */
- (void)scrollToIndex:(NSUInteger)index animated:(BOOL)animated;

@end
