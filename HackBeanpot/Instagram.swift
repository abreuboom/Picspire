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
import SwiftyJSON


class Instagram {
    let db = Firestore.firestore();
    
    var tagPhotos: [photo] = []
    var locationPhotos: [photo] = []
    
    struct photo {
        var url: String;
        var caption: String;
        
        init(url: String, caption: String) {
            self.url = url
            self.caption = caption
        }
    }
    
    func setTagQuery(query: String) -> () {
        let formattedQuery = query.replacingOccurrences(of: " ", with: "")
//        print(formattedQuery)
        db.collection("Queries").document("tagField").setData(["Tag": formattedQuery])
    }
    
    func setLocationQuery(query: String) -> () {
        //        print(formattedQuery)
        db.collection("Queries").document("locationField").setData(["Location": query])
    }
    
    func fetchTagData(completion:@escaping ([photo]) -> ()) {
        db.collection("Results").document("tag").addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard document.data() != nil else {
                print("Document data was empty.")
                return
            }
            let urlArray = document.data()?["URLs"] as? [String]
            let captionArray = document.data()?["Captions"] as? [String]
            
            var counter = 0;
            while (counter < 10) {
                let url = urlArray?[counter]
                let caption = captionArray?[counter]
                counter = counter + 1
                let temp = photo(url: url ?? "", caption: caption ?? "")
                self.tagPhotos.append(temp)
                //print(temp)
            }
            //print("Current data: \(data)")
            /* Use the data retrieved from firestore to create Photo structs and append them to the the photoArray which will be returned.
             I think you must convert the data you get from Firestore to JSON before you can use it!
             */
            //print(self.tagPhotos)
            completion(self.tagPhotos)
        }
        
    }
    
    func fetchLocationData(completion:@escaping ([photo]) -> ()) {
        db.collection("Results").document("location").addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            guard document.data() != nil else {
                print("Document data was empty.")
                return
            }
            let urlArray = document.data()?["LURLs"] as? [String]
            let captionArray = document.data()?["LCaptions"] as? [String]
            
            var counter = 0;
            while (counter < 10) {
                let url = urlArray?[counter]
                let caption = captionArray?[counter]
                counter = counter + 1
                let temp = photo(url: url ?? "", caption: caption ?? "")
                self.locationPhotos.append(temp)
                //print(temp)
            }
            //print("Current data: \(data)")
            /* Use the data retrieved from firestore to create Photo structs and append them to the the photoArray which will be returned.
             I think you must convert the data you get from Firestore to JSON before you can use it!
             */
            //print(self.locationPhotos)
            completion(self.locationPhotos)
        }
        
    }
}
