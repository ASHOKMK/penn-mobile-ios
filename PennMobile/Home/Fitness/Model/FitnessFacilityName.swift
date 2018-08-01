//
//  FitnessFacilityName.swift
//  PennMobile
//
//  Created by dominic on 7/19/18.
//  Copyright © 2018 PennLabs. All rights reserved.
//

import Foundation

enum FitnessFacilityName: String, Codable {
    
    case sherr =       "Sheerr Pool"
    case ringe =       "Ringe-CLOSED"
    case climbing =    "Climbing Wall"
    case membership =  "Membership Services"
    case fox =         "Fox Fitness"
    case pottruck =    "Pottruck Hours"
    case rockwell =    "Basketball - Rockwell"
    case unknown
    
    static let all = [pottruck, fox, sherr, ringe, climbing, membership]
    
    static func getFacilityName(for facilityName: DiningVenueName) -> String {
        return facilityName.rawValue
    }
    
    static func getFacilityName(for apiName: String) -> FitnessFacilityName {
        for facility in FitnessFacilityName.all {
            if apiName.contains(facility.rawValue) {
                return facility
            }
        }
        return .unknown
    }
}