//
//  Instagram.swift
//  HackBeanpot
//
//  Created by Subraiz Ahmed on 2/9/19.
//  Copyright © 2019 John Abreu. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore



class Instagram {
    let db = Firestore.firestore();
    
    func setQuery(query: String) -> () {
        let formattedQuery = query.replacingOccurrences(of: " ", with: "")
        print(formattedQuery)
        db.collection("Queries").document("queryField").setData(["Name": formattedQuery])
    }
    
    func fetchData() {
        db.collection("Results").document("resultField").addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard let data = document.data() else {
                print("Document data was empty.")
                return
            }
            print("Current data: \(data)")
        }
    }
}
