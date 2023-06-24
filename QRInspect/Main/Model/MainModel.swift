//
//  MainModel.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 07.03.2023.
//

import Foundation
import PromiseKit

struct MainModel{
    //MARK: Start | End work
    static func workStartEnd(isStart: Bool) -> Promise<WorkStartEndResponse>{
        var url = Constants.baseURL
        if isStart {
            url = url.appendingPathComponent("/api/v1/users/me/schedule/start/")
        } else {
            url = url.appendingPathComponent("/api/v1/users/me/schedule/end/")
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [:]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        return CoreNetwork.request(method: .POST(url: url, body: data))
    }
    
    static func getRecomendation() -> Promise<RudAPI<[GettingRecomendation]>> {
        let url = Constants.baseURL.appendingPathComponent("/api/locations/recomendations/")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    static func getLocations() -> Promise<RudAPI<[GettingLocation]>> {
        let url = Constants.baseURL.appendingPathComponent("/api/location/")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    static func getTasks() -> Promise<RudAPI<[WorkTask?]>> {
        var url = Constants.baseURL.appendingPathComponent("/api/user/me/task/processed/")
            url = url.appending("is_urgent", value: "true")
        return CoreNetwork.request(method: .GET(url: url))
    }
}


// MARK: SIGN UP RESPONSE
struct RudAPI <T: Codable>: Codable {
    let message: String?
    let description: String?
    let data: T?
}

struct GettingLocation: Codable {
    let name: String?
    let lat: Float?
    let lon: Float?
    let temperature: Float?
    let humidity: Int?
    let sort: String?
    let description: String?
    let cover: String?
    let state: Int?
}

struct GettingRecomendation: Codable {
    let title: String?
    let description: String?
    let id: Int?
    let created: Int?
    let locationName: String?
    let attention: String?
}





// MARK: START END WORK
struct WorkStartEndResponse: Codable {
    let message: String
    let meta: Meta?
    let errors: [ErrorData?]
    let description: String?
    let data: WorkStartEnd?
}

struct WorkStartEnd: Codable {
    let workStartDt: Int?
    let workEndDt: Int?
    let id: Int?
    let user: Profile?
}
