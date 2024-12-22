//
//  NetworkManagerProtocol.swift
//  todo-list
//
//  Created by Luiz Mello on 13/10/24.
//

import Foundation
import Combine

protocol NetworkManagerProtocol {
    var baseURL: URL { get }
    
    func sendRequest<T: Decodable>(
        _ endpoint: String,
        method: String,
        parameters: [String: Any]?,
        authentication: String?,
        token: String?,
        body: Data?
    ) -> AnyPublisher<T, NetworkError>
}


