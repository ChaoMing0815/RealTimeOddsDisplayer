//
//  MatchDTO.swift
//  RealTimeOddsDisplayer
//
//  Created by 黃昭銘 on 2025/8/7.
//

import Foundation

struct MatchDTO: Codable {
    let matchID: String
    let teamA: String
    let teamB: String
    let startTime: String
    
    func toDomain() -> Match? {
        guard let date = ISO8601DateFormatter().date(from: startTime) else { return nil }
        return Match(
            matchID: matchID,
            teamA: teamA,
            teamB: teamB,
            startTime: date
        )
    }
}
