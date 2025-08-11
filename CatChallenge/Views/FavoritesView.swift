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
    @State private var viewModel: FavoritesViewModel?
    
    var body: some View {
        List {
            if let viewModel = viewModel {
                if viewModel.favoriteBreeds.isEmpty {
                    Text("No favourites yet")
                        .foregroundStyle(.secondary)
                } else {
                    Section(header: Text("Average lifespan (lower value): \(viewModel.averageLifespanText) years")) {
                        ForEach(viewModel.favoriteBreeds) { breed in
                            NavigationLink {
                                BreedDetailView(breed: breed)
                            } label: {
                                HStack {
                                    if let urlStr = breed.imageURL, let url = URL(string: urlStr) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                Color.gray.frame(width: 44, height: 44).cornerRadius(6)
                                            case .success(let img):
                                                img.resizable().scaledToFill()
                                                    .frame(width: 44, height: 44)
                                                    .clipped().cornerRadius(6)
                                            case .failure:
                                                Color.gray.frame(width: 44, height: 44).cornerRadius(6)
                                            @unknown default:
                                                Color.gray.frame(width: 44, height: 44).cornerRadius(6)
                                            }
                                        }
                                    } else {
                                        Color.gray.frame(width: 44, height: 44).cornerRadius(6)
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
                        .onDelete { indexSet in
                            for index in indexSet {
                                let breed = viewModel.favoriteBreeds[index]
                                viewModel.removeFromFavorites(breed)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Favourites")
        .onAppear {
            if viewModel == nil {
                viewModel = FavoritesViewModel(modelContext: modelContext)
            } else {
                viewModel?.fetchFavorites()
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CatBreed.self, configurations: config)
    
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
	
 
