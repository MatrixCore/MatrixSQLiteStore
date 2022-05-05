//
//  File.swift
//
//
//  Created by Finn Behrens on 05.05.22.
//

import Foundation
import GRDB

public struct MatrixStoreRoom: Codable {
    public var id: Int64?
    public var roomId: String
    public var displayname: String?
    public var avatarUrl: String?
    public var avatarFile: String?
    public var alias: String?
    public var topic: String?
    public var version: String?
}

extension MatrixStoreRoom: FetchableRecord, MutablePersistableRecord {
    public static var databaseTableName: String = "room"

    public mutating func didInsert(with rowID: Int64, for _: String?) {
        id = rowID
    }

    enum CodingKeys: String, CodingKey {
        case id
        case roomId = "room_id"
        case displayname
        case avatarUrl = "avatar_url"
        case avatarFile = "avatar_file"
        case topic
        case version
    }
}
