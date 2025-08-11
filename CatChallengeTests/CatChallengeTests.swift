//
//  CatChallengeTests.swift
//  CatChallengeTests
//
//  Created by user943027 on 8/10/25.
//

import XCTest
import SwiftData
@testable import CatChallenge

final class CatChallengeTests: XCTestCase {
    
    // MARK: - Simple Model Tests (sem SwiftData)
    
    func testCatBreed_LifeSpanAverage_BothValues() throws {
        // Given
        let breed = CatBreed(apiId: "1", name: "Bengal", lifeSpanMin: 12, lifeSpanMax: 16)
        
        // When
        let average = breed.lifeSpanAverage
        
        // Then
        XCTAssertEqual(average, 14) // (12 + 16) / 2 = 14
    }
    
    func testCatBreed_LifeSpanAverage_OnlyMinValue() throws {
        // Given
        let breed = CatBreed(apiId: "1", name: "Bengal", lifeSpanMin: 12, lifeSpanMax: nil)
        
        // When
        let average = breed.lifeSpanAverage
        
        // Then
        XCTAssertEqual(average, 12)
    }
    
    func testCatBreed_LifeSpanAverage_NoValues() throws {
        // Given
        let breed = CatBreed(apiId: "1", name: "Bengal", lifeSpanMin: nil, lifeSpanMax: nil)
        
        // When
        let average = breed.lifeSpanAverage
        
        // Then
        XCTAssertNil(average)
    }
    
    // MARK: - CatAPIService Tests
    
    func testCatAPIService_ParseLifeSpan_ValidRange() throws {
        // Given
        let service = CatAPIService.shared
        let lifeSpanString = "12 - 16"
        
        // When
        let (min, max) = service.parseLifeSpan(lifeSpanString)
        
        // Then
        XCTAssertEqual(min, 12)
        XCTAssertEqual(max, 16)
    }
    
    func testCatAPIService_ParseLifeSpan_SingleValue() throws {
        // Given
        let service = CatAPIService.shared
        let lifeSpanString = "14"
        
        // When
        let (min, max) = service.parseLifeSpan(lifeSpanString)
        
        // Then
        XCTAssertEqual(min, 14)
        XCTAssertEqual(max, 14)
    }
    
    func testCatAPIService_ParseLifeSpan_InvalidInput() throws {
        // Given
        let service = CatAPIService.shared
        let lifeSpanString = "invalid"
        
        // When
        let (min, max) = service.parseLifeSpan(lifeSpanString)
        
        // Then
        XCTAssertNil(min)
        XCTAssertNil(max)
    }
    
    func testCatAPIService_ParseLifeSpan_NilInput() throws {
        // Given
        let service = CatAPIService.shared
        
        // When
        let (min, max) = service.parseLifeSpan(nil)
        
        // Then
        XCTAssertNil(min)
        XCTAssertNil(max)
    }
    
    // MARK: - Basic Logic Tests
    
    func testCatBreed_FavoriteToggle() throws {
        // Given
        let breed = CatBreed(apiId: "1", name: "Bengal", isFavorite: false)
        
        // When
        breed.isFavorite.toggle()
        
        // Then
        XCTAssertTrue(breed.isFavorite)
        
        // When (toggle again)
        breed.isFavorite.toggle()
        
        // Then
        XCTAssertFalse(breed.isFavorite)
    }
    
    func testCatBreed_Initialization() throws {
        // Given & When
        let breed = CatBreed(
            apiId: "beng",
            name: "Bengal",
            origin: "United States",
            temperament: "Active",
            breedDescription: "Active cat",
            imageURL: "https://example.com/image.jpg",
            lifeSpanMin: 12,
            lifeSpanMax: 16,
            isFavorite: true
        )
        
        // Then
        XCTAssertEqual(breed.apiId, "beng")
        XCTAssertEqual(breed.name, "Bengal")
        XCTAssertEqual(breed.origin, "United States")
        XCTAssertEqual(breed.temperament, "Active")
        XCTAssertEqual(breed.breedDescription, "Active cat")
        XCTAssertEqual(breed.imageURL, "https://example.com/image.jpg")
        XCTAssertEqual(breed.lifeSpanMin, 12)
        XCTAssertEqual(breed.lifeSpanMax, 16)
        XCTAssertTrue(breed.isFavorite)
    }
    
    // MARK: - Search Logic Test
    
    func testSearchLogic() throws {
        // Given
        let breeds = [
            CatBreed(apiId: "1", name: "Bengal"),
            CatBreed(apiId: "2", name: "Persian"),
            CatBreed(apiId: "3", name: "Maine Coon")
        ]
        let searchText = "Bengal"
        
        // When
        let filtered = breeds.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        
        // Then
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.name, "Bengal")
    }
    
    func testSearchLogic_CaseInsensitive() throws {
        // Given
        let breeds = [
            CatBreed(apiId: "1", name: "Bengal"),
            CatBreed(apiId: "2", name: "Persian")
        ]
        let searchText = "bengal" // lowercase
        
        // When
        let filtered = breeds.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        
        // Then
        XCTAssertEqual(filtered.count, 1)
        XCTAssertEqual(filtered.first?.name, "Bengal")
    }
    
    // MARK: - Average Calculation Test
    
    func testAverageLifespanCalculation() throws {
        // Given
        let favoriteBreeds = [
            CatBreed(apiId: "1", name: "Bengal", lifeSpanMin: 12, lifeSpanMax: 16, isFavorite: true),
            CatBreed(apiId: "2", name: "Persian", lifeSpanMin: 10, lifeSpanMax: 14, isFavorite: true)
        ]
        
        // When
        let values = favoriteBreeds.compactMap {
            Double($0.lifeSpanMin ?? $0.lifeSpanMax ?? 0)
        }.filter { $0 > 0 }
        
        let avg = values.reduce(0, +) / Double(values.count)
        let result = String(format: "%.1f", avg)
        
        // Then
        XCTAssertEqual(result, "11.0") // (12 + 10) / 2 = 11.0
    }
    
    func testAverageLifespanCalculation_NoFavorites() throws {
        // Given
        let favoriteBreeds: [CatBreed] = []
        
        // When
        let values = favoriteBreeds.compactMap {
            Double($0.lifeSpanMin ?? $0.lifeSpanMax ?? 0)
        }.filter { $0 > 0 }
        
        let result = values.isEmpty ? "—" : String(format: "%.1f", values.reduce(0, +) / Double(values.count))
        
        // Then
        XCTAssertEqual(result, "—")
    }
}
