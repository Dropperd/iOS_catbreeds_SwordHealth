//
//  ContentView.swift
//  CatChallenge
//
//  Created by user943027 on 8/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    // Fetch CatBreed entities
    @Query(sort: [SortDescriptor(\CatBreed.name)]) private var breeds: [CatBreed]

    @State private var searchText: String = ""
    @State private var isLoading: Bool = false
    @State private var errorMessage: String?

    //filters by text
    private var filtered: [CatBreed] {
        guard !searchText.isEmpty else { return breeds }
        return breeds.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { breed in
                    NavigationLink(destination: BreedDetailView(breed: breed)) {
                        BreedRowView(breed: breed) {
                            toggleFavorite(breed)
                        }
                    }
                }
            }
            .navigationTitle("Cat Breeds")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FavoritesView()) {
                        Label("Favourites", systemImage: "heart.fill")
                    }
                }
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .overlay {
                if isLoading {
                    ProgressView("Loading breeds…")
                }
            }
            .task {
                await loadBreedsIfNeeded()
            }
            .alert("Error", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                Button("OK", role: .cancel) { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    // Loads breeds from API if no local data exists
    private func loadBreedsIfNeeded() async {
        guard breeds.isEmpty else { return }
        isLoading = true
        do {
            let dtos = try await CatAPIService.shared.fetchBreeds()
            // Avoid inserting duplicates by matching apiId
            for dto in dtos {
                if breeds.contains(where: { $0.apiId == dto.id }) { continue }
                let (min, max) = CatAPIService.shared.parseLifeSpan(dto.life_span)
                let model = CatBreed(apiId: dto.id,
                                     name: dto.name,
                                     origin: dto.origin,
                                     temperament: dto.temperament,
                                     breedDescription: dto.description,
                                     imageURL: dto.image?.url,
                                     lifeSpanMin: min,
                                     lifeSpanMax: max,
                                     isFavorite: false)
                modelContext.insert(model)
            }
            do {
                try modelContext.save()
            } catch {
                print("Failed to save fetched breeds: \(error)")
            }
        } catch {
            errorMessage = "Failed to load breeds: \(error.localizedDescription)"
            print(error)
        }
        isLoading = false
    }

    private func toggleFavorite(_ breed: CatBreed) {
        breed.isFavorite.toggle()
        do {
            try modelContext.save()
        } catch {
            print("Failed to save favorite change: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CatBreed.self, inMemory: true)
}
