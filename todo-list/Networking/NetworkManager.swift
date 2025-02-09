//
//  NetworkManager.swift
//  todo-list
//
//  Created by Luiz Mello on 13/10/24.
//

import Foundation
import Combine

class NetworkManager: NetworkManagerProtocol {
    
    static let shared = NetworkManager()
    let baseURL = URL(string: "http://localhost:8000")!
    
    private init() {}
    
    func sendRequest<T: Decodable>(
        _ endpoint: String,
        method: String,
        parameters: [String: Any]? = nil,
        authentication: String?,
        token: String?,
        body: Data? = nil
    ) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            logError("Invalid URL for endpoint: \(endpoint)")
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        guard let request = RequestBuilder.buildRequest(
            url: url,
            httpMethod: method,
            token: token,
            parameters: parameters,
            authentication: authentication,
            body: body
        ) else {
            logError("Failed to build request for endpoint: \(endpoint)")
            return Fail(error: NetworkError.badServerResponse).eraseToAnyPublisher()
        }
        
        // Log da requisição enviada
        logInfo("📤 Sending request to: \(url)")
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            logInfo("📄 Request body: \(bodyString)")
        }
        logInfo("🔑 Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    self.logError("⚠️ Error: Bad server response (status code: \(String(describing: (result.response as? HTTPURLResponse)?.statusCode)))")
                    throw NetworkError.badServerResponse
                }
                return result.data
            }
            .handleEvents(receiveOutput: { data in
                // Log da resposta recebida
                if let jsonString = String(data: data, encoding: .utf8) {
                    self.logInfo("✅ Response received:\n\(jsonString)")
                    self.logSeparator()
                }
            })
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                self.logError("❌ Error decoding \(T.self): \(error)")
                return error as? NetworkError ?? NetworkError.decodingError
            }
            .eraseToAnyPublisher()
    }
    
    // Função para logar mensagens de sucesso
    private func logInfo(_ message: String) {
        print("\n\("🌟".green) \(message)\n")
    }
    
    // Função para logar mensagens de erro
    private func logError(_ message: String) {
        print("\n\("🚨".red) \(message)\n")
    }
    
    // Função para logar separadores de resposta
    private func logSeparator() {
        print("\n\("-----------------------------".yellow)\n")
    }
}

extension String {
    var red: String { return "\u{001B}[0;31m\(self)\u{001B}[0;39m" }
    var green: String { return "\u{001B}[0;32m\(self)\u{001B}[0;39m" }
    var yellow: String { return "\u{001B}[0;33m\(self)\u{001B}[0;39m" }
    var blue: String { return "\u{001B}[0;34m\(self)\u{001B}[0;39m" }
}
