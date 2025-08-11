//
//  FavoritesViewModel.swift
//  CatChallenge
//
//  Created by user943027 on 8/11/25.
//

import Foundation
import SwiftData

@Observable
final class FavoritesViewModel {
    var favoriteBreeds: [CatBreed] = []
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchFavorites()
    }
    
    var averageLifespanText: String {
        let values = favoriteBreeds.compactMap {
            Double($0.lifeSpanMin ?? $0.lifeSpanMax ?? 0)
        }.filter { $0 > 0 }
        
        guard !values.isEmpty else { return "—" }
        let avg = values.reduce(0, +) / Double(values.count)
        return String(format: "%.1f", avg)
    }
    
    func fetchFavorites() {
        let descriptor = FetchDescriptor<CatBreed>(
            predicate: #Predicate { $0.isFavorite == true },
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            favoriteBreeds = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch favorites: \(error)")
        }
    }
    
    func removeFromFavorites(_ breed: CatBreed) {
        breed.isFavorite = false
        
        do {
            try modelContext.save()
            fetchFavorites()
        } catch {
            print("Failed to remove from favorites: \(error)")
        }
    }
}
