//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Abrar on 25/01/2022.
//

import Foundation

public protocol FeedStore {
    typealias deletionCompletion = (Error?) -> Void
    typealias insertionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping deletionCompletion)
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping insertionCompletion)
}

