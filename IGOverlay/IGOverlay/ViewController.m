//
//  ViewController.m
//  IGOverlay
//
//  Created by iGalactus on 15/12/3.
//  Copyright © 2015年 一斌. All rights reserved.
//

#import "ViewController.h"
#import "IGOverlay.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic,strong) UIView *baseView;
@property (nonatomic,strong) UIButton *selectedButton;

@property (nonatomic) BOOL isResizeOverlayHeightByText;
@property (nonatomic) IGOverlayOptions headerOption;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = ({
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wow.jpg"]];
        tableView.rowHeight = 44;
        tableView.tableHeaderView = [self tableHeaderView];
        [self.view addSubview:tableView];
        
        tableView;
    });
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"移除Overlay";
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"只有一个头部框";
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"只有文字";
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"有头部框 还有文字";
        }
            break;
        case 4:
        {
            cell.textLabel.text = @"切换视图";
        }
            break;
        case 5:
        {
            cell.textLabel.text = @"自定义Overlay";
        }
            break;
        case 6:
        {
            cell.textLabel.text = @"短文字";
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    IGOverlayOptions options;
    
    if (self.isResizeOverlayHeightByText)
    {
        options = options | IGOverlayOptionLabelHeightByText;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            [IGOverlay removeOverlayInView:self.baseView];
        }
            break;
        case 1:
        {
            options = options | self.headerOption;
            [IGOverlay showOverlayWithStatus:nil options:options afterDelay:MAXFLOAT showInView:self.baseView];
        }
            break;
        case 2:
        {
            [IGOverlay showOverlayWithStatus:@"测试测试测试测试测试测试测试测试测试测试测试测试" showInView:self.baseView];
        }
            break;
        case 3:
        {
            options = options | self.headerOption;
            [IGOverlay showOverlayWithStatus:@"测试测试测试测试测试测试测试测试测试测试测试测试" options:options showInView:self.baseView];
        }
            break;
        case 4:
        {
            UIViewController *controller = [[UIViewController alloc] init];
            controller.view.backgroundColor = [UIColor whiteColor];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 5:
        {
            IGOverlay *overlay = [[IGOverlay alloc] init];
            overlay.status = @"测试一下";
            overlay.options = self.headerOption;
            overlay.overlayTextFont = [UIFont boldSystemFontOfSize:20];
            overlay.overlayTextColor = [UIColor yellowColor];
            overlay.shapeLayerColor = [UIColor greenColor];
            [overlay showInView:self.view];
        }
            break;
        case 6:
        {
            [IGOverlay showOverlayWithStatus:@"测试测试" options:options showInView:self.view];
        }
            break;
            
        default:
            break;
    }
}

-(UIView *)tableHeaderView
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    
    /// 是否根据最小文字高度设置Overlay高度
    
    UILabel *resizeLabel = [self labelWithTitle:@"高度由文字决定"];
    resizeLabel.frame = CGRectMake(10, 10, resizeLabel.frame.size.width, 30);
    [headerView addSubview:resizeLabel];
    
    UISwitch *resizeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(resizeLabel.frame) + 10, 10, 30, 30)];
    [resizeSwitch addTarget:self action:@selector(resizeOverlaySwitch:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:resizeSwitch];
    
    
    /// 在当前控制器View中显示
    
    UILabel *showLabel = [self labelWithTitle:@"当前视图/KeyWindow"];
    showLabel.frame = CGRectMake(10, 50, showLabel.frame.size.width, 30);
    [headerView addSubview:showLabel];
    
    UISwitch *showSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(showLabel.frame) + 10, 50, 30, 30)];
    [showSwitch addTarget:self action:@selector(resizeShowSwitch:) forControlEvents:UIControlEventValueChanged];
    [headerView addSubview:showSwitch];
    
    /// 头部视图
    
    UILabel *headLabel = [self labelWithTitle:@"头部视图"];
    headLabel.frame = CGRectMake(10, 90, headLabel.frame.size.width, 30);
    [headerView addSubview:headLabel];
    
    NSArray *headList = @[@"等待圈",@"错误",@"正确",@"警告"];
    for (int i = 0; i < headList.count; i++) {
        
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:headList[i] forState:0];
        [button setTitleColor:[UIColor yellowColor] forState:1<<2];
        button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        button.layer.cornerRadius = 2;
        button.layer.borderColor = [UIColor whiteColor].CGColor;
        button.layer.borderWidth = 0.5f;
        button.frame = CGRectMake(CGRectGetMaxX(headLabel.frame) + 10 + (10 + 50) * i, 90, 50, 30);
        button.tag = i;
        [button addTarget:self action:@selector(buttonSelected:) forControlEvents:1<<6];
        
        if (i == 0) {
            [self buttonSelected:button];
        }
        
        [headerView addSubview:button];
        
    }
    
    return headerView;
}

-(void)buttonSelected:(UIButton *)sender
{
    self.selectedButton.selected = NO;
    self.selectedButton = sender;
    sender.selected = YES;
    
    switch (sender.tag) {
        case 0:
        {
            self.headerOption = IGOverlayOptionHeaderTypeIndicator;
        }
            break;
        case 1:
        {
            self.headerOption = IGOverlayOptionHeaderTypeError;
        }
            break;
        case 2:
        {
            self.headerOption = IGOverlayOptionHeaderTypeSuccess;
        }
            break;
        case 3:
        {
            self.headerOption = IGOverlayOptionHeaderTypeWarning;
        }
            break;
            
        default:
            break;
    }
}

-(UILabel *)labelWithTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    [label sizeToFit];
    label.textColor = [UIColor whiteColor];
    return label;
}

-(void)resizeOverlaySwitch:(UISwitch *)switcher
{
    self.isResizeOverlayHeightByText = switcher.isOn;
}

-(void)resizeShowSwitch:(UISwitch *)switcher
{
    self.baseView = switcher.isOn ? self.view : nil;
}

@end
