//
//  MainTableViewVC.m
//  SSJKeybordViewDemo
//
//  Created by jssName on 2017/6/7.
//  Copyright © 2017年 ccs. All rights reserved.
//


#import "MainTableViewVC.h"
#import "MainTableViewCell.h"
@interface MainTableViewVC ()
@property (nonatomic,strong) NSMutableArray *list;
@end

@implementation MainTableViewVC

- (void)joinToList:(NSString *)str{
    [self.list addObject:str];
    [self.tableView reloadData];
}
- (void)updateWithList:(NSMutableArray *)arr{
    self.list = arr;
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([MainTableViewCell class]) bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:mainTableViewCellIdent];
        //去掉多余下划线
    removeDouble_bottomLine(self.tableView);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MainTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:mainTableViewCellIdent forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    (indexPath.row % 2 ==0)?(cell.backgroundColor=[UIColor yellowColor]):(cell.backgroundColor=[UIColor orangeColor]);
    [cell updateCell:self.list[indexPath.row]];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here, for example:
    // Create the next view controller.
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:<#@"Nib name"#> bundle:nil];
    
    // Pass the selected object to the new view controller.
    
    // Push the view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

//滚动收回键盘
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (self.scrollViewWillBeginDraggingBlock) {
        self.scrollViewWillBeginDraggingBlock(scrollView);
    }
}
// 滚到底部
- (void)scrollToBottom {
    NSInteger count = self.list.count;
    if (count > 1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(count - 1) inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
- (NSMutableArray *)list{
    if (!_list) {
        _list = [NSMutableArray new];
//        _list = [@[@"你好",@"今天天气不错噢",@"好啥呀",@"快下雨了都",@"啊，好像是这样的"] mutableCopy];
    }
    return _list;
}

/** 去掉多余的tableView线条 */
static inline void removeDouble_bottomLine(UITableView *tableView){
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
    tableView.backgroundColor = [UIColor clearColor];
}
@end
