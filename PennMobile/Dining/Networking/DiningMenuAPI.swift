//
//  DiningMenuAPI.swift
//  PennMobile
//
//  Created by Dominic on 7/2/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import SwiftyJSON
import Foundation

class DiningMenuAPI: Requestable {
    
    static let instance = DiningMenuAPI()
    
    let diningMenuUrl = "https://api.pennlabs.org/dining/daily_menu/"
    
    func fetchDiningMenu(for venue: DiningVenueName, _ completion: @escaping (_ success: Bool) -> Void) {
        
        getRequest(url: (diningMenuUrl + String(venue.getID()))) { (dictionary) in
            if dictionary == nil {
                completion(false)
                return
            }
            
            let json = JSON(dictionary!)
            let success = DiningMenuData.shared.loadMenusForSingleVenue(with: json)
            
            completion(success)
        }
    }
}

extension DiningMenuData {
    
    fileprivate func loadMenusForSingleVenue(with json: JSON) -> Bool {
        
        dump(json)
        
        let name = json["name"].stringValue
        let venueName = DiningVenueName.getVenueName(for: name)
        if venueName == .unknown {
            return false
        }
        
        let today = DateFormatter.yyyyMMdd.string(from: Date())
        let todayJSON = json["dateHours"].array?.filter { json -> Bool in
            return json["date"].string == today
            }.first
        
        var hours = [OpenClose]()
        
        // Not open today
        if todayJSON == nil {
            self.load(hours: [], for: venueName)
        }
        
        guard let json = todayJSON, let timesJSON = json["meal"].array else {
            return false
        }
        
        var closedFlag = false
        var closedTime: OpenClose?
        
        for json in timesJSON {
            guard let type = json["type"].string, type == "Lunch" || type == "Brunch" || type == "Dinner" || type == "Breakfast" || type == "Late Night" || type == "Closed" || name.range(of: type) != nil, let open = json["open"].string, let close = json["close"].string else { continue }
            
            let longFormatter = DateFormatter()
            longFormatter.dateFormat = "yyyy-MM-dd"
            let todayString = longFormatter.string(from: Date())
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd:HH:mm:ss"
            formatter.timeZone = TimeZone(abbreviation: "EST")
            
            let openString = todayString + ":" + open
            let closeString = todayString + ":" + close
            
            guard let openDate = formatter.date(from: openString)?.adjustedFor11_59,
                let closeDate = formatter.date(from: closeString)?.adjustedFor11_59 else { continue }
            
            let time = OpenClose(open: openDate, close: closeDate)
            if type == "Closed" {
                closedFlag = true
                closedTime = time
            } else if !hours.containsOverlappingTime(with: time) {
                hours.append(time)
            }
        }
        
        if let closedTime = closedTime, closedFlag {
            hours = hours.filter { !$0.overlaps(with: closedTime) }
        }
        
        self.load(hours: hours, for: venueName)
        return true
    }
}
