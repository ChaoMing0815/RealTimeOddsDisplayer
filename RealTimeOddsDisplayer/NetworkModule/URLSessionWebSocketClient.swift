//
//  URLSessionWebSocketClient.swift
//  RealTimeOddsDisplayer
//
//  Created by 黃昭銘 on 2025/8/7.
//

import Foundation

public class URLSessionWebSocketClient: WebSocketClient {
    public private(set) var isConnected: Bool = false
    public var onStateChanged: ((WebSocketConnectionState) -> Void)?
    
    private let url: URL
    private var task: URLSessionWebSocketTask?
    private let session: URLSession
    private var messageHandler: ((Result<Data, WebSocketClientError>) -> Void)?
    
    public init( url: URL, session: URLSession = .shared) {
        self.url = url
        self.session = session
    }
    
    public func connect() {
        guard !isConnected else { return }
        
        task = session.webSocketTask(with: url)
        task?.resume()
        
        isConnected = true
        onStateChanged?(.connected)
        
        listen()
    }
    
    public func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        isConnected = false
        onStateChanged?(.disconnected)
    }
    
    public func send<T>(_ message: T) where T : Encodable {
        guard isConnected else {
            onStateChanged?(.failed(.disconnected))
            return
        }
        
        do {
            let data = try JSONEncoder().encode(message)
            guard let string = String(data: data, encoding: .utf8) else {
                onStateChanged?(.failed(.encodingFailed))
                return
            }
            task?.send(.string(string)) { [weak self] error in
                if let error = error {
                    self?.onStateChanged?(.failed(.connectionFailed(reason: error.localizedDescription)))
                }
            }
        } catch {
            onStateChanged?(.failed(.encodingFailed))
        }
    }
    
    public func observeMessage<T>(ofType type: T.Type, completion: @escaping (Result<T, WebSocketClientError>) -> Void) where T : Decodable {
        messageHandler = { result in
            switch result {
            case .success(let data):
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(.decodingFailed))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private helpers
extension URLSessionWebSocketClient {
    private func listen() {
        task?.receive { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let message):
                switch message {
                case.string(let text):
                    if let data = text.data(using: .utf8) {
                        self.messageHandler?(.success(data))
                    } else {
                        self.messageHandler?(.failure(.invalidMessageFormat))
                    }
                case .data(let data):
                    self.messageHandler?(.success(data))
                @unknown default:
                    self.messageHandler?(.failure(.invalidMessageFormat))
                }
                
            case .failure(let error):
                self.isConnected = false
                self.onStateChanged?(.failed(.connectionFailed(reason: error.localizedDescription)))
                return
            }
            
            self.listen()
        }
    }
}
