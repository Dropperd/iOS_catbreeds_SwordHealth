//
//  Item.swift
//  CatChallenge
//
//  Created by user943027 on 8/10/25.
//

import Foundation
import SwiftData

@Model
final class CatBreed {
    // avoid duplicates
    @Attribute(.unique) var apiId: String

    var name: String
    var origin: String?
    var temperament: String?
    var breedDescription: String?
    var imageURL: String? // image
    var lifeSpanMin: Int?
    var lifeSpanMax: Int?
    var isFavorite: Bool

    init(apiId: String,
         name: String,
         origin: String? = nil,
         temperament: String? = nil,
         breedDescription: String? = nil,
         imageURL: String? = nil,
         lifeSpanMin: Int? = nil,
         lifeSpanMax: Int? = nil,
         isFavorite: Bool = false) {
        self.apiId = apiId
        self.name = name
        self.origin = origin
        self.temperament = temperament
        self.breedDescription = breedDescription
        self.imageURL = imageURL
        self.lifeSpanMin = lifeSpanMin
        self.lifeSpanMax = lifeSpanMax
        self.isFavorite = isFavorite
    }
    //calculate average lifespan and if there are only 1 value
    var lifeSpanAverage: Int? {
        if let low = lifeSpanMin, let high = lifeSpanMax {
            return Int(round(Double(low + high) / 2.0))
        }
        return lifeSpanMin ?? lifeSpanMax
    }
}
