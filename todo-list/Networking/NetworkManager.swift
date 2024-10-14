//
//  NetworkManager.swift
//  todo-list
//
//  Created by Luiz Mello on 13/10/24.
//

import Foundation
import Combine

class NetworkManager: NetworkManagerProtocol {
    
    let baseURL = URL(string: "http://localhost:8000")!
    
    static let shared = NetworkManager()

    func fetch<T: Decodable>(from endpoint: String) -> AnyPublisher<T, NetworkError> {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                    throw NetworkError.badServerResponse
                }
                return result.data
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                return error as? NetworkError ?? NetworkError.decodingError
            }
            .eraseToAnyPublisher()
    }

    func create<T: Encodable>(to endpoint: String, body: T) -> AnyPublisher<Void, NetworkError> {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONEncoder().encode(body)
            request.httpBody = jsonData
        } catch {
            return Fail(error: NetworkError.decodingError).eraseToAnyPublisher()
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { result in
                guard let response = result.response as? HTTPURLResponse, response.statusCode == 201 else {
                    throw NetworkError.badServerResponse
                }
                return result.data
            }
            .map { _ in }
            .mapError { error in
                return error as? NetworkError ?? NetworkError.decodingError
            }
            .eraseToAnyPublisher()
    }
    
    func delete(from endpoint: String) -> AnyPublisher<Void, NetworkError> {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    throw NetworkError.badServerResponse
                }
                return
            }
            .map { _ in () }
            .mapError { error in
                return error as? NetworkError ?? .badServerResponse
            }
            .eraseToAnyPublisher()
    }
}
