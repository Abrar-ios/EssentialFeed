//
//  FeedItemsMapper.swift
//  EssentialFeed
//
//  Created by Abrar on 07/12/2021.
//

import Foundation

internal final class FeedItemsMapper {
    
    private struct Root: Decodable {
        let items: [item]
        
        var feed : [FeedItem] {
            return  items.map{$0.item}
        }
    }

    private struct item: Decodable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL
        
        var item : FeedItem {
            return FeedItem(id: id, description: description, location: location, imageUrl: image)
        }
    }
   private static var OK_200: Int{return 200}
    
    internal static func map(_ data: Data, from response:HTTPURLResponse) -> RemoteFeedLoader.Result {
        
        guard response.statusCode == OK_200,
              let root = try? JSONDecoder().decode(Root.self, from: data)
        else {
            return .failure(.invalidData)
        }
        return .success(root.feed)
    }
    
}
