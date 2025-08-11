//
//  BreedDetailView.swift
//  CatChallenge
//
//  Created by user943027 on 8/11/25.
//

import Foundation
import SwiftUI
import SwiftData

struct BreedDetailView: View {
    let breed: CatBreed
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: BreedDetailViewModel?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let urlStr = breed.imageURL, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Color.gray.frame(height: 240).cornerRadius(12)
                        case .success(let image):
                            image.resizable().scaledToFill()
                                .frame(height: 240).clipped().cornerRadius(12)
                        case .failure:
                            Color.gray.frame(height: 240).cornerRadius(12)
                        @unknown default:
                            Color.gray.frame(height: 240).cornerRadius(12)
                        }
                    }
                }
                
                Text(breed.name)
                    .font(.title)
                    .bold()
                
                if let origin = breed.origin {
                    Text("Origin: \(origin)").font(.subheadline)
                }
                
                if let temperament = breed.temperament {
                    Text("Temperament: \(temperament)").font(.body)
                }
                
                if let desc = breed.breedDescription {
                    Text(desc).font(.body)
                }
                
                if let avg = breed.lifeSpanAverage {
                    Text("Average lifespan: \(avg) years").font(.subheadline)
                } else {
                    Text("Lifespan: Unknown").font(.subheadline)
                }
                
                Button {
                    viewModel?.toggleFavorite()
                } label: {
                    Label(breed.isFavorite ? "Remove from favourites" : "Add to favourites",
                          systemImage: breed.isFavorite ? "heart.fill" : "heart")
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 8)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(breed.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel == nil {
                viewModel = BreedDetailViewModel(breed: breed, modelContext: modelContext)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CatBreed.self, configurations: config)
    
    let sampleBreed = CatBreed(
        apiId: "beng",
        name: "Bengal",
        origin: "United States",
        temperament: "Alert, Agile, Energetic, Demanding, Intelligent",
        breedDescription: "Bengals are a lot of fun to live with, but they're definitely not the cat for everyone, or for first-time cat owners. Extremely intelligent, curious and active, they demand a lot of interaction and woe betide the owner who doesn't provide it.",
        imageURL: "https://cdn2.thecatapi.com/images/O3btzLlsO.png",
        lifeSpanMin: 13,
        lifeSpanMax: 16,
        isFavorite: false
    )
    
    container.mainContext.insert(sampleBreed)
    
    return NavigationView {
        BreedDetailView(breed: sampleBreed)
    }
    .modelContainer(container)
}
