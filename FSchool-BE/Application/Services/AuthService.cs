using Application.DTOs.Auth;
using Application.Interfaces.Repositories;
using Application.Interfaces.Services;
using Domain.Exceptions;

namespace Application.Services
{
    public class AuthService : IAuthService
    {
        private readonly IAccountRepository _accountRepository;
        private readonly ITokenService _tokenService;

        public AuthService(IAccountRepository accountRepository, ITokenService tokenService)
        {
            _accountRepository = accountRepository;
            _tokenService = tokenService;
        }

        public async Task<AuthResponseDto> LoginAsync(LoginRequestDto request)
        {
            var account = await _accountRepository.GetByPhoneNumberAsync(request.Username);

           
            if (account == null || !BCrypt.Net.BCrypt.Verify(request.Password, account.PasswordHash))
            {
                throw new UnauthorizedException("Tài khoản hoặc mật khẩu không chính xác.");
            }

            var token = _tokenService.GenerateJwtToken(account);

            return new AuthResponseDto
            {
                AccessToken = token,
                Role = account.Role.ToString()
            };
        }
    }
}
