//
//  ViewController.m
//  DemoNetwork
//
//  Created by user on 15/5/12.
//  Copyright (c) 2015年 lcg. All rights reserved.
//

#import "ViewController.h"
#import "RefreshTableView.h"
#import "LayoutMacro.h"
#import "DemoCell.h"
#import "PageModel.h"
#import "DemoRequest.h"

@interface ViewController ()<RefreshTableViewDelegate, BGNetworkRequestDelegate>{
    RefreshTableView *_tableView;
    NSMutableArray *_dataArr;
    NSInteger _pageSize;
    NSInteger _page;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"BGNetworkDemo";
    [self setupViews];
    [self setupData];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)setupData{
    _page = 0;
    _pageSize = 10;
    _dataArr = [NSMutableArray array];
    [self requestData];
}

- (void)requestData{
    DemoRequest *request = [[DemoRequest alloc] initPage:_page pageSize:_pageSize];
    [request sendRequestWithDelegate:self];
}

- (void)setupViews{
    _tableView = [[RefreshTableView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight-64.0) withRefreshHeadView:YES withRefreshFootView:YES];
    _tableView.delegate = self;
    _tableView.isCompleted = NO;
    _tableView.isRemoveFootViewWhenLoadMoreCompleted = NO;
    [self.view addSubview:_tableView];
}

#pragma mark RefreshTableViewDelegate method
- (NSInteger)numberOfSectionsInRefreshTableView:(RefreshTableView *)tableView{
    return 1;
}

- (NSInteger)refreshTableView:(RefreshTableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}

- (CGFloat)refreshTableView:(RefreshTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}

- (UITableViewCell *)refreshTableView:(RefreshTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DemoCell *cell = [tableView dequeueReusableCellWithIdentifier:[DemoCell cellIdentifier]];
    if(cell == nil){
        cell = [DemoCell loadFromXib];
    }
    [cell fillCellWithObject:_dataArr[indexPath.row]];
    return cell;
}

- (void)refreshTableView:(RefreshTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView stopPullDownRefresh];
}

//下拉刷新
- (void)pullDownRefreshTableView:(RefreshTableView *)tableView{
    _page = 0;
    [self requestData];
}

//上拉加载
- (void)pullUpRefreshTableView:(RefreshTableView *)tableView{
    _page ++;
    [self requestData];
}

#pragma mark - BGNetworkRequestDelegate method
- (void)request:(BGNetworkRequest *)request successWithResponse:(id)response{
    if(![response isKindOfClass:[PageModel class]]){
        return;
    }
    PageModel *resultModel = response;
    //下拉刷新
    if(_page == 0){
        [_dataArr removeAllObjects];
        [_dataArr addObjectsFromArray:resultModel.list];
    }
    else{
        [_dataArr addObjectsFromArray:resultModel.list];
    }
    //加载完成，改变tableView状态
    if(_page*_pageSize >= resultModel.count){
        _tableView.isCompleted = YES;
    }
    else{
        _tableView.isCompleted = NO;
    }
    [_tableView reloadData];
}

- (void)request:(BGNetworkRequest *)request failWithError:(NSError *)error{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
