//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Abrar on 24/11/2021.
//

import XCTest

class RemoteFeedLoader {
    
}

class HTTPClient {
    var requestedURL: URL?
}

class RemoteFeedLoaderTests : XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClient()
         _ = RemoteFeedLoader()
        XCTAssertNil(client.requestedURL);
    }
}
