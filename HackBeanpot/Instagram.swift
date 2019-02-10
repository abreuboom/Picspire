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
    
    
    
    
    struct photo {
        var url: String;
        var caption: String;
        
        init(url: String, caption: String) {
            self.url = url
            self.caption = caption
        }
    }
    
    func setTagQuery(query: String, completion:@escaping (Bool) -> ()) -> () {
        let formattedQuery = query.replacingOccurrences(of: " ", with: "")
//        print(formattedQuery)
        db.collection("Queries").document("tagField").setData(["Tag": formattedQuery]) { (error) in
            completion(true)
        }
    }
    
    func setLocationQuery(longitude: Float, latitude: Float, completion:@escaping (Bool) -> ()) -> () {
        //        print(formattedQuery)
        
        
        db.collection("Queries").document("locationField").setData(["longitude": longitude, "latitude": latitude]) { (error) in
            completion(true)
        }
    }
    
    func fetchTagData(completion:@escaping ([photo]) -> ()) {
        var tagPhotos: [photo] = []
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
                tagPhotos.append(temp)
                //print(temp)
            }
            //print("Current data: \(data)")
            /* Use the data retrieved from firestore to create Photo structs and append them to the the photoArray which will be returned.
             I think you must convert the data you get from Firestore to JSON before you can use it!
             */
            //print(self.tagPhotos)
            completion(tagPhotos)
        }
        
    }
    
    func fetchLocationData(completion:@escaping ([photo]) -> ()) {
        var locationPhotos: [photo] = []
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
            while (counter < 8) {
                
                let url = urlArray?[counter]
                let caption = captionArray?[counter]
                counter = counter + 1
                let temp = photo(url: url ?? "", caption: caption ?? "")
                locationPhotos.append(temp)
                //print(temp)
            }
            //print("Current data: \(data)")
            /* Use the data retrieved from firestore to create Photo structs and append them to the the photoArray which will be returned.
             I think you must convert the data you get from Firestore to JSON before you can use it!
             */
            //print(self.locationPhotos)
            completion(locationPhotos)
        }
        
    }
}
