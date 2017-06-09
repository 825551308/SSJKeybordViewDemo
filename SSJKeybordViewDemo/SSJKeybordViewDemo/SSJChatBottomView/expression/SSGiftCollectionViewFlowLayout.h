//
//  SSGiftCollectionViewFlowLayout.h
//  自定义聊天键盘
//
//  Created by 金汕汕 on 16/9/21.
//  Copyright © 2016年 ccs. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CustomViewFlowLayoutDelegate <UICollectionViewDelegateFlowLayout>
- (void)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout cellCenteredAtIndexPath:(NSIndexPath *)indexPath page:(int)page;
@end

@interface SSGiftCollectionViewFlowLayout : UICollectionViewFlowLayout
@property (nonatomic, weak) id<CustomViewFlowLayoutDelegate> delegate;
@end
