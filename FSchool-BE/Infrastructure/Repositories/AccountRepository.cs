using Application.Interfaces.Repositories;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Infrastructure.Repositories
{
    public class AccountRepository : IAccountRepository
    {
        private readonly ApplicationDbContext _context;

        public AccountRepository(ApplicationDbContext context)
        {
            _context = context;
        }

        public async Task<Account?> GetByPhoneNumberAsync(string phonenumber)
        {
            return await _context.Accounts.FirstOrDefaultAsync(x => x.PhoneNumber == phonenumber);
        }
    }
}
