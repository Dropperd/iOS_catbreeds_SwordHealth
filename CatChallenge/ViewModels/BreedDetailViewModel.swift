//
//  BreedDetailViewModel.swift
//  CatChallenge
//
//  Created by user943027 on 8/11/25.
//

import Foundation
import SwiftData

@Observable
final class BreedDetailViewModel {
    let breed: CatBreed
    private let modelContext: ModelContext
    
    init(breed: CatBreed, modelContext: ModelContext) {
        self.breed = breed
        self.modelContext = modelContext
    }
    
    func toggleFavorite() {
        breed.isFavorite.toggle()
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save favorite toggle: \(error)")
        }
    }
}
