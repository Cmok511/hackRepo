//
//  MapModel.swift
//  hackathon
//
//  Created by iOS AXAS on 24.06.2023.
//

import Foundation
import CoreLocation
import PromiseKit

class MapRequests {

    //MARK: get locations
    func getLocations() -> Promise<GetLocationsResponse> {
        let url = Constants.baseURL.appendingPathComponent("/api/location/")

        return CoreNetwork.request(method: .GET(url: url))
    }

}

// MARK: - GetLocationsResponse
struct GetLocationsResponse: Codable {
    let message: String?
    let description: String?
    let data: [GetLocationData]?
}

// MARK: - GetLocationData
struct GetLocationData: Codable {
    let name: String?
    let lat, lon: Float?
    let border: [Float]?
    let temperature, humidity: Int?
    let sort: String?
    let area: Int?
    let cadastralNumber, soil: String?
    let zoom: Int?
    let description: String?
    let stage, id: Int?
}

struct Point {
    let coordinate: CLLocationCoordinate2D
}
