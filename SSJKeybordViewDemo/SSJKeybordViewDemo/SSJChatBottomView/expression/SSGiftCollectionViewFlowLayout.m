
//
//  SSGiftCollectionViewFlowLayout.m
//  自定义聊天键盘
//
//  Created by 金汕汕 on 16/9/21.
//  Copyright © 2016年 ccs. All rights reserved.
//

#import "SSGiftCollectionViewFlowLayout.h"


@implementation SSGiftCollectionViewFlowLayout


- (void)prepareLayout{
    [super prepareLayout];
}
- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumInteritemSpacing = 0.0f;
        self.sectionInset = UIEdgeInsetsZero;
        self.itemSize = CGSizeMake(100.f ,100.f);
        self.minimumLineSpacing = 0;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        if (CGRectIntersectsRect(attribute.frame, rect)) {
            if (visibleRect.origin.x == 0) {
                [self.delegate collectionView:self.collectionView layout:self cellCenteredAtIndexPath:attribute.indexPath page:0];
            }else{
                // 除法取整 取余数
                div_t x = div(visibleRect.origin.x,visibleRect.size.width);
                if (x.quot > 0 && x.rem > 0) {
                    [self.delegate collectionView:self.collectionView layout:self cellCenteredAtIndexPath:attribute.indexPath page:x.quot + 1];
                }
                if (x.quot > 0 && x.rem == 0) {
                    [self.delegate collectionView:self.collectionView layout:self cellCenteredAtIndexPath:attribute.indexPath page:x.quot];
                }
            }
        }
    }
    return attributes;
}



@end
