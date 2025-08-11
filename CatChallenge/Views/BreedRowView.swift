//
//  BreedRowView.swift
//  CatChallenge
//
//  Created by user943027 on 8/11/25.
//

import Foundation
import SwiftUI

struct BreedRowView: View {
    @Bindable var breed: CatBreed
    var onFavoriteTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if let urlString = breed.imageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.frame(width: 60, height: 60).cornerRadius(8)
                    case .success(let img):
                        img
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipped()
                            .cornerRadius(8)
                    case .failure:
                        Color.gray.frame(width: 60, height: 60).cornerRadius(8)
                    @unknown default:
                        Color.gray.frame(width: 60, height: 60).cornerRadius(8)
                    }
                }
            } else {
                Color.gray.frame(width: 60, height: 60).cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(breed.name)
                    .font(.headline)
                if let origin = breed.origin {
                    Text(origin)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                onFavoriteTapped()
            } label: {
                Image(systemName: breed.isFavorite ? "heart.fill" : "heart")
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    let sampleBreed = CatBreed(
        apiId: "beng",
        name: "Bengal",
        origin: "United States",
        temperament: "Active, Playful",
        imageURL: "https://cdn2.thecatapi.com/images/O3btzLlsO.png",
        lifeSpanMin: 12,
        lifeSpanMax: 16,
        isFavorite: false
    )
    
    return List {
        BreedRowView(breed: sampleBreed) {
            print("Favorite tapped!")
        }
        
        BreedRowView(breed: CatBreed(
            apiId: "pers",
            name: "Persian",
            origin: "Iran",
            isFavorite: true
        )) {
            print("Persian favorite tapped!")
        }
    }
    .modelContainer(for: CatBreed.self, inMemory: true)
}
