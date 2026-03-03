using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Data.Seeders
{
    public class StudentsSeeder : ISeeder
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<StudentsSeeder> _logger;

        public int Order => 2;

        public StudentsSeeder(
            ApplicationDbContext context,
            ILogger<StudentsSeeder> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task SeedAsync()
        {
            if (await _context.Students.AnyAsync())
            {
                _logger.LogInformation("Students already seeded, skipping...");
                return;
            }

            var studentAccount = await _context.Accounts
                .FirstOrDefaultAsync(a => a.PhoneNumber == "0900000001" && a.Role == "Student");

            if (studentAccount == null)
            {
                _logger.LogWarning("Student account not found, skipping student seeding");
                return;
            }

            var students = new List<Student>
        {
            new Student
            {
                FullName = "Nguyen Van A",
                RollNumber = "SE001",
                AvatarUrl = "https://example.com/avatar1.jpg",
                AccountId = studentAccount.Id
            }
        };

            await _context.Students.AddRangeAsync(students);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Seeded {Count} students", students.Count);
        }
    }
}
