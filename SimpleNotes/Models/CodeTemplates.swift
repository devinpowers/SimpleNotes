import Foundation

struct CodeTemplate: Identifiable {
    let id = UUID()
    let name: String
    let language: String
    let code: String

    var markdown: String {
        "```\(language)\n\(code)\n```"
    }
}

struct CodeTemplates {
    static let supportedLanguages = [
        "swift", "python", "javascript", "typescript", "go", "rust",
        "sql", "bash", "json", "yaml", "html", "plaintext"
    ]

    static let displayNames: [String: String] = [
        "swift": "Swift",
        "python": "Python",
        "javascript": "JavaScript",
        "typescript": "TypeScript",
        "go": "Go",
        "rust": "Rust",
        "sql": "SQL",
        "bash": "Bash",
        "json": "JSON",
        "yaml": "YAML",
        "html": "HTML/CSS",
        "plaintext": "Plain Text"
    ]

    static let templates: [CodeTemplate] = [
        CodeTemplate(
            name: "Swift Function",
            language: "swift",
            code: """
            func myFunction(param: String) -> String {
                // TODO: implement
                return param
            }
            """
        ),
        CodeTemplate(
            name: "Python Function",
            language: "python",
            code: """
            def my_function(param: str) -> str:
                \"\"\"Description of function.\"\"\"
                # TODO: implement
                return param
            """
        ),
        CodeTemplate(
            name: "JavaScript Function",
            language: "javascript",
            code: """
            function myFunction(param) {
                // TODO: implement
                return param;
            }
            """
        ),
        CodeTemplate(
            name: "Swift Struct",
            language: "swift",
            code: """
            struct MyModel {
                let id: UUID
                let name: String
                let createdAt: Date
            }
            """
        ),
        CodeTemplate(
            name: "Python Class",
            language: "python",
            code: """
            class MyClass:
                def __init__(self, name: str):
                    self.name = name

                def __repr__(self) -> str:
                    return f"MyClass(name={self.name})"
            """
        ),
        CodeTemplate(
            name: "API Request",
            language: "javascript",
            code: """
            const response = await fetch("https://api.example.com/data", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer TOKEN"
                },
                body: JSON.stringify({ key: "value" })
            });
            const data = await response.json();
            """
        ),
        CodeTemplate(
            name: "SQL Query",
            language: "sql",
            code: """
            SELECT
                u.id,
                u.name,
                COUNT(o.id) AS order_count
            FROM users u
            LEFT JOIN orders o ON o.user_id = u.id
            WHERE u.created_at >= '2024-01-01'
            GROUP BY u.id, u.name
            ORDER BY order_count DESC
            LIMIT 10;
            """
        ),
    ]
}
