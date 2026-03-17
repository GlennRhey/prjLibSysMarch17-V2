using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Security.Cryptography;
using System.Text;

namespace prjLibrarySystem.Models
{
    public class DatabaseHelper
    {
        private static string ConnectionString =
            ConfigurationManager.ConnectionStrings["LibraryDB"]?.ConnectionString ??
            "Data Source=MSI\\SQLEXPRESS;Initial Catalog=dbLibrarySystem;Integrated Security=True";

        // ── Password hashing ──────────────────────────────────────────────────
        // SHA256, UTF-8 encoding, lowercase hex output
        // All password comparisons and updates go through this method.

        public static string HashPassword(string password)
        {
            using (SHA256 sha256 = SHA256.Create())
            {
                byte[] bytes = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                StringBuilder sb = new StringBuilder();
                foreach (byte b in bytes)
                    sb.Append(b.ToString("x2"));
                return sb.ToString();
            }
        }

        // ── Core helpers ──────────────────────────────────────────────────────

        public static DataTable ExecuteQuery(string query, SqlParameter[] parameters = null)
        {
            using (var connection = new SqlConnection(ConnectionString))
            using (var command = new SqlCommand(query, connection))
            {
                if (parameters != null) command.Parameters.AddRange(parameters);
                using (var adapter = new SqlDataAdapter(command))
                {
                    var dt = new DataTable();
                    adapter.Fill(dt);
                    return dt;
                }
            }
        }

        public static int ExecuteNonQuery(string query, SqlParameter[] parameters = null)
        {
            using (var connection = new SqlConnection(ConnectionString))
            using (var command = new SqlCommand(query, connection))
            {
                if (parameters != null) command.Parameters.AddRange(parameters);
                connection.Open();
                return command.ExecuteNonQuery();
            }
        }

        public static object ExecuteScalar(string query, SqlParameter[] parameters = null)
        {
            using (var connection = new SqlConnection(ConnectionString))
            using (var command = new SqlCommand(query, connection))
            {
                if (parameters != null) command.Parameters.AddRange(parameters);
                connection.Open();
                return command.ExecuteScalar();
            }
        }

        public static DataTable ExecuteStoredProcedure(string procedureName, SqlParameter[] parameters = null)
        {
            using (var connection = new SqlConnection(ConnectionString))
            using (var command = new SqlCommand(procedureName, connection))
            {
                command.CommandType = CommandType.StoredProcedure;
                if (parameters != null) command.Parameters.AddRange(parameters);
                using (var adapter = new SqlDataAdapter(command))
                {
                    var dt = new DataTable();
                    adapter.Fill(dt);
                    return dt;
                }
            }
        }

        public static bool TestConnection()
        {
            try
            {
                using (var connection = new SqlConnection(ConnectionString))
                {
                    connection.Open();
                    return true;
                }
            }
            catch { return false; }
        }

        // ── Authentication ─────────────────────────────────────────────────────
        // Accepts plain text password — hashes internally before DB comparison.

        public static User AuthenticateUser(string userId, string plainTextPassword)
        {
            string query = @"
                SELECT UserID, Role, FullName, Email, IsActive
                FROM   tblUsers
                WHERE  UserID       = @UserID
                  AND  PasswordHash = @PasswordHash
                  AND  IsActive     = 1";

            DataTable dt = ExecuteQuery(query, new SqlParameter[]
            {
                new SqlParameter("@UserID",       userId),
                new SqlParameter("@PasswordHash", HashPassword(plainTextPassword))
            });

            if (dt.Rows.Count == 0) return null;

            DataRow row = dt.Rows[0];
            return new User
            {
                UserID = row["UserID"].ToString(),
                Role = row["Role"].ToString(),
                FullName = row["FullName"]?.ToString() ?? "",
                Email = row["Email"]?.ToString() ?? "",
                IsActive = true
            };
        }

        // Authenticate student — returns full row including MemberID
        public static DataRow AuthenticateStudent(string userId, string plainTextPassword)
        {
            string query = @"
                SELECT u.UserID, u.Role, u.FullName, u.Email, u.IsActive,
                       m.MemberID, m.Course, m.YearLevel
                FROM   tblUsers   u
                INNER JOIN tblMembers m ON m.UserID = u.UserID
                WHERE  u.UserID       = @UserID
                  AND  u.PasswordHash = @PasswordHash
                  AND  u.IsActive     = 1
                  AND  u.Role         = 'Student'";

            DataTable dt = ExecuteQuery(query, new SqlParameter[]
            {
                new SqlParameter("@UserID",       userId),
                new SqlParameter("@PasswordHash", HashPassword(plainTextPassword))
            });

            return dt.Rows.Count > 0 ? dt.Rows[0] : null;
        }

