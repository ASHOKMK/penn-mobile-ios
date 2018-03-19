//
//  HomeFeedbackCellItem.swift
//  PennMobile
//
//  Created by Zhilei Zheng on 3/18/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

final class HomeFeedbackCellItem: HomeCellItem {
    func equals(item: HomeCellItem) -> Bool {
        return item is HomeFeedbackCellItem
    }
    
    static var jsonKey: String {
        return "feedback"
    }
    
    static func getItem(for json: JSON?) -> HomeCellItem? {
        return HomeFeedbackCellItem()
    }
    
    static var associatedCell: ModularTableViewCell.Type {
        return HomeFeedbackCell.self
    }
    
    
}
