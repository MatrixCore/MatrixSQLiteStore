
import Foundation
import GRDB
import MatrixClient
import MatrixCore

@available(swift, introduced: 5.5)
@available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *)
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

    /// Create a database in memory, useful to feed previews with data.
    ///
    /// This uses a `DatabaseQueue`, therefore a not advised for production use.
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
            migrator.eraseDatabaseOnSchemaChange = false // TODO: reenable
        #endif

        migrator.registerMigration("init") { db in
            try db.create(table: "account") { t in
                t.column("id", .integer).notNull().primaryKey(autoincrement: true).unique()
                t.column("mxid", .text).notNull().indexed().unique()
                t.column("name", .text).notNull()
                t.column("displayName", .text)
                t.column("homeserver", .text).notNull()
                t.column("device_id", .text).notNull()
            }

            try db.create(table: "handle") { t in
                t.column("id", .integer).notNull().primaryKey(autoincrement: true).unique()
                t.column("mxid", .text).notNull().indexed()
                t.column("display_name", .text)
                t.column("avatar_url", .text)
                t.column("avatar_file", .text)
            }
        }

        migrator.registerMigration("events") { db in
            try db.create(table: "event") { t in
                t.column("streaming_order", .integer).unique().notNull().primaryKey(autoincrement: true)
                t.column("topological_ordering", .integer).notNull()
                t.column("event_id", .text).notNull().unique().indexed()
                // t.column("room_id", .text).notNull()
                t.column("room_id", .integer).references("room", onDelete: .cascade).notNull()
                t.column("type", .text).notNull()
                t.column("state_key", .text)
                t.column("printable", .boolean)
                t.column("sender_id", .integer).references("handle", column: "id", onDelete: .cascade).notNull()
                t.column("content", .text)
            }

            try db.create(
                index: "events_order_room",
                on: "event",
                columns: ["room_id", "topological_ordering", "streaming_order"]
            )

            try db.create(table: "room") { t in
                t.column("id", .integer).primaryKey(autoincrement: true).unique()
                t.column("room_id", .text).notNull()
                t.column("displayname", .text)
                t.column("avatar_url", .text)
                t.column("avatar_file", .text)
                t.column("alias", .text)
                t.column("topic", .text)
                t.column("version", .text)
            }

            try db.create(table: "room_account_join") { t in
                t.column("account_id", .text).references("account", column: "id", onDelete: .cascade).notNull()
                t.column("room_id", .text).references("room", onDelete: .cascade).notNull()
                t.column("local_muted", .boolean).defaults(to: false)
                // t.column("local_name", .text)
            }
        }

        return migrator
    }
}

public extension MatrixSQLiteStore /*: MatrixStore */ {
    func saveAccountInfo(account: MatrixSQLAccountInfo) async throws {
        try await dbWriter.write { [account] db in
            try account.save(db)
            try account.saveToKeychain()
        }
    }

    func getAccountInfo(accountID: MatrixFullUserIdentifier) async throws -> MatrixSQLAccountInfo {
        let account = try await dbWriter.read { db in
            try MatrixSQLAccountInfo.fetchOne(db, key: accountID.FQMXID)
        }

        guard var account = account else {
            throw SQLError.missingData
        }

        account.accessToken = try MatrixSQLAccountInfo.getFromKeychain(account: accountID)

        return account
    }

    func getAccountInfos() async throws -> [MatrixSQLAccountInfo] {
        let accounts = try await dbWriter.read { db in
            try MatrixSQLAccountInfo.fetchAll(db)
        }

        return try accounts.map { account in
            var account = account
            account.accessToken = try MatrixSQLAccountInfo.getFromKeychain(account: account.mxID)
            return account
        }
    }

    func deleteAccountInfo(account: MatrixSQLAccountInfo) async throws {
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
