//
//  FavoritesView.swift
//  CatChallenge
//
//  Created by user943027 on 8/11/25.
//

import Foundation
import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: [SortDescriptor(\CatBreed.name)]) private var allBreeds: [CatBreed]
    
    private var favorites: [CatBreed] {
        allBreeds.filter { $0.isFavorite }
    }
    
    private var averageLifespanText: String {
        let values = favorites.compactMap { Double($0.lifeSpanMin ?? $0.lifeSpanMax ?? 0) }.filter { $0 > 0 }
        guard !values.isEmpty else { return "—" }
        let avg = values.reduce(0, +) / Double(values.count)
        return String(format: "%.1f", avg)
    }
    
    var body: some View {
        List {
            if favorites.isEmpty {
                Text("No favourites yet").foregroundStyle(.secondary)
            } else {
                Section(header: Text("Average lifespan (lower value): \(averageLifespanText) years")) {
                    ForEach(favorites) { breed in
                        NavigationLink {
                            BreedDetailView(breed: breed)
                        } label: {
                            HStack {
                                if let urlStr = breed.imageURL, let url = URL(string: urlStr) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            Color.gray.frame(width:44, height:44).cornerRadius(6)
                                        case .success(let img):
                                            img.resizable().scaledToFill().frame(width:44, height:44).clipped().cornerRadius(6)
                                        case .failure:
                                            Color.gray.frame(width:44, height:44).cornerRadius(6)
                                        @unknown default:
                                            Color.gray.frame(width:44, height:44).cornerRadius(6)
                                        }
                                    }
                                } else {
                                    Color.gray.frame(width:44, height:44).cornerRadius(6)
                                }
                                VStack(alignment: .leading) {
                                    Text(breed.name)
                                    if let origin = breed.origin {
                                        Text(origin).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                    .onDelete(perform: removeFromFavorites) //delete button swipe left
                }
            }
        }
        .navigationTitle("Favourites")
    }
    
    private func removeFromFavorites(offsets: IndexSet) {
        for idx in offsets {
            let breed = favorites[idx]
            breed.isFavorite = false
        }
        do {
            try modelContext.save()
        } catch {
            print("Failed to save after unfavorite: \(error)")
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CatBreed.self, configurations: config)
    
    // Criar dados de teste com favoritos e lifespans
    let breed1 = CatBreed(
        apiId: "test1",
        name: "Bengal",
        origin: "United States",
        temperament: "Active, Playful",
        imageURL: "https://cdn2.thecatapi.com/images/O3btzLlsO.png",
        lifeSpanMin: 12,
        lifeSpanMax: 16,
        isFavorite: true
    )
    
    let breed2 = CatBreed(
        apiId: "test2",
        name: "Persian",
        origin: "Iran",
        temperament: "Calm, Gentle",
        imageURL: "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg",
        lifeSpanMin: 14,
        lifeSpanMax: 18,
        isFavorite: true
    )
    
    let breed3 = CatBreed(
        apiId: "test3",
        name: "Maine Coon",
        origin: "United States",
        temperament: "Gentle, Social",
        lifeSpanMin: 10,
        lifeSpanMax: 13,
        isFavorite: true
    )
    
    container.mainContext.insert(breed1)
    container.mainContext.insert(breed2)
    container.mainContext.insert(breed3)
    
    return NavigationView {
        FavoritesView()
    }
    .modelContainer(container)
}
	
 
