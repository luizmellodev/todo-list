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
    let baseURL = URL(string: "https://fastapi-learn-dm10.onrender.com")!
    
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
            Logger.error("Invalid URL for endpoint: \(endpoint)")
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
            Logger.error("Failed to build request for endpoint: \(endpoint)")
            return Fail(error: NetworkError.badServerResponse).eraseToAnyPublisher()
        }
        
        Logger.info("📤 Sending request to: \(url)")
        if let body = body, let bodyString = String(data: body, encoding: .utf8) {
            Logger.info("📄 Request body: \(bodyString)")
        }
        Logger.info("🔑 Request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    Logger.error("⚠️ Error: Bad server response (status code: \(String(describing: (result.response as? HTTPURLResponse)?.statusCode)))")
                    throw NetworkError.badServerResponse
                }
                return result.data
            }
            .handleEvents(receiveOutput: { data in
                Logger.prettyPrintJSON(from: data)
            })
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                Logger.error("❌ Error decoding \(T.self): \(error)")
                return error as? NetworkError ?? NetworkError.decodingError
            }
            .eraseToAnyPublisher()
    }
}
