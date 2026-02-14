You are a senior API architect.

Generate a complete OpenAPI 3.1 YAML technical requirements for a Library Management System backend built as a Rails API-only application.

User story:
As a librarian, I need to manage the catalog and track borrowings so the library inventory stays accurate.
As a member, I want to search books and manage my borrowings.

That's the busines requirements:
Backend
● Authentication and Authorization:
○ Users should be able to register, log in, and log out.
○ Two types of users: Librarian and Member.
○ Only Librarian users should be able to add, edit, or delete books.
● Book Management:
○ Ability to add a new book with details like title, author, genre, ISBN, and total
copies.
○ Ability to edit and delete book details.
○ Search functionality:
■ Users should be able to search for a book by title, author, or genre.
● Borrowing and Returning:
○ Member users should be able to borrow a book if it's available. They can't borrow
the same book multiple times.
○ The system should track when a book was borrowed and when it's due (2
weeks from the borrowing date).
○ Librarian users can mark a book as returned.
● Dashboard:
○ Librarian:
■ A dashboard showing total books, total borrowed books, books due today,
and a list of members with overdue books.
○ Member:
■ A dashboard showing books they've borrowed, their due dates, and any
overdue books.
● API Endpoints:
○ Develop a RESTful API that allows CRUD operations for books and borrowings.
○ Ensure proper status codes and responses for each endpoint.