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
        private static readonly string ConnectionString =
            ConfigurationManager.ConnectionStrings["LibraryDB"]?.ConnectionString ??
            "Data Source=MSI\\SQLEXPRESS;Initial Catalog=dbLibrarySystem;Integrated Security=True";

        // ── Password hashing ──────────────────────────────────────────────────

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

        // ── Core DB helpers ───────────────────────────────────────────────────

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

        // ── Authentication ────────────────────────────────────────────────────

        public static User AuthenticateUser(string userId, string plainTextPassword)
        {
            DataTable dt = ExecuteQuery(@"
                SELECT UserID, Role, FullName, Email
                FROM   tblUsers
                WHERE  UserID       = @UserID
                  AND  PasswordHash = @PasswordHash
                  AND  IsActive     = 1",
                new SqlParameter[]
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
                Email = row["Email"]?.ToString() ?? ""
            };
        }

        // ── Password management ───────────────────────────────────────────────

        public static bool ChangePassword(string userId, string currentPlainText, string newPlainText)
        {
            try
            {
                int count = Convert.ToInt32(ExecuteScalar(@"
                    SELECT COUNT(*) FROM tblUsers
                    WHERE  UserID = @UserID AND PasswordHash = @Current AND IsActive = 1",
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

        // ── Borrow limits (dynamic from tblSystemSettings) ────────────────────

        public static (int maxBooks, int borrowDays) GetBorrowLimits(int memberId)
        {
            DataTable dt = ExecuteQuery(@"
                SELECT s.SettingKey, s.SettingValue
                FROM   tblSystemSettings s
                INNER JOIN tblMembers m ON m.MemberType = s.MemberType
                WHERE  m.MemberID = @MemberID",
                new SqlParameter[] { new SqlParameter("@MemberID", memberId) });

            int maxBooks = 3, borrowDays = 7; // safe fallback defaults
            foreach (DataRow row in dt.Rows)
            {
                if (row["SettingKey"].ToString() == "MaxBorrowedBooks")
                    maxBooks = Convert.ToInt32(row["SettingValue"]);
                if (row["SettingKey"].ToString() == "BorrowDuration")
                    borrowDays = Convert.ToInt32(row["SettingValue"]);
            }
            return (maxBooks, borrowDays);
        }

        // ── Audit logging ─────────────────────────────────────────────────────

        public static void WriteAuditLog(
            string userId,
            string userName,
            string action,
            string affectedTable,
            string affectedId = null,
            string oldValue = null,
            string newValue = null)
        {
            try
            {
                ExecuteNonQuery(@"
                    INSERT INTO tblAuditLogs
                        (UserID, UserName, Action, AffectedTable, AffectedID, OldValue, NewValue)
                    VALUES
                        (@UserID, @UserName, @Action, @AffectedTable, @AffectedID, @OldValue, @NewValue)",
                    new SqlParameter[]
                    {
                        new SqlParameter("@UserID",        userId),
                        new SqlParameter("@UserName",      (object)userName    ?? DBNull.Value),
                        new SqlParameter("@Action",        action),
                        new SqlParameter("@AffectedTable", affectedTable),
                        new SqlParameter("@AffectedID",    (object)affectedId  ?? DBNull.Value),
                        new SqlParameter("@OldValue",      (object)oldValue    ?? DBNull.Value),
                        new SqlParameter("@NewValue",      (object)newValue    ?? DBNull.Value)
                    });
            }
            catch { /* audit log failure must never break main functionality */ }
        }

        // ── Notifications ─────────────────────────────────────────────────────

        public static void CreateNotification(string type, string recipient,
            string subject, string message)
        {
            ExecuteNonQuery(@"
                INSERT INTO tblNotifications
                    (NotificationType, Recipient, Subject, Message, Status, CreatedAt)
                VALUES
                    (@Type, @Recipient, @Subject, @Message, 'Pending', @CreatedAt)",
                new SqlParameter[]
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
            DataTable dueBooks = ExecuteQuery(@"
                SELECT t.BorrowID, u.Email, b.Title, t.DueDate, m.FullName
                FROM   tblTransactions t
                INNER JOIN tblMembers m ON t.MemberID = m.MemberID
                INNER JOIN tblUsers   u ON m.UserID   = u.UserID
                INNER JOIN tblBooks   b ON t.ISBN     = b.ISBN
                WHERE  t.Status              = 'Active'
                  AND  t.RequestStatus       = 'Accepted'
                  AND  t.DueDateReminderSent = 0
                  AND  t.DueDate BETWEEN GETDATE() AND DATEADD(DAY, 2, GETDATE())");

            foreach (DataRow row in dueBooks.Rows)
            {
                string email = row["Email"].ToString();
                string title = row["Title"].ToString();
                string fullName = row["FullName"].ToString();
                DateTime dueDate = Convert.ToDateTime(row["DueDate"]);

                string message =
                    $"Dear {fullName}, this is a friendly reminder that '{title}' is due on " +
                    $"{dueDate:MMMM dd, yyyy}. Please return it to the library to avoid " +
                    $"overdue charges. Thank you, Library Management System";

                CreateNotification("EMAIL", email, "Book Due Date Reminder", message);

                ExecuteNonQuery(
                    "UPDATE tblTransactions SET DueDateReminderSent = 1 WHERE BorrowID = @BorrowID",
                    new SqlParameter[] { new SqlParameter("@BorrowID", row["BorrowID"]) });
            }
        }

        public static void SendBorrowConfirmation(string memberEmail, string memberName,
            string bookTitle, DateTime dueDate)
        {
            string message =
                $"Dear {memberName}, you have successfully borrowed '{bookTitle}'. " +
                $"Due Date: {dueDate:MMMM dd, yyyy}. Please return it on time. " +
                $"Thank you, Library Management System";

            CreateNotification("EMAIL", memberEmail, "Book Borrowed Successfully", message);
        }
    }
}