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
    public var name: String

    public var displayName: String?

    public var mxID: MatrixUserIdentifier

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
