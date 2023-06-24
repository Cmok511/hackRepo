//
//  PPRModel.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 07.03.2023.
//

import Foundation
import PromiseKit

struct PPRModel {
    
    func fetchMaintenance(page: Int) -> Promise<ActivePPRResponse> {
        let urlString = Constants.urlString.appending("/api/maintenance/active/")
        let url = URL(string: urlString)!.appending("page", value: "\(page)")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    func fetchInactiveMaintenance(page: Int) -> Promise<InactivePPRResponce> {
        let urlString = Constants.urlString.appending("/api/maintenance-reports/")
        let url = URL(string: urlString)!.appending("page", value: "\(page)")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    func fatchMaintenanceTasks(id: Int) -> Promise<MaintenanceTasksResponse> {
        let urlString = Constants.urlString.appending("/api/maintenance/\(id)/maintenance-task/")
        let url = URL(string: urlString)
        return CoreNetwork.request(method: .GET(url: url!))
    }
    
    func startPPR(id: Int) -> Promise<StartPPRResponce> {
        let urlString = Constants.urlString.appending("/api/maintenance/\(id)/start/")
        let url = URL(string: urlString)
        return CoreNetwork.request(method: .PUT(url: url!, body: nil))
    }
    
    func endPPR(pprID: Int, comment: String?) -> Promise<StartPPRResponce> {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "comment": comment
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let urlString = Constants.urlString.appending("/api/maintenance/\(pprID)/end/")
        let url = URL(string: urlString)
        return CoreNetwork.request(method: .PUT(url: url!, body: data))
    }
    
}

struct ActivePPRResponse: Codable {
    let message: String?
    let meta: Meta?
    let description: String?
    let data: [Maintenance]?
}

struct Maintenance: Codable {
    let title: String?
    let description: String?
    let id: Int?
    let position: Position?
    let group: Group?
    let worker: User?
    let repeatValue: Int?
    let repeatUnit: Int?
    let planned: Int?
    let tasks: [WorkTask?]
}

struct StartPPRResponce: Codable {
    let message: String?
    let description: String?
}


struct MaintenanceTasksResponse: Codable {
    let message: String?
    let description: String?
    let data: [MaintenanceTask]?
}

struct MaintenanceTask: Codable {
    let id: Int?
    let creator: User?
    let description: String?
    let worker: User?
    let location: Location?
    let locationDescription: String?
    let title: String?
    let group: Group?
    let created: Int?
    let started: Int?
    let ended: Int?
    let deadline: Int?
    let status: Int?
    let photos : [Photo]?
    let reports: [Report]?
}


struct MaintenanceTaskResponse: Codable {
    let message: String?
    let description: String?
    let data: MaintenanceTask?
}

struct EndTaskResponse: Codable {
    let message: String?
    let description: String?
}

struct InactivePPRResponce: Codable {
    let message: String?
    let description: String?
    let meta: Meta?
    let data: [InactivePPR]
}

struct InactivePPR: Codable {
    let id: Int?
    let created: Int?
    let isComplete: Bool?
    let comment: String?
    let maintenance: MaintenanceReports?
    let taskReports: [WorkTaskReports?]?
}

struct MaintenanceReports: Codable {
    let title: String?
    let description: String?
    let id: Int?
    let position: Position?
    let group: Group?
    let worker: User?
    let repeatValue: Int?
    let repeatUnit: Int?
    let planned: Int?
    let status: Int?
}

struct WorkTaskReports: Codable {
    let comment: String?
    let id: Int?
    let created: Int?
    let creator: User?
    let photos: [Photo]?
    let status: Int?
    let task: WorkTaskReport?
}
