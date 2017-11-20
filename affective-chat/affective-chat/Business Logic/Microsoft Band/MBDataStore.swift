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
private let heartRatesKey = "heartRates"

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

    func saveHeartRates(_ newHeartRateData: [HeartRateData]) {
        var sensorData = getSensorData()
        let heartRateDataInFile = sensorData[heartRatesKey] as? [[String: Any]] ?? []
        let heartRateData = heartRateDataInFile + newHeartRateData.map { $0.json }
        sensorData[heartRatesKey] = heartRateData
        saveSensorData(sensorData)
    }

    func compressSensorData() {
        do {
            let _ = try Zip.quickZipFiles([sensorDataJsonUrl], fileName: sensorDataFileName)
        } catch {
            print(error)
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
        compressSensorData()

        guard let zipData = try? Data(contentsOf: sensorDataZipUrl) else {
            return
        }

        let endpoint = ServerAPI.newData(
            id: "5a132032ad5a325b17a9b364",
            data: zipData,
            fileName: fileNameDateFormatter.string(from: Date())
        )

        apiProvider.rx.request(endpoint)
            .subscribe()
            .disposed(by: disposeBag)
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
}
