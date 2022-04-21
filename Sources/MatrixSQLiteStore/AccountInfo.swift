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
        accessToken: String? = nil
    ) {
        self.name = name
        self.displayName = displayName
        self.mxID = mxID
        self.homeServer = homeServer
        self.accessToken = accessToken
    }

    public typealias AccountIdentifier = MatrixFullUserIdentifier

    public var name: String

    public var displayName: String?

    public var mxID: MatrixFullUserIdentifier

    public var homeServer: MatrixHomeserver

    public var accessToken: String?
}

extension MatrixSQLAccountInfo: Codable, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String = "account"

    enum CodingKeys: String, CodingKey {
        case name
        case displayName
        case mxID = "id"
        case homeServer = "homeserver"
    }
}
