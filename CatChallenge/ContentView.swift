//
//  ContentView.swift
//  CatChallenge
//
//  Created by user943027 on 8/10/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var breeds: [CatBreed] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    //simple view to see if fetchapi is working
    var body: some View {
            NavigationView {
                List {
                    if isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                            .foregroundColor(.red)
                    } else {
                        ForEach(breeds, id: \.apiId) { breed in
                            VStack(alignment: .leading) {
                                Text(breed.name)
                                    .font(.headline)
                                if let avg = breed.lifeSpanAverage {
                                    Text("Average lifespan: \(avg) years")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                } else {
                                    Text("Lifespan unknown")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .navigationTitle("Cat Breeds")
                .onAppear {
                    fetchBreeds()
                }
            }
        }

    func fetchBreeds() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let resultDTO = try await CatAPIService.shared.fetchBreeds()
                breeds = resultDTO.map { dto in
                    let (min, max) = CatAPIService.shared.parseLifeSpan(dto.life_span)
                    return CatBreed(
                        apiId: dto.id,
                        name: dto.name,
                        origin: dto.origin,
                        temperament: dto.temperament,
                        breedDescription: dto.description,
                        imageURL: dto.image?.url,
                        lifeSpanMin: min,
                        lifeSpanMax: max
                    )
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }

}
#Preview {
    ContentView()
        .modelContainer(for: CatBreed.self, inMemory: true)
}
