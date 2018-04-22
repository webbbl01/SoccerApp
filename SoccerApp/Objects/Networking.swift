//
//  Networking.swift
//  SoccerApp
//
//  Created by blaine on 4/21/18.
//  Copyright © 2018 blaine. All rights reserved.
//

import Foundation

class Networking {
    static let shared = Networking()
    private let session = URLSession.shared
    
    private init() {}
    
    func getTeamsFrom(url: String , completion: @ escaping(_ scores: [BoxScore]?, Error?) -> Void) {
        guard let url = URL(string: url) else {
            let error = NSError(domain: "URL Error", code: 1, userInfo: nil)
            completion(nil,error)
            return
        }
        session.dataTask(with: url) { (sessionData, sessionResponse, sessionError) in
            if let error = sessionError {
                completion(nil, error)
                return
            }
            //check for response 200, and other potential codes
            guard let data = sessionData else {
                let error = NSError(domain: "Response Error", code: 1, userInfo: nil)
                completion(nil,error)
                return
            }
            do {
                let jsonScores = try JSONDecoder().decode([BoxScore].self, from: data)
                completion(jsonScores,nil)
            } catch let error {
                print("Error retrieving data from api:", error.localizedDescription)
            }
        }.resume()
    }
}
