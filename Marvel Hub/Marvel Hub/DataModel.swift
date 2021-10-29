
//
//  DataModel.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 28/10/2021.
//

import Foundation

struct Character:Codable {
    var id:Int?
    var name:String?
    var description:String?
    var thumbnail:Image?
    var comics:ComicList?
    var stories:StoryList?
    var events:EventList?
    var series:SeriesList?
}

struct Image:Codable {
    var path:String?
    var imageExtension:String?
}

struct ComicList:Codable {
    var available:Int?
    var returned:Int?
    var collectionURI:String?
    var items:[ComicSummary]?
}
struct ComicSummary:Codable{
    var resourceURI:String?
    var name:String?
}

struct StoryList:Codable {
    var available:Int?
    var returned:Int?
    var collectionURI:String?
    var items:[StorySummary]?
}
struct StorySummary:Codable{
    var resourceURI:String?
    var name:String?
    var type:String?
}

struct EventList:Codable {
    var available:Int?
    var returned:Int?
    var collectionURI:String?
    var items:[EventSummary]?
}
struct EventSummary:Codable{
    var resourceURI:String?
    var name:String?
}

struct SeriesList:Codable {
    var available:Int?
    var returned:Int?
    var collectionURI:String?
    var items:[SeriesSummary]?
}

struct SeriesSummary:Codable{
    var resourceURI:String?
    var name:String?
}
