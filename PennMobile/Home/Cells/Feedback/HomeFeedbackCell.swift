//
//  HomeFeedbackCell.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 3/18/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation
import UIKit
import StoreKit

final class HomeFeedbackCell: UITableViewCell, HomeCellConformable {
    static var identifier: String = "homeFeedbackCell"
    
    var item: ModularTableViewItem!
    var delegate: ModularTableViewCellDelegate!
    
    static func getCellHeight(for item: ModularTableViewItem) -> CGFloat {
        return 160.0
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
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
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
        print("\n\n###### \nScreen Width: \(screenWidth)\n########\n")
        switch screenWidth {
        case _ where screenWidth < 350: // iPhone 5 or 5S or 5C or SE
            _ = starGroup.anchor(titleLabel.bottomAnchor, left: cardView.leftAnchor, bottom: cardView.bottomAnchor, right: cardView.rightAnchor, topConstant: 10, leftConstant: 15, bottomConstant: 20, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        case _ where screenWidth > 350 && screenWidth < 380: // iPhone 6 or 7 or 8
            _ = starGroup.anchor(titleLabel.bottomAnchor, left: cardView.leftAnchor, bottom: cardView.bottomAnchor, right: cardView.rightAnchor, topConstant: 10, leftConstant: 45, bottomConstant: 20, rightConstant: 45, widthConstant: 0, heightConstant: 0)
        default:
            _ = starGroup.anchor(titleLabel.bottomAnchor, left: cardView.leftAnchor, bottom: cardView.bottomAnchor, right: cardView.rightAnchor, topConstant: 10, leftConstant: 55, bottomConstant: 20, rightConstant: 55, widthConstant: 0, heightConstant: 0)
        }
    }
    
    fileprivate func prepareStarButton(for star: UIButton, index: Int) {
        star.setImage(#imageLiteral(resourceName: "DefaultState"), for: .normal)
        star.addTarget(self, action: #selector(didSelectStarAt(sender:)), for: .touchUpInside)
        star.widthAnchor.constraint(equalToConstant: 35.0).isActive = true
        star.heightAnchor.constraint(equalToConstant: 35.0).isActive = true
        starGroup.addArrangedSubview(star)
    }
    
    @objc func didSelectStarAt(sender: UIButton) {
        var counter = 0
        for star in stars {
            star.setImage(#imageLiteral(resourceName: "ApprovalState"), for: .normal)
            counter += 1
            if star == sender {
                break
            }
            if (counter >= 4) {
                openInAppRating()
            }
        }
        for star in stars {
            counter -= 1
            if (counter < 0) {
                star.setImage(#imageLiteral(resourceName: "DisapprovalState"), for: .normal)
            }
        }
    }
    
    fileprivate func openInAppRating() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        }
    }
}
