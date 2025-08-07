//
//  WebSocketClient.swift
//  RealTimeOddsDisplayer
//
//  Created by 黃昭銘 on 2025/8/7.
//

import Foundation

public enum WebSocketClientError: Error, Equatable {
    case connectionFailed(reason: String)
    case disconnected
    case timeout
    case invalidMessageFormat
    case decodingFailed
    case encodingFailed
    case unkown
}

public enum WebSocketConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case failed(WebSocketClientError)
}

public protocol WebSocketClient {
    var isConnected: Bool { get }
    
    var onStateChanged: ((WebSocketConnectionState) -> Void)? { get set }
    
    func connect()
    func disconnect()
    
    func send<T: Encodable>(_ message: T)
    func observeMessage<T: Decodable>(ofType type: T.Type, completion: @escaping (Result<T, WebSocketClientError>) -> Void)
}
