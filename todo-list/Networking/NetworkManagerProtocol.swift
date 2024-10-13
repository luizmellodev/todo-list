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
    
    func fetch<T: Decodable>(from endpoint: String) -> AnyPublisher<T, Error>
    func create<T: Encodable>(to endpoint: String, body: T) -> AnyPublisher<Void, Error>
}
