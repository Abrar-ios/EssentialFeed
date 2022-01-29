//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Abrar on 29/01/2022.
//

import Foundation
import XCTest
import EssentialFeed
 
class CodeableFeedStore {
    
    private struct Cache: Codable {
        let feed : [CodableFeedImage]
        let timestamp : Date
        
        var localFeed: [LocalFeedImage] {
            return feed.map{ $0.local }
        }
    }
    
    private struct CodableFeedImage : Codable {
        private let id: UUID
        private let description: String?
        private let location: String?
        private let url: URL
        
        init(_ image: LocalFeedImage){
            id = image.id
            description = image.description
            location = image.location
            url = image.url
        }
        
        var local: LocalFeedImage {
            return LocalFeedImage(id: id, description: description, location: location, url: url)
        }
    }
    
    private let storeURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    func retrieve(completion: @escaping FeedStore.retrievalCompletion){
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        let cache = try! decoder.decode(Cache.self, from: data)
        completion(.found(feed: cache.localFeed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.insertionCompletion){
        let encoder = JSONEncoder()
        let cache = Cache(feed: feed.map(CodableFeedImage.init), timestamp: timestamp)
        let encoded = try! encoder.encode(cache)
        try! encoded.write(to: storeURL)
        completion(nil)
    }
    
}

class CodableFeedStoreTests: XCTestCase  {
    
    override func setUp() {
        super.setUp()
        
        let storeURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
        try? FileManager.default.removeItem(at: storeURL)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache(){
     
        let sut = CodeableFeedStore()
        let exp = expectation(description: "wait for cache retrieval")
        
        sut.retrieve{ result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("Expected empty result, got \(result) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectOnEmptyCache(){
     
        let sut = CodeableFeedStore()
        let exp = expectation(description: "wait for cache retrieval")
        sut.retrieve { firstResult in
            sut.retrieve{ secondResult in
                switch (firstResult,secondResult) {
                case (.empty,.empty):
                    break
                default:
                    XCTFail("Expected retrieving twice from cache to deliver same empty result, got \(firstResult) and \(secondResult) instead")
                }
                
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues(){
     
        let sut = CodeableFeedStore()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let exp = expectation(description: "wait for cache retrieval")
        sut.insert(feed, timestamp: timestamp){ insertionError in
            XCTAssertNil(insertionError, "Expected feed to be inserted successfully")
            sut.retrieve{ retrieveResult in
                switch retrieveResult {
                case let .found(retrieveFeed, retrieveTimeStamp):
                    XCTAssertEqual(retrieveFeed, feed)
                    XCTAssertEqual(retrieveTimeStamp, timestamp)
                default:
                    XCTFail("Expected found result with feed \(feed) and timestamp \(timestamp), got \(retrieveResult) instead")
                }
                
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    
}