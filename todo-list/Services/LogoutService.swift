import Foundation
import Combine

protocol LogoutServiceProtocol {
    func logout(token: String) -> AnyPublisher<Bool, NetworkError>
}

class LogoutService: LogoutServiceProtocol {
    private let networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func logout(token: String) -> AnyPublisher<Bool, NetworkError> {
        return networkManager.sendRequest("/logout", method: "POST", parameters: nil, authentication: nil, token: token, body: nil)
            .map { (_: [String: String]) in true }
            .catch { _ in Just(false).setFailureType(to: NetworkError.self) }
            .eraseToAnyPublisher()
    }
}

