//
//  File.swift
//
//
//  Created by Finn Behrens on 05.05.22.
//

import Foundation
import GRDB
import MatrixClient

public struct MatrixStoreHandle: Codable {
    public init(
        mxId: MatrixFullUserIdentifier,
        displayName: String? = nil,
        avatarUrl: String? = nil,
        avatarFile: String? = nil
    ) {
        self.mxId = mxId
        self.displayName = displayName
        self.avatarUrl = avatarUrl
        self.avatarFile = avatarFile
    }

    public var id: Int64?
    public var mxId: MatrixFullUserIdentifier
    public var displayName: String?
    public var avatarUrl: String?
    public var avatarFile: String?
}

extension MatrixStoreHandle: FetchableRecord, MutablePersistableRecord {
    public static var databaseTableName: String = "handle"

    enum CodingKeys: String, CodingKey {
        case id
        case mxId = "mxid"
        case displayName = "display_name"
        case avatarUrl = "avatar_url"
        case avatarFile = "avatar_file"
    }

    public mutating func didInsert(with rowID: Int64, for _: String?) {
        id = rowID
    }
}
