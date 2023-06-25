//
//  MainModel.swift
//  QRInspect
//
//

import Foundation
import PromiseKit

struct MainModel{

    //MARK: Start | End work
    static func workStartEnd(isStart: Bool) -> Promise<WorkStartEndResponse>{
        var url = Constants.baseURL
        if isStart {
            url = url.appendingPathComponent("/api/users/me/schedule/start/")
        } else {
            url = url.appendingPathComponent("/api/users/me/schedule/end/")
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [:]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        return CoreNetwork.request(method: .POST(url: url, body: data))
    }

    //MARK: get recommendations
    static func getRecomendation() -> Promise<RudAPI<[GettingRecomendation]>> {
        let url = Constants.baseURL.appendingPathComponent("/api/locations/recomendations/")
        return CoreNetwork.request(method: .GET(url: url))
    }

    //MARK: get locations of polygons
    static func getLocations() -> Promise<RudAPI<[GettingLocation]>> {
        let url = Constants.baseURL.appendingPathComponent("/api/location/")
        return CoreNetwork.request(method: .GET(url: url))
    }

    //MARK: get all tasks (completed and unused)
    static func getTasks() -> Promise<RudAPI<[WorkTask?]>> {
        var url = Constants.baseURL.appendingPathComponent("/api/user/me/task/processed/")
            url = url.appending("statuses", value: "0")
            url = url.appending("statuses", value: "2")
            url = url.appending("is_urgent", value: "true")
        return CoreNetwork.request(method: .GET(url: url))
    }

    //MARK: get weather fetching by location
    static func getWeather(lat: Float, lon: Float) -> Promise<RudAPI<GetWeatherResponse>> {
        var url = Constants.baseURL.appendingPathComponent("/api/weather/")

        url = url.appending("lat", value: String(lat))
        url = url.appending("lon", value: String(lon))

        return CoreNetwork.request(method: .GET(url: url))
    }
}


// MARK: sign up response
struct RudAPI <T: Codable>: Codable {
    let message: String?
    let description: String?
    let data: T?
}

//MARK: getting location
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

//MARK: getting recommendation
struct GettingRecomendation: Codable {
    let title: String?
    let description: String?
    let id: Int?
    let created: Int?
    let locationName: String?
    let attention: String?
}

//MARK: get weather
struct GetWeatherResponse: Codable {
    var temperature: Int?
    var humidity: Int?
    var prediction: String?
    var image: String?
    var now: Int?
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
