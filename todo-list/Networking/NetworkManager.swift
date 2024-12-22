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
            return Fail(error: NetworkError.badServerResponse).eraseToAnyPublisher()
        }
        
        print(request)
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    throw NetworkError.badServerResponse
                }
                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                print("erro: \(T.self)")
                return error as? NetworkError ?? NetworkError.decodingError
            }
            .eraseToAnyPublisher()
    }
}
