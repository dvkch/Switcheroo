//
//  Sitemap.swift
//  Migrator
//
//  Created by Stanislas Chevallier on 04/11/2021.
//

import Foundation

class Sitemap {
    
    // MARK: Init
    init(urls: [URL] = [], ignoreQueries: Bool = false) {
        var cleanedUpURLs = urls
        if ignoreQueries {
            cleanedUpURLs = cleanedUpURLs.map(\.withoutQuery)
        }

        self.urls = Array(Set(cleanedUpURLs)).sorted()
        self.statuses = [:]
    }
    
    // MARK: Properties
    let urls: [URL]
    private var statuses: [URL: PathStatus]

    // MARK: Methods
    func status(for url: URL) -> PathStatus? {
        return statuses[url]
    }
}


