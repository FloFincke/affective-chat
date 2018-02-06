//
//  MBDataStore.swift
//  affective-chat
//
//  Created by Vincent Füseschi on 18.11.17.
//  Copyright © 2017 Florian Fincke. All rights reserved.
//

import Foundation
import Zip
import RxSwift
import CoreLocation

private let sensorDataFileName = "sensor-data"
private let sensorDataJsonName = "\(sensorDataFileName).json"
private let zip = "zip"
private let sensorDataZipName = "\(sensorDataFileName).\(zip)"

private let receptivityKey = "receptivity"
private let locationKey = "location"
private let messageKey = "message"

enum UploadError: Error {
    case instanceGone
    case missingZip
    case missingPhoneId
    case parsingFailed
}

class MBDataStore {

    // Testing
    private var mockDataJsonUrl: URL! {
        return URL(fileURLWithPath: Bundle.main.path(forResource: "sensor-data", ofType: "json")!)
    }

    private var documentsDirectory: URL!
    private var sensorDataJsonUrl: URL! {
        return documentsDirectory.appendingPathComponent(sensorDataJsonName)
    }
    private var sensorDataZipUrl: URL! {
        return documentsDirectory.appendingPathComponent(sensorDataZipName)
    }
    private var sensorDataTempZipUrl: URL! {
        let timestamp = Int(Date().timeIntervalSince1970)
        return documentsDirectory.appendingPathComponent("\(sensorDataFileName)-\(timestamp).\(zip)")
    }

    private let fileNameDateFormatter = DateFormatter(dateFormat: Constants.DateFormat.fileTimestamp)
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    init() {
        documentsDirectory = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first
    }

    // MARK: - Public Functions

    func saveData(_ newData: [String: Any], toKey key: String) {
        var sensorData = getSensorData()
        var data = sensorData[key] as? [String: Any] ?? [:]
        data += newData
        sensorData[key] = data
        saveSensorData(sensorData)
    }

    func uploadSensorData(
        withReceptivity receptivity: Receptivity,
//        atLocation location: CLLocationCoordinate2D,
        message: String) -> Observable<Void> {

        log.info("sending sensor data")

//        prepareSensoreDataForSending(receptivity: receptivity, location: location)
//        compressSensorData()
//        deleteSensorDataJson()

        return uploadData(message: message)
    }

    func deleteSensorDataJson() {
        do {
            if FileManager.default.fileExists(atPath: sensorDataJsonUrl.path) {
                try FileManager.default.removeItem(at: sensorDataJsonUrl)
            }
        } catch {
            log.error(error)
        }
    }

    // MARK: - Private Functions

    private func saveSensorData(_ sensorData: [String: Any]) {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: sensorData, options: []),
            let jsonString = String(data: jsonData, encoding: .utf8)
            else {
                return
        }

