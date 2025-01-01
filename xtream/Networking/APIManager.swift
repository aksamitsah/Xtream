//
//  APIManager.swift
//  xtream
//
//  Created by Amit Shah on 20/12/24.
//

import Foundation

typealias Handler<T> = (Result<T, HandleError>) -> Void

enum HTTPMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}

enum HTTPScheme: String {
    case http
    case https
}

class APIManager {
    
    class func buildURL(endpoint: API) -> URLComponents {
        var components = URLComponents()
        components.scheme = endpoint.scheme.rawValue
        components.host = endpoint.baseURL
        components.path = endpoint.path
        if let data = endpoint.parameters, !data.isEmpty {
            components.queryItems = data
        }
        return components
    }
    
    class func request<T: Decodable>(endpoint: API, completion: @escaping Handler<T>) {
        
        let components = buildURL(endpoint: endpoint)
        
        guard let url = components.url else {
            Log.error("URL creation error")
            completion(.failure(.invalidURL))
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        
        if let rowHeader = endpoint.headers, !rowHeader.isEmpty {
            for (key, value) in rowHeader {
                urlRequest.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        if endpoint.body != nil {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = endpoint.body
        }
        
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            
            guard let data, error == nil else {
                completion(.failure(.message(error)))
                Log.error(error)
                return
            }
            
            guard let response = response as? HTTPURLResponse,
                  200 ... 299 ~= response.statusCode else {
                
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let sendback = json["message"] as? String {
                        completion(.failure(.custom(sendback)))
                    } else {
                        completion(.failure(.invalidResponse))
                    }
                } catch {
                    completion(.failure(.invalidResponse))
                }
                Log.error("Failed Response Code")
                return
                
            }
            
            do {
                let response = try JSONDecoder().decode(T.self, from: data)
                completion(.success(response))
                Log.info("Sucessful featched")
            } catch {
                completion(.failure(.message(error)))
                Log.error(error)
            }
        }
        
        dataTask.resume()
    }
}
