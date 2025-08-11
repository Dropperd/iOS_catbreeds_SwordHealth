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
    @State private var viewModel: BreedsListViewModel?
    
    var body: some View {
        NavigationStack {
            if let viewModel = viewModel {
                List {
                    ForEach(viewModel.filteredBreeds) { breed in
                        NavigationLink(destination: BreedDetailView(breed: breed)) {
                            BreedRowView(breed: breed) {
                                viewModel.toggleFavorite(breed)
                            }
                        }
                        .onAppear {
                            Task {
                                await viewModel.loadMoreIfNeeded(currentItem: breed)
                            }
                        }
                    }
                    
                    // loading indicator at the end of the list
                    if viewModel.isLoading && !viewModel.filteredBreeds.isEmpty {
                        HStack {
                            Spacer()
                            ProgressView("Loading more...")
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
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
                .searchable(
                    text: Binding(
                        get: { viewModel.searchText },
                        set: { viewModel.searchText = $0 }
                    ),
                    placement: .navigationBarDrawer(displayMode: .always)
                )
                .refreshable {
                    await viewModel.refreshData()
                }
                .overlay {
                    if viewModel.isLoading && viewModel.filteredBreeds.isEmpty {
                        ProgressView("Loading breeds...")
                    }
                }
                .alert("Error", isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                )) {
                    Button("OK", role: .cancel) {
                        viewModel.errorMessage = nil
                    }
                } message: {
                    Text(viewModel.errorMessage ?? "")
                }
                .task {
                    await viewModel.loadInitialBreeds()
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = BreedsListViewModel(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: CatBreed.self, inMemory: true)
}
