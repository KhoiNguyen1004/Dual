//
//  PinterestLayout.swift
//  uEAT
//
//  Created by Khoi Nguyen on 6/15/20.
//  Copyright © 2020 Khoi Nguyen. All rights reserved.
//

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
  func collectionView(_ collectionView: UICollectionView, widthForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

class PinterestLayout: UICollectionViewLayout {
    // 1
    weak var delegate: PinterestLayoutDelegate?

    // 2
    private let numberOfColumns = 2
    private let cellPadding: CGFloat = 6

    // 3
    private var cache: [UICollectionViewLayoutAttributes] = []

    // 4
    private var contentWidth: CGFloat = 0

    private var contentHeight: CGFloat {
      guard let collectionView = collectionView else {
        return 0
      }
      let insets = collectionView.contentInset
        return collectionView.bounds.height - (insets.top + insets.bottom)
    }

    // 5
    override var collectionViewContentSize: CGSize {
      return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
      // 1
      guard
        cache.isEmpty == true,
        let collectionView = collectionView
        else {
          return
      }
      // 2
      let columnHeight = contentHeight / CGFloat(numberOfColumns)
      var xOffset: [CGFloat] = []
      for column in 0..<numberOfColumns {
        xOffset.append(CGFloat(column) * columnHeight)
      }
      var column = 0
      var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
        
      // 3
      for item in 0..<collectionView.numberOfItems(inSection: 0) {
        let indexPath = IndexPath(item: item, section: 0)
          
        // 4
        let photoWidth = delegate?.collectionView(
          collectionView,
            widthForPhotoAtIndexPath: indexPath) ?? 180
        let width = cellPadding * 2 + photoWidth
        let frame = CGRect(x: xOffset[column],
                           y: yOffset[column],
                           width: width,
                           height: columnHeight)
        let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
          
        // 5
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = insetFrame
        cache.append(attributes)
          
        // 6
        contentWidth = max(contentWidth, frame.maxX)
        yOffset[column] = yOffset[column] + width
          
        column = column < (numberOfColumns - 1) ? (column + 1) : 0
      }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
      var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
      
      // Loop through the cache and look for items in the rect
      for attributes in cache {
        if attributes.frame.intersects(rect) {
          visibleLayoutAttributes.append(attributes)
        }
      }
      return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
      return cache[indexPath.item]
    }
}
