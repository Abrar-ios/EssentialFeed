//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Abrar on 21/11/2021.
//

import Foundation

public struct FeedItem: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageUrl: URL
}
