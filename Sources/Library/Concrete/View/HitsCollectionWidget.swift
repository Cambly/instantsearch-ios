//
//  HitsCollectionWidget.swift
//  InstantSearch
//
//  Created by Guy Daher on 07/04/2017.
//
//

import Foundation
import UIKit

@objc public class HitsCollectionWidget: UICollectionView, HitsViewDelegate, AlgoliaWidget {
    
    @IBInspectable public var hitsPerPage: UInt = 20
    @IBInspectable public var infiniteScrolling: Bool = true
    @IBInspectable public var remainingItemsBeforeLoading: UInt = 5
    
    var viewModel: HitsViewModelDelegate
    
    public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        viewModel = HitsViewModel()
        super.init(frame: frame, collectionViewLayout: layout)
        viewModel.view = self
    }
    
    public required init?(coder aDecoder: NSCoder) {
        viewModel = HitsViewModel()
        super.init(coder: aDecoder)
        viewModel.view = self
    }
    
    public func scrollTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
    
    public func reloadHits() {
        reloadData()
    }
}
