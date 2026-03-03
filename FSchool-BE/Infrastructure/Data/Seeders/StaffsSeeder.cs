using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Data.Seeders
{
    public class StaffsSeeder : ISeeder
    {
        private readonly ApplicationDbContext _context;
        private readonly ILogger<StaffsSeeder> _logger;

        public int Order => 3;

        public StaffsSeeder(
            ApplicationDbContext context,
            ILogger<StaffsSeeder> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task SeedAsync()
        {
            if (await _context.Staffs.AnyAsync())
            {
                _logger.LogInformation("Staffs already seeded, skipping...");
                return;
            }

            var staffAccount = await _context.Accounts
                .FirstOrDefaultAsync(a => a.PhoneNumber == "0900000002" && a.Role == "Staff");

            if (staffAccount == null)
            {
                _logger.LogWarning("Staff account not found, skipping staff seeding");
                return;
            }

            var staffs = new List<Staff>
        {
            new Staff
            {
                FullName = "Tran Thi B",
                EmployeeId = "EMP001",
                Department = "Information Technology",
                AccountId = staffAccount.Id
            }
        };

            await _context.Staffs.AddRangeAsync(staffs);
            await _context.SaveChangesAsync();

            _logger.LogInformation("Seeded {Count} staffs", staffs.Count);
        }
    }
}
