//
//  APICaller.swift
//  News
//
//  Created by MAHESHWARAN on 27/05/23.
//

import Foundation

final class APICaller {
  
  static let shared = APICaller()
  
  let topHeadlinesURL = "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=---EnterAPIKey-----"
  
  let businessURL = "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=---EnterAPIKey-----"
  
  private init(){ }
  
  // MARK: - Get News Details
  
  public func getTopStories(completion: @escaping (Result<[Article], Error>) -> Void) {
    guard let url = URL(string: topHeadlinesURL) else { return }
    
    let task = URLSession.shared.dataTask(with: url) { data, _ , error in
      
      if let error {
        completion(.failure(error))
      } else if let data {
        do {
          let result = try JSONDecoder().decode(APIRespone.self, from: data)
          completion(.success(result.articles))
        }
        catch {
          completion(.failure(error))
        }
      }
    }
    task.resume()
  }
  
  public func getTopBusiness(completion: @escaping (Result<[Article], Error>) -> Void){
    guard let url = URL(string: businessURL) else { return }
    
    let task = URLSession.shared.dataTask(with: url) { data, _ , error in
      
      if let error {
        completion(.failure(error))
      } else if let data {
        do {
          let result = try JSONDecoder().decode(APIRespone.self, from: data)
          completion(.success(result.articles))
        }
        catch {
          completion(.failure(error))
        }
      }
    }
    task.resume()
  }
  
  public func search(with query: String, isFromNews: Bool = false, completion: @escaping (Result<[Article], Error>) -> Void){
    guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
    
    let urlstring = isFromNews ? topHeadlinesURL : businessURL
    
    guard let url = URL(string: urlstring + "&q=\(query)") else { return }
    
    let task = URLSession.shared.dataTask(with: url) { data, _ , error in
      
      if let error {
        completion(.failure(error))
      } else if let data {
        do {
          let result = try JSONDecoder().decode(APIRespone.self, from: data)
          completion(.success(result.articles))
        }
        catch {
          completion(.failure(error))
        }
      }
    }
    task.resume()
  }
}

// MARK: - Article

struct APIRespone: Codable {
  let articles: [Article]
}

struct Article: Codable {
  let source: Source
  
  let title: String
  let description: String?
  let url: String?
  let urlToImage: String?
  let publishedAt: String
}

struct Source: Codable {
  let name: String
}
