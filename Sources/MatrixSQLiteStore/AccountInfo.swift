//
//  File.swift
//
//
//  Created by Finn Behrens on 16.04.22.
//

import Foundation
import GRDB
import MatrixClient
import MatrixCore

public struct MatrixSQLAccountInfo: MatrixStoreAccountInfo {
    public init(
        name: String,
        displayName: String? = nil,
        mxID: MatrixFullUserIdentifier,
        homeServer: MatrixHomeserver,
        accessToken: String? = nil,
        deviceID: String
    ) {
        self.name = name
        self.displayName = displayName
        self.mxID = mxID
        self.homeServer = homeServer
        self.accessToken = accessToken
        self.deviceID = deviceID
    }

    public init?(_ homeserver: MatrixHomeserver, login: MatrixLogin) {
        guard let mxID = login.userId,
              let accessToken = login.accessToken,
              let deviceID = login.deviceId
        else {
            return nil
        }
        self.init(
            name: mxID.localpart,
            displayName: nil,
            mxID: mxID,
            homeServer: homeserver,
            accessToken: accessToken,
            deviceID: deviceID
        )
    }

    public typealias AccountIdentifier = MatrixFullUserIdentifier

    public var name: String

    public var displayName: String?

    public var mxID: MatrixFullUserIdentifier

    public var homeServer: MatrixHomeserver

    public var accessToken: String?

    public var deviceID: String
}

extension MatrixSQLAccountInfo: Codable, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String = "account"

    enum CodingKeys: String, CodingKey {
        case name
        case displayName
        case mxID = "id"
        case homeServer = "homeserver"
        case deviceID = "device_id"
    }
}
