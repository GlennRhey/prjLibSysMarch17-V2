-- Insert Programming Books
INSERT INTO Books (ISBN, Title, Author, Category, TotalCopies, AvailableCopies, Description, CreatedAt)
VALUES 
('9780132350884', 'Clean Code: A Handbook of Agile Software Craftsmanship', 'Robert C. Martin', 'Programming', 5, 5, 'A handbook of agile software craftsmanship covering best practices for writing clean, maintainable code.', GETDATE()),
('9780201616224', 'The Pragmatic Programmer', 'Andrew Hunt and David Thomas', 'Programming', 8, 7, 'From journeyman to master - practical advice for improving your programming skills and career.', GETDATE()),
('9780262510875', 'Structure and Interpretation of Computer Programs', 'Harold Abelson and Gerald Jay Sussman', 'Programming', 3, 3, 'A classic textbook about computer programming, focusing on fundamental concepts and abstraction.', GETDATE());

-- Insert Artificial Intelligence Books
INSERT INTO Books (ISBN, Title, Author, Category, TotalCopies, AvailableCopies, Description, CreatedAt)
VALUES 
('9780134610993', 'Artificial Intelligence: A Modern Approach', 'Stuart Russell and Peter Norvig', 'Artificial Intelligence', 6, 4, 'Comprehensive textbook on artificial intelligence covering theory and practice of AI systems.', GETDATE()),
('9781101970317', 'Life 3.0: Being Human in the Age of Artificial Intelligence', 'Max Tegmark', 'Artificial Intelligence', 4, 4, 'Exploring the future of AI and its impact on humanity, society, and consciousness.', GETDATE()),
('9780262039406', 'Deep Learning', 'Ian Goodfellow, Yoshua Bengio, Aaron Courville', 'Artificial Intelligence', 7, 6, 'Comprehensive introduction to deep learning, covering mathematical and conceptual foundations.', GETDATE());

-- Insert Data Communications Books
INSERT INTO Books (ISBN, Title, Author, Category, TotalCopies, AvailableCopies, Description, CreatedAt)
VALUES 
('9780073376226', 'Data Communications and Networking', 'Behrouz A. Forouzan', 'Data Communications', 10, 8, 'Comprehensive introduction to data communications and networking fundamentals.', GETDATE()),
('9781108419437', 'Computer Networking: Principles Protocols and Practice', 'Olivier Bonaventure', 'Data Communications', 5, 5, 'Modern approach to computer networking with practical examples and protocols.', GETDATE()),
('9781260454043', 'CompTIA Network+ Certification All-in-One Exam Guide', 'Mike Meyers', 'Data Communications', 12, 9, 'Complete study guide for CompTIA Network+ certification exam preparation.', GETDATE());

-- Insert Literature Books
INSERT INTO Books (ISBN, Title, Author, Category, TotalCopies, AvailableCopies, Description, CreatedAt)
VALUES 
('9780061120084', 'To Kill a Mockingbird', 'Harper Lee', 'Literature', 15, 12, 'Classic American novel dealing with racial injustice and childhood innocence in the American South.', GETDATE()),
('9780141439518', 'Pride and Prejudice', 'Jane Austen', 'Literature', 8, 6, 'Romantic novel of manners depicting the English gentry of the early 19th century.', GETDATE()),
('9780451524935', '1984', 'George Orwell', 'Literature', 20, 15, 'Dystopian social science fiction novel and cautionary tale about totalitarianism.', GETDATE());

-- Insert Business Books
INSERT INTO Books (ISBN, Title, Author, Category, TotalCopies, AvailableCopies, Description, CreatedAt)
VALUES 
('9780743269513', 'The 7 Habits of Highly Effective People', 'Stephen R. Covey', 'Business', 6, 4, 'Powerful lessons in personal change that have transformed millions of lives.', GETDATE()),
('9780066620992', 'Good to Great', 'Jim Collins', 'Business', 7, 5, 'Why some companies make the leap and others dont - based on extensive research.', GETDATE()),
('9780374533557', 'Thinking Fast and Slow', 'Daniel Kahneman', 'Business', 9, 7, 'Nobel laureate explores the two systems that drive the way we think and make decisions.', GETDATE());

-- Verify the data was inserted
SELECT ISBN, Title, Author, Category, TotalCopies, AvailableCopies, LEFT(Description, 50) + '...' AS DescriptionPreview, CreatedAt
FROM Books
ORDER BY Category, Title;