        // ── Change Password ────────────────────────────────────────────────────
        // Accepts plain text passwords — hashes internally.

        public static bool ChangePassword(string userId, string currentPlainText, string newPlainText)
        {
            try
            {
                int count = Convert.ToInt32(ExecuteScalar(
                    @"SELECT COUNT(*) FROM tblUsers
                      WHERE UserID = @UserID AND PasswordHash = @Current AND IsActive = 1",
                    new SqlParameter[]
                    {
                        new SqlParameter("@UserID",  userId),
                        new SqlParameter("@Current", HashPassword(currentPlainText))
                    }));

                if (count == 0) return false;

                ExecuteNonQuery(
                    "UPDATE tblUsers SET PasswordHash = @New WHERE UserID = @UserID",
                    new SqlParameter[]
                    {
                        new SqlParameter("@New",    HashPassword(newPlainText)),
                        new SqlParameter("@UserID", userId)
                    });

                return true;
            }
            catch { return false; }
        }

        // ── Notification System ───────────────────────────────────────────────────
        // Email notification logging and management

        public static void CreateNotification(string type, string recipient,
            string subject, string message)
        {
            string query = @"
                INSERT INTO tblNotifications 
                (NotificationType, Recipient, Subject, Message, Status, CreatedAt)
                VALUES (@Type, @Recipient, @Subject, @Message, 'Pending', @CreatedAt)";

            ExecuteNonQuery(query, new SqlParameter[]
            {
                new SqlParameter("@Type",      type),
                new SqlParameter("@Recipient", recipient),
                new SqlParameter("@Subject",   subject),
                new SqlParameter("@Message",   message),
                new SqlParameter("@CreatedAt", DateTime.Now)
            });
        }

        public static void SendDueDateReminders()
        {
            // Find books due in 2 days
            string query = @"
                SELECT t.BorrowID, u.Email, b.Title, t.DueDate, m.FullName
                FROM tblTransactions t
                INNER JOIN tblMembers m ON t.MemberID = m.MemberID
                INNER JOIN tblUsers u ON m.UserID = u.UserID
                INNER JOIN tblBooks b ON t.ISBN = b.ISBN
                WHERE t.Status = 'Active'
                AND t.RequestStatus = 'Accepted'
                AND t.DueDate BETWEEN GETDATE() AND DATEADD(day, 2, GETDATE())";

            DataTable dueBooks = ExecuteQuery(query);

            foreach (DataRow row in dueBooks.Rows)
            {
                string email = row["Email"].ToString();
                string title = row["Title"].ToString();
                DateTime dueDate = Convert.ToDateTime(row["DueDate"]);
                string fullName = row["FullName"].ToString();

                string message = $@"
                    Dear {fullName},
                    
                    This is a friendly reminder that '{title}' is due on {dueDate:MMMM dd, yyyy}.
                    
                    Please return it to the library to avoid overdue charges.
                    
                    Thank you,
                    Library Management System";

                CreateNotification("EMAIL", email, "Book Due Date Reminder", message);

                // DueDateReminderSent column not in schema - skipped
            }
        }

        public static void SendBorrowConfirmation(string memberEmail, string memberName,
            string bookTitle, DateTime dueDate)
        {
            string message = $@"
                Dear {memberName},
                
                You have successfully borrowed '{bookTitle}'.
                Due Date: {dueDate:MMMM dd, yyyy}
                
                Please return it on time to avoid overdue charges.
                
                Thank you,
                Library Management System";

            CreateNotification("EMAIL", memberEmail, "Book Borrowed Successfully", message);
        }

        public static void SendOverdueNotice(string memberEmail, string memberName,
            string bookTitle, DateTime dueDate)
        {
            string message = $@"
                Dear {memberName},
                
                Your borrowed book '{bookTitle}' is OVERDUE!
                Due Date: {dueDate:MMMM dd, yyyy}
                Current Date: {DateTime.Now:MMMM dd, yyyy}
                
                Please return it immediately to avoid additional charges.
                
                Thank you,
                Library Management System";

            CreateNotification("EMAIL", memberEmail, "BOOK OVERDUE NOTICE", message);
        }
    }
}