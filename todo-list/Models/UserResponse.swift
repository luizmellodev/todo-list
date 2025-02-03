//
//  UserResponse.swift
//  todo-list
//
//  Created by Luiz Mello on 03/02/25.
//

import Foundation

struct UserResponse: Decodable {
    let username: String
    let name: String
    let disabled: Bool
}
