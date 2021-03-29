//
//  NetworkManager.swift
//  newsForQulix
//
//  Created by Hellizar on 29.03.21.
//

import Foundation

class NetworkManager {

    // MARK: - Static
    static let shared = NetworkManager()

    // MARK: - Variables
    private let baseUrl: String = "https://newsapi.org/v2/everything?"
    private let apiKey: String = "d346b908fbb7493fa9cb87727967ef37"
    private lazy var session = URLSession(configuration: .default)

    // MARK: - Initialization
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
    }

    // MARK: - Methods
    var simpleCounter: Int = 0
    var dayCounter = Date()
    var isPaginating: Bool = false

    func request<Generic: Decodable>(pagination: Bool = false,
                                     successHandler: @escaping (Generic) -> Void,
                                     errorHandler: @escaping (NetworkError) -> Void) {
        if pagination {
            self.isPaginating = true
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 3, execute: { [weak self] in
            guard let self = self else {return}
            guard self.simpleCounter < 7 else {
                return
            }
            self.simpleCounter += 1


            let day = self.dayCounter
            let iso8601DateFormatter = ISO8601DateFormatter()
            iso8601DateFormatter.formatOptions = [.withYear, .withMonth, .withDay]
            let formatedDay = iso8601DateFormatter.string(from: day)
            print(formatedDay)

            guard let fullUrl = URL(string: "\(self.baseUrl)q=from=\(formatedDay)&apiKey=\(self.apiKey)") else {
                errorHandler(.incorrectUrl)
                return
            }
            print(fullUrl)

            let request = URLRequest(url: fullUrl)
            let dataTask = self.session.dataTask(with: request) { [weak self] data, response, error in
                guard let self = self else { return }
                if let error: Error = error {

                    DispatchQueue.main.async {
                        errorHandler(.networkError(error: error))
                    }
                    return
                } else if let data: Data = data,
                          let response: HTTPURLResponse = response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200..<300:
                        // Success server response handling
                        do {
                            let model = try JSONDecoder().decode(Generic.self, from: data)
                            self.dayCounter = day.dayBefore
                            DispatchQueue.main.async {
                                successHandler(model)
                            }
                        } catch let error {
                            DispatchQueue.main.async {
                                errorHandler(.parsingError(error: error))
                            }
                        }
                        if pagination {
                            self.isPaginating = false
                        }
                    case 400..<500:
                        // TODO: - response model error handling
                        break
                    case 500...:
                        // Handle server errors
                        DispatchQueue.main.async {
                            errorHandler(.serverError(statusCode: response.statusCode))
                        }
                    default:
                        DispatchQueue.main.async {
                            errorHandler(.unknown)
                        }
                    }
                }
            }
            dataTask.resume()
        })
    }
}
