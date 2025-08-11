//
//  CatAPIService.swift
//  CatChallenge
//
//  Created by user943027 on 8/10/25.
//

import Foundation


enum CatAPIError: Error {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
}

final class CatAPIService {
    static let shared = CatAPIService()
    private let baseURL = "https://api.thecatapi.com/v1"
    private let apiKey = "DEMO-API-KEY"

    private var defaultHeaders: [String: String] {
        ["Content-Type": "application/json", "x-api-key": apiKey]
    }

    //load breeds from API
    func fetchBreeds(page: Int, limit: Int = 30) async throws -> [CatBreedDTO] {
        guard var components = URLComponents(string: "\(baseURL)/breeds") else {
            throw CatAPIError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        guard let url = components.url else {
            throw CatAPIError.invalidURL
        }

        var request = URLRequest(url: url)
        defaultHeaders.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw CatAPIError.invalidResponse
        }

        do {
            return try JSONDecoder().decode([CatBreedDTO].self, from: data)
        } catch {
            throw CatAPIError.decodingError(error)
        }
    }

    // Parse lifespan strings no formato "10 - 12"
     func parseLifeSpan(_ raw: String?) -> (Int?, Int?) {
        guard let raw = raw else { return (nil, nil) }
        //extract numbers
        let pattern = #"(\d{1,3})"#
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let nsRange = NSRange(raw.startIndex..<raw.endIndex, in: raw)
            let matches = regex.matches(in: raw, options: [], range: nsRange)
            
            let numbers = matches.compactMap { match -> Int? in
                if let range = Range(match.range, in: raw) {
                    return Int(String(raw[range]))
                }
                return nil
            }
            
            if numbers.count >= 2 {
                return (numbers[0], numbers[1])
            } else if numbers.count == 1 {
                return (numbers[0], numbers[0])
            } else {
                return (nil, nil)
            }
        } catch {
            return (nil, nil)
        }
    }
}
