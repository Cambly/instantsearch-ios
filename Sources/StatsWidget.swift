//
//  StatsWidget.swift
//  ecommerce
//
//  Created by Guy Daher on 09/03/2017.
//  Copyright © 2017 Guy Daher. All rights reserved.
//

import UIKit

@IBDesignable
@objc public class StatsWidget: UILabel, StatsViewDelegate, AlgoliaView {
    
    public var viewModel: StatsViewModelDelegate!
    
    @IBInspectable public var resultTemplate: String = ""
    @IBInspectable public var clearText: String = ""
    @IBInspectable public var errorText: String = ""
    
    public func set(text: String) {
        self.text = text
    }
}