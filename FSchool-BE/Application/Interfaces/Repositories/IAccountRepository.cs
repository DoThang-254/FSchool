using Domain.Entities;

namespace Application.Interfaces.Repositories
{
    public interface IAccountRepository
    {
        Task<Account?> GetByPhoneNumberAsync(string username);
    }
}
