//
//  Odd.swift
//  RealTimeOddsDisplayer
//
//  Created by 黃昭銘 on 2025/8/7.
//

import Foundation

enum OddsSource {
    case initial
    case live
}

struct Odd {
    let matchID: String
    let teamAOdds: Float
    let teamBOdds: Float
    let updateAt: Date
    let source: OddsSource
}
