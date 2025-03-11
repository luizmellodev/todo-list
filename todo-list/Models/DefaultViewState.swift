//
//  DefaultViewState.swift
//  todo-list
//
//  Created by Luiz Mello on 15/12/24.
//


public enum DefaultViewState: Equatable {
    case loading
    case started
    case dataChanged
    case requestFailed
    case requestSucceeded
    case noConnection
    case paginatedLoading
    case emptyResult
    case error(String)
    case loggedIn
}
