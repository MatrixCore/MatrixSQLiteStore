//
//  File.swift
//
//
//  Created by Finn Behrens on 05.05.22.
//

import Foundation
import GRDB

public struct MatrixStoreRoomAccount: Codable {
    public var accountId: Int64
    public var roomId: Int64

    public var localMuted: Bool?
    // public var localName: String?
}

public extension MatrixStoreRoomAccount {
    static let account = belongsTo(MatrixSQLAccountInfo.self)
    var account: QueryInterfaceRequest<MatrixSQLAccountInfo> {
        request(for: Self.account)
    }

    static let room = belongsTo(MatrixStoreRoom.self)
    var room: QueryInterfaceRequest<MatrixStoreRoom> {
        request(for: Self.room)
    }
}

extension MatrixStoreRoomAccount: TableRecord, FetchableRecord, PersistableRecord {
    public static var databaseTableName: String = "room_account_join"

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case roomId = "room_id"
        case localMuted = "local_muted"
    }
}
