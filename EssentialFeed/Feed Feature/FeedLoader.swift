//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Abrar on 21/11/2021.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedItem])
    case failure(Error)
}

protocol FeedLoader {
    func load(completion: @escaping(LoadFeedResult) -> Void)
}
