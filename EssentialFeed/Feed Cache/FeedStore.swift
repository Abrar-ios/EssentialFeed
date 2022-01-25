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


public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageUrl: URL
    
    public init(id:UUID, description: String?, location: String?, imageUrl: URL){
        self.id = id
        self.description = description
        self.location = location
        self.imageUrl = imageUrl
    }
}
