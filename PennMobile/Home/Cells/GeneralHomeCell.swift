//
//  AbstractHomeCell.swift
//  PennMobile
//
//  Created by Josh Doman on 1/17/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

protocol GeneralHomeCellDelegate: TransitionDelegate {}

class GeneralHomeCell: UITableViewCell {
    
    var item: HomeViewModelItem? {
        didSet {
            guard let item = item else { return }
            setupCell(for: item)
        }
    }
    
    var delegate: GeneralHomeCellDelegate!
    
    fileprivate var typeLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        prepareBackground()
        prepareTypeLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup and Prepare UI Elements
extension GeneralHomeCell {
    fileprivate func prepareBackground() {
        backgroundColor = UIColor.whiteGrey
    }
    
    fileprivate func prepareTypeLabel() {
        typeLabel = UILabel()
        typeLabel.font = UIFont.systemFont(ofSize: 10)
        
        addSubview(typeLabel)
        typeLabel.anchorWithConstantsToTop(topAnchor, left: leftAnchor, bottom: nil, right: nil, topConstant: 4, leftConstant: 8, bottomConstant: 0, rightConstant: 0)
    }
    
    fileprivate func setupCell(for item: HomeViewModelItem) {
        typeLabel.text = item.title
    }
}