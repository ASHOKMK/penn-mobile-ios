//
//  HomeFeedbackCell.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 3/18/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit

final class HomeFeedbackCell: UITableViewCell, HomeCellConformable {
    static var identifier: String = "homeFeedbackCell"
    
    var item: ModularTableViewItem!
    var delegate: ModularTableViewCellDelegate!
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        return 150.0
    }
    
    // UI Elements
    var cardView: UIView! = UIView()
    
    fileprivate var titleLabel: UILabel! = {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .center
        label.font = UIFont(name: "AvenirNext-Regular", size: 15)
        return label
    }()
    
    fileprivate var star1: UIButton! = UIButton() // left most star
    fileprivate var star2: UIButton! = UIButton()
    fileprivate var star3: UIButton! = UIButton()  // center star
    fileprivate var star4: UIButton! = UIButton()
    fileprivate var star5: UIButton! = UIButton()  // right most star
    fileprivate var stars = [UIButton]()
    fileprivate var starGroup: UIStackView! = {
        let stack = UIStackView()
        stack.axis  = UILayoutConstraintAxis.horizontal
        stack.distribution  = UIStackViewDistribution.equalSpacing
        stack.alignment = UIStackViewAlignment.center
        stack.spacing   = 16.0
        return stack
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareHomeCell()
        prepareUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Prepare UI
extension HomeFeedbackCell {
    fileprivate func prepareUI() {
        prepareLabel()
        prepareStarGroup()
    }
    
    fileprivate func prepareLabel() {
        let titleString = "Enjoying PennMobile? Have Feature Suggestions? Consider Leaving us a rating!"
        titleLabel.text = titleString
        cardView.addSubview(titleLabel)
        _ = titleLabel.anchor(cardView.topAnchor, left: cardView.leftAnchor, bottom: nil, right: cardView.rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 48)
    }
    
    fileprivate func prepareStarGroup() {
        stars.append(star1)
        stars.append(star2)
        stars.append(star3)
        stars.append(star4)
        stars.append(star5)
        var counter = 0
        for star in stars {
            prepareStarButton(for: star, index: counter)
            counter += 1
        }
        cardView.addSubview(starGroup)
        _ = starGroup.anchor(titleLabel.bottomAnchor, left: cardView.leftAnchor, bottom: cardView.bottomAnchor, right: cardView.rightAnchor, topConstant: 10, leftConstant: 45, bottomConstant: 20, rightConstant: 45, widthConstant: 0, heightConstant: 0)
    }
    
    fileprivate func prepareStarButton(for star: UIButton, index: Int) {
        star.setImage(#imageLiteral(resourceName: "DefaultState"), for: .normal)
        star.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        star.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        starGroup.addArrangedSubview(star)
    }
}
