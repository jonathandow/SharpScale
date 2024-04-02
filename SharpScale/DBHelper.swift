import Foundation
import SQLite3

class SQLiteHelper {
    var db: OpaquePointer?
    let dbName = "SharpScaleDB.sqlite"
    
    init() {
        copyDatabaseIfNeeded()
        db = openDatabase()
        createTables()
    }
    
    func openDatabase() -> OpaquePointer? {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent(dbName)
        print(fileURL.path)
        var db: OpaquePointer? = nil
        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database")
            return nil
        }
        return db
    }
    
    func createTables() {
        createRecipesTable()
        createIngredientsTable()
    }
    
    private func createRecipesTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS Recipes(
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Name TEXT,
        Ingredients TEXT,
        Steps TEXT);
        """
        executeStatement(createTableString, successMessage: "Recipes table created.")
    }
    
        func fetchAllRecipes() -> [Recipe] {
            let queryStatementString = "SELECT Id, Name, Ingredients, Steps FROM Recipes;"
            var queryStatement: OpaquePointer? = nil
            var recipes = [Recipe]()
            
            if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let id = sqlite3_column_int(queryStatement, 0)
                    
                    guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1),
                          let queryResultCol2 = sqlite3_column_text(queryStatement, 2),
                          let queryResultCol3 = sqlite3_column_text(queryStatement, 3) else {
                        print("Query result is nil.")
                        continue
                    }
                    let name = String(cString: queryResultCol1)
                    let ingredients = String(cString: queryResultCol2)
                    let steps = String(cString: queryResultCol3)
                    
                    let recipe = Recipe(id: Int(id), name: name, ingredients: ingredients, steps: steps)
                    recipes.append(recipe)
                }
            } else {
                print("SELECT statement could not be prepared")
            }
            
            sqlite3_finalize(queryStatement)
            return recipes
        }
    
    private func createIngredientsTable() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS Ingredients(
        Id INTEGER PRIMARY KEY AUTOINCREMENT,
        Name TEXT,
        Density REAL);
        """
        executeStatement(createTableString, successMessage: "Ingredients table created.")
    }
    func fetchAllIngredients() -> [Ingredient] {
        let queryStatementString = "SELECT Id, Name, Density FROM Ingredients;"
        var queryStatement: OpaquePointer? = nil
        var ingredients = [Ingredient]()
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                
                guard let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                else {
                    print("Query result is nil.")
                    continue
                }
                let name = String(cString: queryResultCol1)
                let density = sqlite3_column_double(queryStatement, 2)
                
                let ingredient = Ingredient(id: Int(id), name: name, density: density)
                ingredients.append(ingredient)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        
        sqlite3_finalize(queryStatement)
        return ingredients
    }
    func copyDatabaseIfNeeded() {
        let fileManager = FileManager.default
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let finalDatabaseURL = documentsDirectoryURL.appendingPathComponent("SharpScaleDB.sqlite")

        if !fileManager.fileExists(atPath: finalDatabaseURL.path) {
            do {
                if let bundleURL = Bundle.main.url(forResource: "SharpScaleDB", withExtension: "sqlite") {
                    try fileManager.copyItem(at: bundleURL, to: finalDatabaseURL)
                    print("Database successfully copied to Documents directory.")
                }
            } catch {
                print("Error copying database: \(error)")
            }
        }
    }

    private func executeStatement(_ statementString: String, successMessage: String) {
            var statement: OpaquePointer? = nil
            if sqlite3_prepare_v2(db, statementString, -1, &statement, nil) == SQLITE_OK {
                if sqlite3_step(statement) == SQLITE_DONE {
                    print(successMessage)
                } else {
                    print("Could not execute statement.")
                }
            } else {
                print("Statement could not be prepared.")
            }
            sqlite3_finalize(statement)
    }
    func insertIngredient(name: String, density: Double) -> Bool {
        var insertStatement: OpaquePointer?
        let insertStatementString = """
        INSERT INTO ingredients (name, density) VALUES (?, ?);
        """
        var isSuccess = true
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_double(insertStatement, 2, density)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully Inserted Row.")
            } else {
                print("Error Inserting Row")
                isSuccess = false
            }
        } else {
            print("INSERT statement could not be prepared")
            isSuccess = false
        }
        sqlite3_finalize(insertStatement)
        return isSuccess
    }
    func insertRecipe(name: String, ingredients: String, steps: String) -> Bool {
        var insertStatement: OpaquePointer?
        let insertStatementString = """
        INSERT INTO recipes (name, ingredients, steps) VALUES (?, ?, ?);
        """
        var isSuccess = true
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_text(insertStatement, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 2, (ingredients as NSString).utf8String, -1, nil)
            sqlite3_bind_text(insertStatement, 3, (steps as NSString).utf8String, -1, nil)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Successfully Inserted Row.")
            } else {
                print("Error Inserting Row.")
                isSuccess = false
            }
        } else {
            print("INSERT statement could not be prepared.")
            isSuccess = false
        }
        sqlite3_finalize(insertStatement)
        return isSuccess
    }
    
    func deleteIngredient(id: Int) -> Bool {
        var deleteStatement: OpaquePointer?
        let deleteStatementString = "DELETE FROM ingredients WHERE Id = ?; REINDEX ingredients;"
        var isSuccess = true
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
                isSuccess = false
            }
        } else {
            print("DELETE statement could not be prepared")
            isSuccess = false
        }
        sqlite3_finalize(deleteStatement)
        return isSuccess
    }
    
    func deleteRecipe(id: Int) -> Bool {
        var deleteStatement: OpaquePointer?
        let deleteStatementString = "DELETE FROM recipes WHERE Id = ?; REINDEX recipes;"
        var isSuccess = true
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &deleteStatement, nil) == SQLITE_OK {
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                print("Successfully deleted row.")
            } else {
                print("Could not delete row.")
                isSuccess = false
            }
        } else {
            print("DELETE statement could not be prepared")
            isSuccess = false
        }
        sqlite3_finalize(deleteStatement)
        return isSuccess
    }
    
}
