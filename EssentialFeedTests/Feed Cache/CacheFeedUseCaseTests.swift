//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Abrar on 23/01/2022.
//

import Foundation
import XCTest
import EssentialFeed

class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate  = currentDate
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Void) {
        store.deleteCachedFeed {[unowned self] error in
            completion(error)
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    typealias deletionCompletion = (Error?) -> Void
    
    enum ReceivedMessage:  Equatable {
        case deleteCacheFeed
        case insert([FeedItem], Date)
    }
    
    private(set) var receivedMessages  = [ReceivedMessage]()
    
    private var deletionCompletions = [deletionCompletion]()
    
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
    
    func insert(_ items: [FeedItem], timestamp: Date) {
        receivedMessages.append(.insert(items, timestamp))
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageStoreUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let items  = [uniqueItem(), uniqueItem()];
        let (sut, store) = makeSUT()
        
        sut.save(items) { _ in };
        
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
        
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items  = [uniqueItem(), uniqueItem()];
        let (sut, store) = makeSUT()
        let DeletionError = anyNSError()
        sut.save(items) { _ in };
        store.completeDeletion(with: DeletionError)
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion(){
        let timestamp = Date()
        let items  = [uniqueItem(), uniqueItem()];
        let (sut, store) = makeSUT(currentDate: {timestamp})
        sut.save(items) { _ in };
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.receivedMessages, [.deleteCacheFeed, .insert(items, timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let items  = [uniqueItem(), uniqueItem()];
        let (sut, store) = makeSUT()
        let DeletionError = anyNSError()
        let exp = expectation(description: "wait for save completion")
        
        var receivedError : Error?
        sut.save(items) { error in
            receivedError  = error
            exp.fulfill()
        }
        store.completeDeletion(with: DeletionError)
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, DeletionError)
    }

    // Mark: - Helper
    
    private func makeSUT(currentDate: @escaping () -> Date =  Date.init, file: StaticString = #filePath, line: UInt = #line) -> (sut: LocalFeedLoader, store:FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "ay", imageUrl: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
}
