using System;

namespace prjLibrarySystem.Models
{
    // Mirrors tblBooks:
    // ISBN (PK), Title, Author, Category, TotalCopies, AvailableCopies, Description, DateAdded
    public class Book
    {
        public string ISBN { get; set; }
        public string Title { get; set; }
        public string Author { get; set; }
        public string Category { get; set; }
        public int TotalCopies { get; set; }
        public int AvailableCopies { get; set; }
        public string Description { get; set; }
        public DateTime? DateAdded { get; set; }

        public Book()
        {
            DateAdded = DateTime.Now;
        }

        public Book(string isbn, string title, string author, string category, int totalCopies, int availableCopies, string description = "")
        {
            ISBN = isbn;
            Title = title;
            Author = author;
            Category = category;
            TotalCopies = totalCopies;
            AvailableCopies = availableCopies;
            Description = description;
            DateAdded = DateTime.Now;
        }

        public bool IsAvailable => AvailableCopies > 0;
        public int BorrowedCopies => TotalCopies - AvailableCopies;
    }
}