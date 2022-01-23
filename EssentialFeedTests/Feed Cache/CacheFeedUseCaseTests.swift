//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Abrar on 23/01/2022.
//

import Foundation
import XCTest

class LocalFeedLoader {
    
    init(store: FeedStore) {
        
    }
    
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteUponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
    
}
