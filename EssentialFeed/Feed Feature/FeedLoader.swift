//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Abrar on 21/11/2021.
//

import Foundation

enum LoadFeedResult  {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
