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
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed {[unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.currentDate())
            }
        }
    }
}

class FeedStore {
    typealias deletionCompletion = (Error?) -> Void
    var deleteCachedFeedCallCount = 0
    var insertions = [(items: [FeedItem], timestamp: Date)]()
    
    private var deletionCompletions = [deletionCompletion]()
    
    func deleteCachedFeed(completion: @escaping deletionCompletion) {
        deleteCachedFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, at index: Int = 0){
        deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insert(_ items: [FeedItem], timestamp: Date) {
        insertions.append((items, timestamp))
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteUponCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
    func test_save_requestsCacheDeletion() {
        let items  = [uniqueItem(), uniqueItem()];
        let (sut, store) = makeSUT()
        
        sut.save(items);
        
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
        
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let items  = [uniqueItem(), uniqueItem()];
        let (sut, store) = makeSUT()
        let DeletionError = anyNSError()
        sut.save(items);
        store.completeDeletion(with: DeletionError)
        XCTAssertEqual(store.insertions.count, 0)
    }
    
    func test_save_requestsNewCacheInsertionWithTimeStampOnSuccessfulDeletion(){
        let timestamp = Date()
        let items  = [uniqueItem(), uniqueItem()];
        let (sut, store) = makeSUT(currentDate: {timestamp})
        sut.save(items);
        store.completeDeletionSuccessfully()
        XCTAssertEqual(store.insertions.count, 1)
        XCTAssertEqual(store.insertions.first?.items, items)
        XCTAssertEqual(store.insertions.first?.timestamp, timestamp)
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
