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

private let sensorDataFileName = "sensor-data"
private let sensorDataJsonName = "\(sensorDataFileName).json"
private let sensorDataZipName = "\(sensorDataFileName).zip"

class MBDataStore {

    private var documentsDirectory: URL!
    private var sensorDataJsonUrl: URL! {
        return documentsDirectory.appendingPathComponent(sensorDataJsonName)
    }
    private var sensorDataZipUrl: URL! {
        return documentsDirectory.appendingPathComponent(sensorDataZipName)
    }

    private lazy var fileNameDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return dateFormatter
    }()

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

    func compressSensorData() {
        do {
            _ = try Zip.quickZipFiles([sensorDataJsonUrl], fileName: sensorDataFileName)
        } catch {
            print(error)
        }
    }

    func sendSensorData() -> Observable<Void> {
        compressSensorData()
        guard let zipData = try? Data(contentsOf: sensorDataZipUrl),
            let phoneId = UserDefaults.standard.string(forKey: Constants.phoneIdKey) else {
            return Observable.just(())
        }

        let endpoint = ServerAPI.newData(
            id: phoneId,
            data: zipData,
            fileName: fileNameDateFormatter.string(from: Date()) + ".zip"
        )

        return apiProvider.rx.request(endpoint)
            .asObservable()
            .map { [weak self] _ in self?.deleteSensorData() }
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
                return [:]
        }

        return validJson
    }

    private func deleteSensorData() {
        do {
            try FileManager.default.removeItem(at: sensorDataJsonUrl)
            try FileManager.default.removeItem(at: sensorDataZipUrl)
        } catch {
            log.error(error)
        }
    }
}
