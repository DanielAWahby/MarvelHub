
//
//  DataModel.swift
//  Marvel Hub
//
//  Created by Daniel Wahby on 28/10/2021.
//

import Foundation

struct ResponseModelCharacter:Codable{
    var code:Int?
    var status:String?
    var data:DataObjCharacter?
}

struct DataObjCharacter:Codable{
    var total:Int?
    var results:[Character]?
}
struct Character:Codable {
    var id:Int?
    var name:String?
    var description:String?
    var thumbnail:Image?
//    var comics:ComicList?
//    var stories:StoryList?
//    var events:EventList?
//    var series:SeriesList?
}

struct ResponseModelComic:Codable{
    var code:Int?
    var status:String?
    var data:DataObjComic?
}

struct DataObjComic:Codable{
    var total:Int?
    var results:[Comic]?
}

//struct ComicList:Codable {
//    var available:Int?
//    var returned:Int?
//    var collectionURI:String?
//    var items:[ComicSummary]?
//}

struct Comic:Codable {
    var id:Int?
    var digitalId:Int?
    var title:String?
    var thumbnail:Image?
    
}
struct ResponseModelEvent:Codable{
    var code:Int?
    var status:String?
    var data:DataObjComic?
}
struct DataObjEvent:Codable{
    var total:Int?
    var results:[Event]?
}
struct Event:Codable {
    var id:Int?
    var title:String?
    var thumbnail:Image?
    
}
struct Series:Codable {
    var id:Int?
    var title:String?
    var thumbnail:Image?
    
}
struct Story:Codable {
    var id:Int?
    var title:String?
    var thumbnail:Image?
    
}

struct Image:Codable {
    var path:String?
    var imageExtension:String?
    
    private enum CodingKeys : String, CodingKey {
            case path = "path"
        case imageExtension = "extension"
    }
}
