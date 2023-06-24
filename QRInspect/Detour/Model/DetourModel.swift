//
//  DetourModel.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 07.03.2023.
//

import Foundation
import PromiseKit

struct DetourModel {
    
    func fatchTour(page: Int) -> Promise<GettingTourResponse> {
        let urlString = Constants.urlString.appending("/api/tour/active/")
        let url = URL(string: urlString)!.appending("page", value: "\(page)")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    func fatchInactiveToursTour(page: Int) -> Promise<InactiveTours> {
        let urlString = Constants.urlString.appending("/api/tour-reports/")
        let url = URL(string: urlString)!.appending("page", value: "\(page)")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    func startTour(tourID: Int) -> Promise<StartTourResponse> {
        let urlString = Constants.urlString.appending("/api/tour/\(tourID)/start/")
        let url = URL(string: urlString)
        return CoreNetwork.request(method: .PUT(url: url!, body: nil))
    }
    
    func endTour(tourID: Int, comment: String?) -> Promise<EndTourResponse> {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "comment": comment
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let urlString = Constants.urlString.appending("/api/tour/\(tourID)/end/")
        let url = URL(string: urlString)
        return CoreNetwork.request(method: .PUT(url: url!, body: data))
    }
    
    func fatchTourTasks(id: Int) -> Promise<TourTasksResponse> {
        let urlString = Constants.urlString.appending("/api/tour/\(id)/tour-task/")
        let url = URL(string: urlString)
        return CoreNetwork.request(method: .GET(url: url!))
    }
    
    func fetchTourTask(id: Int) -> Promise<WorkTaskResponse> {
        let urlString = Constants.urlString.appending("/api/tour-task/\(id)/")
        let url = URL(string: urlString)
        return CoreNetwork.request(method: .GET(url: url!))
    }
    
    func fetchPPRTask(id: Int) -> Promise<MaintenanceTaskResponse> {
        let urlString = Constants.urlString.appending("/api/maintenance-task/\(id)/")
        let url = URL(string: urlString)
        return CoreNetwork.request(method: .GET(url: url!))
    }
    
}


struct GettingTourResponse: Codable {
    let message: String?
    let meta: Meta
    let data: [GettingTour]
}

struct GettingTour: Codable {
    let title: String?
    let description: String?
    let id: Int?
    let position: Position?
    let group: Group?
    let worker: User?
    let repeatValue: Int?
    let repeatUnit: Int?
    let planned: Int?
    let tasks: [WorkTask]?
}

struct StartTaskResponse: Codable {
    let message: String?
    let description: String?
    let data: WorkTask?
}

struct StartTourResponse: Codable {
    let message: String?
    let description: String?
    let data: GettingTour?
}

struct EndTourResponse: Codable {
    let message: String?
    let description: String?
}

struct WorkTaskResponse: Codable {
    let message: String?
    let description: String?
    let data: WorkTask?
}
struct TourTasksResponse: Codable {
    let message: String?
    let description: String?
    let data: [WorkTask]?
}

struct InactiveTours: Codable {
    let message: String?
    let meta: Meta?
    let description: String?
    let data: [InactiveToursData]?
}

struct InactiveToursData: Codable {
    let id: Int
    let created: Int?
    let isComplete: Bool?
    let tour: GettingTour?
    let taskReports: [TourTaskReports]?
}

struct TourTaskReports: Codable {
    let comment: String?
    let id: Int
    let created: Int?
    let creator: User?
    let photos: [Photo]?
    let status: Int?
    let task: WorkTask
}
