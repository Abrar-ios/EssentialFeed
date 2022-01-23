//
//  XCTestCase+MemoryLeakTracking.swift
//  EssentialFeedTests
//
//  Created by Abrar on 08/12/2021.
//

import Foundation
import XCTest

extension XCTestCase {
    
    func trackForMemoryLeaks(_ instance: AnyObject,file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock {[weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
}
