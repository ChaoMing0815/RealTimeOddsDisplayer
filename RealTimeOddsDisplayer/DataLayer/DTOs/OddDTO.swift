//
//  OddDTO.swift
//  RealTimeOddsDisplayer
//
//  Created by 黃昭銘 on 2025/8/7.
//

import Foundation

struct OddDTO: Codable {
    let matchID: String
    let teamAOdds: Float
    let teamBOdds: Float
    
    func toDomain(source: OddsSource, timestamp: Date = Date()) -> Odd {
        return Odd(
            matchID: matchID, 
            teamAOdds: teamAOdds,
            teamBOdds: teamBOdds, 
            updateAt: timestamp,
            source: source)
    }
}
