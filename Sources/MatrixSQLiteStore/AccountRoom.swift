//
//  File.swift
//
//
//  Created by Finn Behrens on 29.04.22.
//

import Foundation
import GRDB
import MatrixClient

public struct MatrixAccountRoom {
    public var accountId: MatrixFullUserIdentifier
    public var roomId: String
    public var localMuted: Bool = false
}

extension MatrixAccountRoom: Codable, FetchableRecord, PersistableRecord, Equatable, Hashable {
    public static let databaseTableName: String = "account_room"

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case roomId = "room_id"
        case localMuted = "local_muted"
    }
}
