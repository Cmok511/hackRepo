//
//  TaskModel.swift
//  QRInspect
//
//  Created by Сергей Майбродский on 24.06.2023.
//

import Foundation
import PromiseKit

struct TaskModel {
    
    //MARK: fetch task list
    static func fetchTaskList(isActive: Bool, page: Int) -> Promise<TaskListResponse>{
        var url = Constants.baseURL.appendingPathComponent("/api/user/me/task/processed/")
        if isActive {
            url = url.appending("statuses", value: "0")
            url = url.appending("statuses", value: "2")
        } else {
            url = url.appending("statuses", value: "3")
        }
        url = url.appending("page", value: "\(page)")
        return CoreNetwork.request(method: .GET(url: url))
    }
    
    //MARK: change task status
    static func startTask(taskId: Int) -> Promise<OneTaskResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let param: [String: Encodable] = [
            "status": 2
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/task/\(taskId)/status/")
        return CoreNetwork.request(method: .PUT(url: url, body: data!))
    }
    
    static func putImage(image: Data?) -> Promise<PhotoResponse> {
        let url: URL = Constants.baseURL
            .appendingPathComponent("/api/task-report/photo/")
        let media = NetCoreMedia(with: image!, forKey: "new_image", mediaType: .image)
        
        let configuration = MultipartRequestConfiguration(url: url, media: [media], parameters: [:])
        return CoreNetwork.request(method: .MultipartPOST(configuration: configuration))
    }
   
    //MARK: putTourImage
    static func putTourImage(image: Data?) -> Promise<PhotoResponse> {
        let url: URL = Constants.baseURL
            .appendingPathComponent("/api/tour-task-reports/photo/")
        let media = NetCoreMedia(with: image!, forKey: "new_image", mediaType: .image)
        
        let configuration = MultipartRequestConfiguration(url: url, media: [media], parameters: [:])
        return CoreNetwork.request(method: .MultipartPOST(configuration: configuration))
    }

    //MARK: put image
    static func putPPRImage(image: Data?) -> Promise<PhotoResponse> {
        let url: URL = Constants.baseURL
            .appendingPathComponent("/api/maintenance-task-reports/photo/")
        let media = NetCoreMedia(with: image!, forKey: "new_image", mediaType: .image)
        
        let configuration = MultipartRequestConfiguration(url: url, media: [media], parameters: [:])
        return CoreNetwork.request(method: .MultipartPOST(configuration: configuration))
    }
    
    
    //MARK: create task report
    static func createReport(taskId: Int, report: String, isComplite: Bool, photosID: [Int]) -> Promise<OneTaskResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        print(photosID)
        let param: [String: Encodable] = [
            "comment": report,
            "is_complete": isComplite,
            "photo_ids": photosID
            
        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/task/\(taskId)/task_reports/")
        return CoreNetwork.request(method: .POST(url: url, body: data!))
    }
    
    //MARK: create task report
    static func createTourTaskReport(taskId: Int, report: String, isComplite: Bool, photosID: [Int]) -> Promise<OneTaskResponse>{
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        print(photosID)
        let param: [String: Encodable] = [
            "comment": report,
            "is_complete": isComplite,
            "photo_ids": photosID

        ]
        let wrappedDict = param.mapValues(NetCoreStruct.EncodableWrapper.init(wrapped:))
        let data: Data? = try? encoder.encode(wrappedDict)
        let url = Constants.baseURL.appendingPathComponent("/api/tour-task/\(taskId)/tour-task-reports/")
        return CoreNetwork.request(method: .POST(url: url, body: data!))
    }
}

// MARK: task list response
struct TaskListResponse: Codable {
    let message: String
    let meta: Meta?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: [WorkTask?]
    
    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}

// MARK: one task
struct OneTaskResponse: Codable {
    let message: String
    let meta: Meta?
    let errors: [ErrorData?]
    let errorDescription: String?
    let data: WorkTask?
    
    enum CodingKeys: String, CodingKey {
        case message, meta, errors
        case errorDescription = "description"
        case data
    }
}

// MARK: task in progress
struct WorkTask: Codable {
    let id: Int?
    let creator: User?
    let description: String?
    let worker, engineer: User?
    let location: Location?
    let task: WorkTaskReport?
    let locationDescription: String?
    let title: String?
    let group: Group?
    let created: Int?
    let started, ended: Int?
    let deadline, status: Int?
    let report: Report?
    let photos: [Photo?]
    let isUrgent: Bool?
    let comment: String?
    let returnedCount: Int?
}

//MARK: task that already completed
struct WorkTaskReport: Codable {
    let id: Int?
    let creator: User?
    let description: String?
    let worker, engineer: User?
    let location: Location?
    let locationDescription: String?
    let title: String?
    let group: Group?
    let created: Int?
    let started, ended: Int?
    let deadline, status: Int?
    let report: Report?
    let photos: [Photo?]
    let isUrgent: Bool?
    let comment: String?
    let returnedCount: Int?
}

// MARK: - Location
struct Location: Codable {
    let name: String?
    let description: String?
    let id: Int?
    let address: Address?
}

// MARK: - Address
struct Address: Codable {
    let name: String?
    let lat, lon: Float?
    let id: Int?
}

// MARK: - Report
struct Report: Codable {
    let comment: String?
    let id, created: Int?
    let creator: User?
    let photos: [Photo?]
}

// MARK: - Photo
struct Photo: Codable {
    let id: Int?
    let url: String?
}

//MARK: - PhotoResponce
struct PhotoResponse: Codable {
    let message: String?
    let description: String?
    let data: Photo
}

