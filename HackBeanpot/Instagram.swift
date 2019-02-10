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
import Alamofire


class Instagram {

    struct photo {
        var url: String;
        var caption: String;
        
        init(url: String, caption: String) {
            self.url = url
            self.caption = caption
        }
    }
    
    func fetchTagData(tag: String, completion:@escaping (Array<photo>) -> ()) {
        var tagPhotos: [photo] = []
        Alamofire.request("https://thawing-oasis-10513.herokuapp.com/tag/red").responseJSON {
            response in switch response.result {
            case .success(let val):
                print("got it")
                let json = JSON(val)
                let numOfPics = json["images"].count
                for index in 0...numOfPics - 1 {
                    
                    let url = json["images"][index]["url"].stringValue
                    let caption = json["images"][index]["caption"].stringValue
                    let temp = photo(url: url, caption: caption)
                    tagPhotos.append(temp)
                    
                }
            print(tagPhotos)
            case .failure(let error):
                print("Error in fetching data!", error)
                
            }
            completion(tagPhotos)
        }
    }
    
/* Make function for fethcing location data. Here is the endpoint you need to hit: https://thawing-oasis-10513.herokuapp.com/location/53.3411/-7.0012 - just enter ur lat and long for 53 and -7 respectively. No API Key required */
    
    // I set up asking for location so from the view controller so pass latitude and longitude as the arguments for hte fetchByLocation function
    // Then use the long and latitude for my endpoint
    
    // Once you make two functions to get the two arrays of photos (one by tags and one by location) please proceed how you did yesterday and pass it to the collection view.
    // Note the location one is a bit rusty compared to the hashtag one! */
 }