        try? jsonString.write(to: sensorDataJsonUrl, atomically: true, encoding: .utf8)
    }

    private func getSensorData() -> [String: Any] {
        guard let jsonString = try? String(contentsOf: sensorDataJsonUrl, encoding: .utf8),
            let jsonData = jsonString.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: jsonData, options: []),
            let validJson = json as? [String: Any]
            else {
                if let phoneId = UserDefaults.standard.string(
                    forKey: Constants.UserDefaults.phoneIdKey) {
                    return ["phoneId": phoneId]
                } else {
                    return [:]
                }
        }

        return validJson
    }

    private func prepareSensoreDataForSending(
        receptivity: Receptivity, location: CLLocationCoordinate2D) {

        let dateValue = UserDefaults.standard.value(
            forKey: Constants.TrackingInfos.trackingEndTimestampKey)
        let date = dateValue as? Date ?? Date()

        saveData(
            [date.stringTimeIntervalSince1970InMilliseconds: receptivity.rawValue],
            toKey: receptivityKey
        )

        let locationData = ["lat": location.latitude, "long": location.longitude]
        saveData(
            [date.stringTimeIntervalSince1970InMilliseconds: locationData],
            toKey: locationKey
        )
    }

    private func compressSensorData() {
        do {
            _ = try Zip.quickZipFiles([mockDataJsonUrl/*sensorDataJsonUrl*/], fileName: sensorDataFileName)
        } catch {
            print(error)
        }
    }

    // Presentation Version
    private func uploadData(message: String) -> Observable<Void> {
        return Observable.create { [weak self] observer in
            guard let strongSelf = self else {
                observer.onError(UploadError.instanceGone)
                return Disposables.create()
            }

            let jsonOpt: Any
            do {
                let data = try Data(contentsOf: strongSelf.mockDataJsonUrl)
                jsonOpt = try JSONSerialization.jsonObject(with: data, options: [])
            } catch {
                observer.onError(UploadError.instanceGone)
                return Disposables.create()
            }

            guard let json = jsonOpt as? [String : Any] else {
                observer.onError(UploadError.parsingFailed)
                return Disposables.create()
            }

            guard let phoneId = UserDefaults.standard.string(
                forKey: Constants.UserDefaults.phoneIdKey) else {
                    observer.onError(UploadError.missingPhoneId)
                    return Disposables.create()
            }

            let endpoint = ServerAPI.newDataJson(
                id: phoneId,
                message: message,
                data: json
            )

            let uploadDisposable = apiProvider.rx.request(endpoint)
                .asObservable()
                .filterSuccessfulStatusCodes()
                .subscribe(onNext: { _ in
                    observer.onNext(())
                    observer.onCompleted()
                }, onError: { observer.onError($0) })

            return Disposables.create {
                return uploadDisposable.dispose()
            }
        }
    }

    // Actual Version
    //    private func uploadData(message: String) -> Observable<Void> {
    //        return Observable.create { [weak self] observer in
    //            guard let strongSelf = self else {
    //                observer.onError(UploadError.instanceGone)
    //                return Disposables.create()
    //            }
    //
    //            guard FileManager.default.fileExists(atPath: strongSelf.sensorDataZipUrl.path) else {
    //                observer.onNext(())
    //                observer.onCompleted()
    //                return Disposables.create()
    //            }
    //
    //            guard let zipData = try? Data(contentsOf: strongSelf.sensorDataZipUrl) else {
    //                observer.onError(UploadError.missingZip)
    //                return Disposables.create()
    //            }
    //
    //            guard let phoneId = UserDefaults.standard.string(
    //                forKey: Constants.UserDefaults.phoneIdKey) else {
    //                observer.onError(UploadError.missingPhoneId)
    //                return Disposables.create()
    //            }
    //
    //            let endpoint = ServerAPI.newData(
    //                id: phoneId,
    //                message: message,
    //                data: zipData,
    //                fileName: strongSelf.fileNameDateFormatter.string(from: Date()) + ".zip"
    //            )
    //
    //            let uploadDisposable = apiProvider.rx.request(endpoint)
    //                .asObservable()
    //                .filterSuccessfulStatusCodes()
    //                .map { [weak self] _ in
    //                    self?.deleteSensorDataZip()
    //                }
    //                .flatMap { [weak self] _ -> Observable<Void> in
    //                    guard let strongSelf = self else {
    //                        return Observable.error(UploadError.instanceGone)
    //                    }
    //                    strongSelf.renameTempZipToCurrent()
    //                    return strongSelf.uploadData(message: "") // queue messages
    //                }
    //                .subscribe(onNext: { _ in
    //                    observer.onNext(())
    //                    observer.onCompleted()
    //                }, onError: { [weak self] in
    //                    guard let strongSelf = self else {
    //                        observer.onError(UploadError.instanceGone)
    //                        return
    //                    }
    //
    //                    strongSelf.renameCurrentZipToTemp()
    //                    observer.onError($0)
    //                })
    //
    //            return Disposables.create {
    //                return uploadDisposable.dispose()
    //            }
    //        }
    //    }

    private func renameCurrentZipToTemp() {
        do {
            try FileManager.default.moveItem(at: sensorDataZipUrl, to: sensorDataTempZipUrl)
        } catch {
            log.error(error)
        }
    }

    private func renameTempZipToCurrent() {
        do {
            let files = try FileManager.default.contentsOfDirectory(atPath: documentsDirectory.path)
            var tempZip: URL?
            for file in files {
                if file.components(separatedBy: ".").last == zip {
                    tempZip = documentsDirectory.appendingPathComponent(file)
                    break
                }
            }

            if let tempZip = tempZip {
                try FileManager.default.moveItem(at: tempZip, to: sensorDataZipUrl)
            }

        } catch {
            log.error(error)
        }
    }

    func deleteSensorDataZip() {
        do {
            if FileManager.default.fileExists(atPath: sensorDataZipUrl.path) {
                try FileManager.default.removeItem(at: sensorDataZipUrl)
            }
        } catch {
            log.error(error)
        }
    }

}
