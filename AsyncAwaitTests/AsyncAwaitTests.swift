//
//  AsyncAwaitTests.swift
//  AsyncAwaitTests
//
//  Created by Mario Alberto Barragán Espinosa on 12/06/21.
//

import XCTest
@testable import AsyncAwait

class RemoteCatFactsLoaderTests: XCTestCase {
    
    func test_invoke_fetchesCatFactsClousure() {
        let sut = RemoteCatFactsLoader()
        let exp = expectation(description: "Wait for expectation")
        
        sut.fetch { catFacts in
            exp.fulfill()
            
            XCTAssertTrue(catFacts!.count == 5)
        }
        
        wait(for: [exp], timeout: 5.0)
    }
    
    func test_invoke_fetchesCatFactsAsync() async throws {
        let sut = RemoteCatFactsLoader()
        
        let catFacts = try await sut.fetch()
        
        XCTAssertTrue(catFacts.count == 5)
    }
}

struct CatFactElement: Codable {
  let text: String
}

typealias CatFacts = [CatFactElement]

class RemoteCatFactsLoader {    
    func fetch(completion: @escaping (CatFacts?) -> Void) {
        let url = URL(string: "https://cat-fact.herokuapp.com/facts")!
        let request = URLRequest(url: url)
        
        let dataTask = URLSession.shared.dataTask(with: request) { (data, _, error) in
            
            if let error = error {
                print("Error en el request: \(error.localizedDescription)")
            }
            
            guard let data = data else { return }
            let facts = try? JSONDecoder().decode(CatFacts.self, from: data)
            
            completion(facts)
        }
        
        dataTask.resume()
    }
    
    func fetch() async throws -> CatFacts {
        let url = URL(string: "https://cat-fact.herokuapp.com/facts")!
        let request = URLRequest(url: url)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let facts = try JSONDecoder().decode(CatFacts.self, from: data)
        
        return facts
    }
}
