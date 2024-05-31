//
//  DataState.swift
//  QrCode
//
//  Created by P. Nam on 29/05/2024.
//

enum DataState<Data> {
    case loading
    case success(data: Data)
    case error(error: Error?)
}

extension DataState {
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        case .success:
            return false
        case .error:
            return false
        }
    }
    
    var data: Data? {
        guard case .success(let data) = self else { return nil }
        return data
    }
    
    var error: Error? {
        guard case .error(let error) = self else { return nil }
        return error
    }
}
