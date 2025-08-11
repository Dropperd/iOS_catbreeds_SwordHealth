//
//  BreedsListViewModel.swift
//  CatChallenge
//
//  Created by user943027 on 8/11/25.
//

import Foundation
import SwiftData

@Observable
final class BreedsListViewModel {
    var breeds: [CatBreed] = []
    var searchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    var filteredBreeds: [CatBreed] {
        guard !searchText.isEmpty else { return breeds }
        return breeds.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    @MainActor
    func loadBreeds() async {
        guard breeds.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let dtos = try await CatAPIService.shared.fetchBreeds()
            
            for dto in dtos {
                if breeds.contains(where: { $0.apiId == dto.id }) { continue }
                let (min, max) = CatAPIService.shared.parseLifeSpan(dto.life_span)
                let model = CatBreed(
                    apiId: dto.id,
                    name: dto.name,
                    origin: dto.origin,
                    temperament: dto.temperament,
                    breedDescription: dto.description,
                    imageURL: dto.image?.url,
                    lifeSpanMin: min,
                    lifeSpanMax: max,
                    isFavorite: false
                )
                modelContext.insert(model)
            }
            
            try modelContext.save()
            fetchLocalBreeds()
        } catch {
            errorMessage = "Failed to load breeds: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchLocalBreeds() {
        let descriptor = FetchDescriptor<CatBreed>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            breeds = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch local breeds: \(error)")
        }
    }
    
    func toggleFavorite(_ breed: CatBreed) {
        breed.isFavorite.toggle()
        
        do {
            try modelContext.save()
        } catch {
            print("Failed to save favorite change: \(error)")
        }
    }
}
