//
//  getYoutubeVideoID.swift
//  FIT3178-Project
//
//  Created by Yi Goh on 20/5/2024.
//

import Foundation
func getYoutubeVideoID (from url: String) -> String? {
    guard let url = URL(string: url) else { return nil }
    if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            /// Loop through the query parameters to find the one with the video ID
            for queryItem in queryItems {
                if queryItem.name == "v" {
                    return queryItem.value
                }
            }
        }
        
        return nil
}

