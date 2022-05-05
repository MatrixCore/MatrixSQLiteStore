//
//  File.swift
//
//
//  Created by Finn Behrens on 24.04.22.
//

import AnyCodable
import Foundation
import GRDB
import MatrixClient
import MatrixCore

public struct MatrixRoomState: MatrixStoreRoomState {
    public init(roomId: String, event: MatrixStateEvent) throws {
        guard let eventId = event.eventID,
              let sender = event.sender
        else {
            throw MatrixCodableStateEventType.StateTypeError.missingTypes
        }
        self.eventId = eventId
        self.roomId = roomId
        stateKey = event.stateKey
        // self.sender = sender
        _content = event
    }

    public var eventId: String
    public var roomId: String

    public var stateKey: String

    public var sender: MatrixFullUserIdentifier? {
        _content.sender
    }

    // TODO: custom type in MatrixClient?
    public var contentType: String {
        type(of: content).type
    }

    // TODO: some event type?
    // @MatrixCodableStateEventType
    private var _content: MatrixStateEvent

    public var content: MatrixStateEventType {
        get {
            _content.content
        }
        set {
            _content.content = newValue
        }
    }
}

extension MatrixRoomState: Codable, FetchableRecord, PersistableRecord, Equatable, Hashable {
    public static func == (lhs: MatrixRoomState, rhs: MatrixRoomState) -> Bool {
        lhs.eventId == rhs.eventId &&
            lhs.roomId == rhs.roomId &&
            lhs.stateKey == rhs.stateKey &&
            lhs.contentType == rhs.contentType
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(eventId)
        hasher.combine(roomId)
        hasher.combine(stateKey)
        hasher.combine(contentType)
    }

    public static var databaseTableName: String = "room_state"

    enum CodingKeys: String, CodingKey {
        case eventId = "event_id"
        case roomId = "room_id"
        case contentType = "type"
        case stateKey = "state_key"
        case content
    }

    enum Columns {
        static let eventId = Column(CodingKeys.eventId)
        static let roomId = Column(CodingKeys.roomId)
        static let contentType = Column(CodingKeys.contentType)
        static let stateKey = Column(CodingKeys.stateKey)
        static let content = Column(CodingKeys.content)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        eventId = try container.decode(String.self, forKey: .eventId)
        roomId = try container.decode(String.self, forKey: .roomId)
        stateKey = try container.decode(String.self, forKey: .stateKey)

        _content = try container.decode(MatrixStateEvent.self, forKey: .content)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(eventId, forKey: .eventId)
        try container.encode(roomId, forKey: .roomId)
        try container.encode(stateKey, forKey: .stateKey)
        try container.encode(contentType, forKey: .contentType)

        try container.encode(_content, forKey: .content)
    }

    /* public static func databaseJSONEncoder(for column: String) -> JSONEncoder {
         let encoder = JSONEncoder()
         encoder.outputFormatting = [.sortedKeys]
         encoder.dateEncodingStrategy = .millisecondsSince1970
         encoder.dataEncodingStrategy = .base64
         encoder.nonConformingFloatEncodingStrategy = .throw
         encoder.outputFormatting = .sortedKeys
         encoder.userInfo[.matrixEventTypes] = MatrixClient.eventTypes
         encoder.userInfo[.matrixMessageTypes] = MatrixClient.messageTypes
         encoder.userInfo[.matrixStateEventTypes] = MatrixClient.stateTypes

         return encoder
     } */

    public static var databaseDecodingUserInfo: [CodingUserInfoKey: Any] = [
        .matrixEventTypes: MatrixClient.eventTypes,
        .matrixMessageTypes: MatrixClient.messageTypes,
        .matrixStateEventTypes: MatrixClient.stateTypes,
    ]

    public static var databaseEncodingUserInfo: [CodingUserInfoKey: Any] = Self.databaseDecodingUserInfo
}

public extension MatrixSQLiteStore {
    typealias RoomState = MatrixRoomState

    func addRoomState(state: MatrixRoomState) async throws {
        try await dbWriter.write { db in
            /* try? db.execute(
                 sql: "DELETE FROM \"\(MatrixRoomState.databaseTableName)\" INDEXED BY \"room_state_type_key_index\" WHERE room_id = ? AND type = ? AND state_key = ?",
                 arguments: [state.roomId, state.contentType, state.stateKey]
             ) */
            try state.insert(db)
        }
    }

    func getRoomState(roomId: String) async throws -> [RoomState] {
        try await dbWriter.read { db in
            try RoomState.fetchAll(
                db,
                sql: "SELECT * FROM room_state INDEXED BY room_state_on_room_id WHERE room_id = ?",
                arguments: [roomId]
            )
        }
    }

    func getRoomState(eventId: String) async throws -> RoomState? {
        try await dbWriter.read { db in
            try RoomState.fetchOne(db, sql: "SELECT * FROM room_state WHERE event_id = ?", arguments: [eventId])
        }
    }

    func getRoomState(roomId: String, stateType: String) async throws -> [RoomState] {
        try await dbWriter.read { db in
            try RoomState.fetchAll(
                db,
                sql: "SELECT * FROM room_state INDEXED BY room_state_type_inex WHERE room_id = ? AND type = ?",
                arguments: [roomId, stateType]
            )
        }
    }

    func getRoomState(roomId: String, stateKey: String) async throws -> [RoomState] {
        try await dbWriter.read { db in
            try RoomState.fetchAll(
                db,
                sql: "SELECT * FROM room_state WHERE room_id = ? and state_key = ?",
                arguments: [roomId, stateKey]
            )
        }
    }

    /// - Throws: An error of type ``DatabaseError``
    func getRoomState(roomId: String, stateType: String, stateKey: String) async throws -> [RoomState] {
        try await dbWriter.read { db in
            try RoomState.fetchAll(
                db,
                sql: "SELECT * FROM room_state INDEXED BY room_state_key_index WHERE room_id = ? AND type = ? AND state_key = ?",
                arguments: [roomId, stateType, stateKey]
            )
        }
    }
}
