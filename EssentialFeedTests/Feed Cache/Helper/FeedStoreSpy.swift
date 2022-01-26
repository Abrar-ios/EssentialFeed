//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Abrar on 26/01/2022.
//

import Foundation
import EssentialFeed

 class FeedStoreSpy : FeedStore {
    enum ReceivedMessage:  Equatable {
        case deleteCacheFeed
        case insert([LocalFeedImage], Date)
        case  retrieve
    }
    
    private(set) var receivedMessages  = [ReceivedMessage]()
    
    private var deletionCompletions = [deletionCompletion]()
    
    private var insertionCompletions = [insertionCompletion]()
     
    private var retrievalCompletions = [retrievalCompletion]()
    
    func deleteCachedFeed(completion: @escaping deletionCompletion) {
        deletionCompletions.append(completion)
        receivedMessages.append(.deleteCacheFeed)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0){
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping insertionCompletion) {
        insertionCompletions.append(completion)
        receivedMessages.append(.insert(feed, timestamp))
    }
    
    func completeInsertion(with error: Error, at index: Int = 0){
        insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
     
     func retrieve(completion: @escaping retrievalCompletion) {
         retrievalCompletions.append(completion)
         receivedMessages.append(.retrieve)
     }
     
     func completeRetrieval(with error: Error, at index: Int = 0) {
         retrievalCompletions[index](error)
     }
     
     func completeRetrievalWithEmptyCache(at index: Int = 0) {
         retrievalCompletions[index](nil)
     }
}
