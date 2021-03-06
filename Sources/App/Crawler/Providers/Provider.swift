//
//  Provider.swift
//  App
//

import Async
import Vapor
import NIO
import Kanna

protocol Provider {

    typealias Details = (
        id: String,
        title: String,
        price: String,
        image: String
    )

    static var baseURL: String { get }
    static var searchURL: String { get }
    static var listx: String { get }
    static var detailsx: Details { get }

    static func resolve(page: Int, in app: Application) -> Future<[House]>?
    static func resolve(element: Kanna.XMLElement) -> House?
}

extension Provider {

    static func resolve(page: Int = 0, in app: Application) -> Future<[House]>? {
        return try? app.client().get(searchURL).map { response in
            // return try response.content.decode(String.self)
            return response.http.body
        }.map { content -> HTMLDocument? in
            guard let data = content.data else { return nil }
            let doc = try? HTML(html: data, encoding: .utf8)
            print(doc?.title ?? "")
            return doc
        }.map { document -> [House] in
            typealias Item = (title: String, href: String)
            guard let articles = document?.xpath(listx) else { return [] }
            print("articles \(articles.count)")
            let houses: [House] = articles.compactMap { self.resolve(element: $0) }
            print("houses \(articles)")
            return houses
        }
    }
}
