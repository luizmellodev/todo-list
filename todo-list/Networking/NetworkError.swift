//
//  NetworkError.swift
//  todo-list
//
//  Created by Luiz Mello on 13/10/24.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case badServerResponse
    case decodingError
    case encodingError
    case unknown(Error)
}
