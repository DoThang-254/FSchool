using BCrypt.Net;
using Domain.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace Infrastructure.Data.Seeders
{
    public class AccountsSeeder : ISeeder
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<AccountsSeeder> _logger;

        public int Order => 1;

        public AccountsSeeder(
            ApplicationDbContext context,
            ILogger<AccountsSeeder> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task SeedAsync()
        {
            if (await _context.Accounts.AnyAsync())
            {
                _logger.LogInformation("Accounts already seeded, skipping...");
                return;
            }

            var studentPassword = BCrypt.Net.BCrypt.HashPassword("123456");
            var staffPassword = BCrypt.Net.BCrypt.HashPassword("123456");

            var accounts = new List<Account>
            {
                new Account
                {
                    PhoneNumber = "0900000001",
                    PasswordHash = studentPassword,
                    Role = "Student"
                },
                new Account
                {
                    PhoneNumber = "0900000002",
                    PasswordHash = staffPassword,
                    Role = "Staff"
                }
            };

            await _context.Accounts.AddRangeAsync(accounts);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Seeded {Count} accounts", accounts.Count);
        }
    }
}