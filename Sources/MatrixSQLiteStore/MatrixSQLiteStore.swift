
import Foundation
import GRDB
import MatrixClient
import MatrixCore

public struct MatrixSQLiteStore {
    var dbWriter: DatabaseWriter

    public init(_ dbWriter: DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrate()
    }

    public init(path: String) throws {
        dbWriter = try DatabasePool(path: path)
        try migrate()
    }

    public static func inMemory() -> Self {
        try! MatrixSQLiteStore(DatabaseQueue())
    }

    private func migrate() throws {
        try migrator.migrate(dbWriter)
    }

    // TODO: lazy instead of computed?
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        #if DEBUG
            // Speed up development by nuking the database when migrations change
            // See https://github.com/groue/GRDB.swift/blob/master/Documentation/Migrations.md#the-erasedatabaseonschemachange-option
            migrator.eraseDatabaseOnSchemaChange = true
        #endif

        migrator.registerMigration("createAccount") { db in
            try db.create(table: "account") { t in
                t.column("id", .text).notNull().indexed().primaryKey().unique()
                t.column("name", .text).notNull()
                t.column("displayName", .text)
                t.column("homeserver", .text).notNull()
                t.column("device_id", .text).notNull()
            }
        }

        migrator.registerMigration("createRoomsAndMessages") { db in
            try db.create(table: "room_state") { t in
                t.column("event_id", .text).notNull().primaryKey()
                t.column("room_id", .text).notNull().indexed()
                t.column("type", .text).notNull()
                t.column("state_key", .text)
                t.column("content", .text)
            }

            try db.create(
                index: "room_state_type_key_index",
                on: "room_state",
                columns: ["room_id", "type", "state_key"],
                options: .unique
            )

            try db.create(index: "room_state_type_index", on: "room_state", columns: ["room_id", "type"])
        }

        return migrator
    }
}

extension MatrixSQLiteStore: MatrixStore {
    public func saveAccountInfo(account: MatrixSQLAccountInfo) async throws {
        try await dbWriter.write { [account] db in
            try account.save(db)
            try account.saveToKeychain()
        }
    }

    public func getAccountInfo(accountID: MatrixFullUserIdentifier) async throws -> MatrixSQLAccountInfo {
        let account = try await dbWriter.read { db in
            try MatrixSQLAccountInfo.fetchOne(db, key: accountID.FQMXID)
        }

        guard var account = account else {
            throw SQLError.missingData
        }

        account.accessToken = try MatrixSQLAccountInfo.getFromKeychain(account: accountID)

        return account
    }

    public func getAccountInfos() async throws -> [MatrixSQLAccountInfo] {
        let accounts = try await dbWriter.read { db in
            try MatrixSQLAccountInfo.fetchAll(db)
        }

        return try accounts.map { account in
            var account = account
            account.accessToken = try MatrixSQLAccountInfo.getFromKeychain(account: account.mxID)
            return account
        }
    }

    public func deleteAccountInfo(account: MatrixSQLAccountInfo) async throws {
        _ = try await dbWriter.write { db in
            try account.delete(db)
        }
        try account.deleteFromKeychain()
    }
}

public extension MatrixSQLiteStore {
    enum SQLError: Error {
        case invalidType
        case missingData
    }
}
