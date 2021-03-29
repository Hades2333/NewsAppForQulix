//
//  NetworkError.swift
//  newsForQulix
//
//  Created by Hellizar on 29.03.21.
//

import Foundation

enum NetworkError: Error {
    case incorrectUrl
    case networkError(error: Error)
    case serverError(statusCode: Int)
    case parsingError(error: Error)
    case unknown
}

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .incorrectUrl:
            return NSLocalizedString("Yout URL is not correct",
                                     comment: "")
        case .networkError(let error):
            return NSLocalizedString("Network connection error, named: \(error)",
                                     comment: "")
        case .serverError(statusCode: let statusCode):
            return NSLocalizedString("An error occurred on the server side with status: \(statusCode)",
                                     comment: "")
        case .parsingError(error: let error):
            return NSLocalizedString("Parsing data failed with error: \(error)",
                                     comment: "")
        case .unknown:
            return NSLocalizedString("An unknown error occurred",
                                     comment: "")
        }
    }
}
