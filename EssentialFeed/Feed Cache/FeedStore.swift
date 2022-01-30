//
//  FeedStore.swift
//  EssentialFeed
//
//  Created by Abrar on 25/01/2022.
//

import Foundation

public enum RetrieveCachedFeedResult {
    case empty
    case found(feed: [LocalFeedImage], timestamp: Date)
    case failure(Error)
}

public protocol FeedStore {
    typealias deletionCompletion = (Error?) -> Void
    typealias insertionCompletion = (Error?) -> Void
    typealias retrievalCompletion = (RetrieveCachedFeedResult) -> Void
    
    ///The completion handler can be invoked in any thread
    ///Clients are responsible to dispatch to appropriate threads, if needed.
    func deleteCachedFeed(completion: @escaping deletionCompletion)
    
    ///The completion handler can be invoked in any thread
    ///Clients are responsible to dispatch to appropriate threads, if needed.
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping insertionCompletion)
    
    ///The completion handler can be invoked in any thread
    ///Clients are responsible to dispatch to appropriate threads, if needed.
    func retrieve(completion: @escaping retrievalCompletion)
}

