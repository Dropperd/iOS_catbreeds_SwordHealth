//
//  CatBreedDTO.swift
//  CatChallenge
//
//  Created by user943027 on 8/11/25.
//

import Foundation

struct CatBreedDTO: Decodable {
    let id: String
    let name: String
    let origin: String?
    let temperament: String?
    let description: String?
    let life_span: String?
    let image: ImageDTO?
    
    struct ImageDTO: Decodable {
        let url: String?
    }
}
