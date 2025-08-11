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
    
    // state of the page
    private var currentPage: Int = 0
    private let pageSize: Int = 20
    private var isLastPage: Bool = false
    private var isLoadingPage: Bool = false
    private var hasLoadedInitialData: Bool = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    var filteredBreeds: [CatBreed] {
        guard !searchText.isEmpty else { return breeds }
        return breeds.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    @MainActor
    func loadInitialBreeds() async {
        
        //  load the first items coredata
        fetchLocalBreeds(limit: pageSize)
        
        // if we have less pagesize locally we use api
        if breeds.count < pageSize {
            currentPage = 0
            isLastPage = false
            await loadNextPage()
        } else {
            currentPage = 1
            isLastPage = false
        }
        
        hasLoadedInitialData = true
    }

    @MainActor
    func loadNextPage() async {
        
        isLoadingPage = true
        if currentPage == 0 || breeds.isEmpty {
            isLoading = true //show loading if there is no data
        }
        errorMessage = nil

        do {
            // verify if there is local data
            let totalLocalBreeds = try modelContext.fetchCount(FetchDescriptor<CatBreed>())
            let expectedLocalItems = (currentPage + 1) * pageSize
            
            if totalLocalBreeds >= expectedLocalItems {
                
                var descriptor = FetchDescriptor<CatBreed>(
                    sortBy: [SortDescriptor(\.name)]
                )
                descriptor.fetchLimit = (currentPage + 1) * pageSize
                
                let localBreeds = try modelContext.fetch(descriptor)
                breeds = localBreeds
                
                currentPage += 1
            } else {
                //data from the API
                let dtos = try await CatAPIService.shared.fetchBreeds(page: currentPage, limit: pageSize)
                
                
                //if it received less items than teh page size its most likely the last page
                if dtos.count < pageSize {
                    isLastPage = true
                }

                // Insert new items
                var newItems: [CatBreed] = []
                
                for dto in dtos {
                    // verify if it alredy exists
                    if breeds.contains(where: { $0.apiId == dto.id }) {
                        continue
                    }
                    
                    let (minLife, maxLife) = CatAPIService.shared.parseLifeSpan(dto.life_span)
                    
                    let catBreed = CatBreed(
                        apiId: dto.id,
                        name: dto.name,
                        origin: dto.origin,
                        temperament: dto.temperament,
                        breedDescription: dto.description,
                        imageURL: dto.image?.url,
                        lifeSpanMin: minLife,
                        lifeSpanMax: maxLife,
                        isFavorite: false
                    )
                    
                    modelContext.insert(catBreed)
                    newItems.append(catBreed)
                }

                if !newItems.isEmpty {
                    try modelContext.save()
                }

                // reload from local data to have it ordered
                var descriptor = FetchDescriptor<CatBreed>(
                    sortBy: [SortDescriptor(\.name)]
                )
                descriptor.fetchLimit = (currentPage + 1) * pageSize
                
                breeds = try modelContext.fetch(descriptor)
                
                //print("Total breeds: \(breeds.count)")
                currentPage += 1
            }

            
        } catch {
            print("Error loading page \(currentPage): \(error)")
            errorMessage = "Failed to load breeds: \(error.localizedDescription)"
        }

        isLoadingPage = false
        isLoading = false
    }

    func fetchLocalBreeds(limit: Int? = nil) {
        var descriptor = FetchDescriptor<CatBreed>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        // can't pass limit
        if let limit = limit {
            descriptor.fetchLimit = limit
        }

        do {
            let fetchedBreeds = try modelContext.fetch(descriptor)
            
            if limit != nil {
                breeds = fetchedBreeds
                //print("Fetched \(fetchedBreeds.count) breeds with limit \(limit!)")
            } else {
                breeds = fetchedBreeds
                //print("Fetched all \(fetchedBreeds.count) breeds from local storage")
            }
        } catch {
            print(" Failed to fetch local breeds: \(error)")
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

    // is called when UI loads last item
    @MainActor
    func loadMoreIfNeeded(currentItem: CatBreed) async {
        // if its in search mode it doesn't load
        guard searchText.isEmpty else {
            return
        }
        
        // verify if its one of the last 3 items
        guard let index = breeds.firstIndex(where: { $0.apiId == currentItem.apiId }) else {
            return
        }
        
        if index >= breeds.count - 3 {
            await loadNextPage()
        }
    }
    
    // func to reload all data
    @MainActor
    func refreshData() async {
        //print(" REFRESH DATA")
        breeds.removeAll()
        currentPage = 0
        isLastPage = false
        hasLoadedInitialData = false
        await loadInitialBreeds()
    }
    
}
