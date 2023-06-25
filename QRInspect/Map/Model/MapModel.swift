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
    let data: [GetLocationsResponseData]?
}

// MARK: - GetLocationsResponseData
struct GetLocationsResponseData: Codable {
    let name: String?
    let lat, lon: Float?
    let border: [[Float]]?
    let temperature, humidity: Int?
    let sort: String?
    let area: Int?
    let cadastralNumber, soil: String?
    let zoom: Int?
    let description: String?
    let stage, id: Int?
    let user: LocationUser?
    let isNegative: Bool?
    let cover: String?
    let annotation: String?
}

// MARK: - LocationUser
struct LocationUser: Codable {
    let email, tel: String?
    let isActive, isSuperuser: Bool?
    let firstName, lastName, patronymic: String?
    let group: UserAdditionalInfo?
    let id: Int?
    let avatar: String?
    let lastActivity: Int?
}

//MARK: UserAdditionalInfo
struct UserAdditionalInfo: Codable {
    let name: String?
}

struct Point {
    let coordinate: CLLocationCoordinate2D
}
