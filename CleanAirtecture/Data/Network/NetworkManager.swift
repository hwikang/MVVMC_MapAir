//
//  NetworkManager.swift
//  CleanAirtecture
//
//  Created by paytalab on 7/1/24.
//

import Foundation
import Alamofire

final public class NetworkManager {
    private let session: Session = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        return Session(configuration: config)
    }()
  
    func fetchData<T:Decodable> (url: String, method: HTTPMethod, parameters: Parameters? = nil,
                                 encoding: ParameterEncoding = URLEncoding.default) async -> Result<T, NetworkError> {
        guard let url = URL(string: url) else {
            return .failure(NetworkError.urlError)
        }
        print("url - \(url)")
      
        let result = await session.request(url, method: method, parameters: parameters, encoding: encoding)
            .validate().serializingData().response
        if let error = result.error { return .failure(NetworkError.requestFailed(error.errorDescription ?? ""))}
        guard let data = result.data else { return .failure(NetworkError.dataNil) }
        guard let response =  result.response else { return .failure(NetworkError.invalid) }
    
        if 200..<400 ~= response.statusCode {
            do {
                let data = try JSONDecoder().decode(T.self, from: data)
                return .success(data)
            } catch {
                return .failure(NetworkError.failToDecode(error.localizedDescription))
            }
        } else {
            debugPrint(result.error?.localizedDescription)
            return .failure(NetworkError.serverError(response.statusCode))
        }
    }
}
