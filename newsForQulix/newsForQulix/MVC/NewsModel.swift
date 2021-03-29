//
//  NewsModel.swift
//  newsForQulix
//
//  Created by Hellizar on 29.03.21.
//

import UIKit

// MARK: - Welcome
struct Welcome: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
}

// MARK: - Article
struct Article: Codable {
    let source: Source
    let author: String?
    let title, articleDescription: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String?
    let content: String?

    enum CodingKeys: String, CodingKey {
        case source, author, title
        case articleDescription = "description"
        case url, urlToImage, publishedAt, content
    }
}

// MARK: - Source
struct Source: Codable {
    let id: String?
    let name: String
}

//MARK: - My structure
struct myModel {
    let urlToImage: String?
    let title, articleDescription: String
}

