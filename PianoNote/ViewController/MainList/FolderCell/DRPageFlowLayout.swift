//
//  DRPageFlowLayout.swift
//  PianoNote
//
//  Created by 김경록 on 2018. 3. 22..
//  Copyright © 2018년 piano. All rights reserved.
//

import UIKit

/// PagingEffect를 가지는 FlowLayout.
class DRPageFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        collectionView?.decelerationRate = UIScrollViewDecelerationRateFast
    }
    
    /*
     User의 scroll이 멈추는 순간 화면의 midX를 기점으로 item을 중앙정렬하여
     마치 paging이 되는것처럼 보이도록 contentOffset을 조정한다.
     */
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else {return proposedContentOffset}
        let viewSize = collectionView.bounds.size
        let proposedRect = CGRect(x: proposedContentOffset.x, y: 0, width: viewSize.width, height: viewSize.height)
        
        // 화면상에 보여지는 item들의 layoutAttributes를 가져온다.
        guard let layoutAttribute = layoutAttributesForElements(in: proposedRect) else {
            return proposedContentOffset
        }
        
        var candidateAttribute: UICollectionViewLayoutAttributes?
        let proposedContentOffsetMidX = proposedContentOffset.x + viewSize.width / 2
        // scroll된 contentOffset을 더하여 계산된 보여지는 화면상의 midX값.
        
        for attribute in layoutAttribute where attribute.representedElementCategory == .cell {
            if candidateAttribute == nil {
                candidateAttribute = attribute
                continue
            }
            // 화면상의 보여지는 item들의 layoutAttribute중에서 최대한 midX값에 근접한 layoutAttribute를 찾는다.
            let attributeValue = fabs(attribute.center.x - proposedContentOffsetMidX)
            let cadidateValue = fabs(candidateAttribute!.center.x - proposedContentOffsetMidX)
            if attributeValue < cadidateValue {candidateAttribute = attribute}
        }
        
        guard candidateAttribute != nil else {return proposedContentOffset}
        var newOffsetX = candidateAttribute!.center.x - viewSize.width / 2
        let offset = newOffsetX - collectionView.contentOffset.x
        
        /*
         User가 가만히 있다가 action을 중단했는지 아니면 swipe action을 취했는지 판단하여
         해당 swipe 방향에 따라 이전 또는 다음 item의 위치를 추가로 계산해준다. (쓩~ 넘어갈 수 있도록 하는,)
         */
        if (velocity.x < 0 && offset > 0) || (velocity.x > 0 && offset < 0) {
            let pageWidth = viewSize.width + minimumLineSpacing
            newOffsetX += (velocity.x > 0) ? pageWidth : -pageWidth
        }
        
        return CGPoint(x: newOffsetX, y: proposedContentOffset.y)
    }
    
}

