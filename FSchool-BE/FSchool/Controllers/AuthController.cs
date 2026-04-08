using Microsoft.AspNetCore.Authorization;
using Application.DTOs.Auth;
using Application.Interfaces.Services;
using Infrastructure.Data;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace FSchool.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [AllowAnonymous]
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;
        private readonly ApplicationDbContext _context;

        public AuthController(IAuthService authService, ApplicationDbContext context)
        {
            _authService = authService;
            _context = context;
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
        {
            var response = await _authService.LoginAsync(request);
            return Ok(response);
        }

        [HttpPost("verify-2fa")]
        public async Task<IActionResult> Verify2fa([FromBody] Verify2faRequestDto request)
        {
            var response = await _authService.Verify2faAsync(request);
            return Ok(response);
        }

        [HttpPut("toggle-2fa")]
        public async Task<IActionResult> Toggle2fa([FromQuery] int accountId)
        {
            var account = await _context.Accounts.FindAsync(accountId);
            if (account == null) return NotFound("Account not found.");

            account.TwoFactorEnabled = !account.TwoFactorEnabled;
            await _context.SaveChangesAsync();

            return Ok(new
            {
                twoFactorEnabled = account.TwoFactorEnabled,
                message = account.TwoFactorEnabled
                    ? "Two-Factor Authentication has been ENABLED."
                    : "Two-Factor Authentication has been DISABLED."
            });
        }

        [HttpGet("2fa-status")]
        public async Task<IActionResult> Get2faStatus([FromQuery] int accountId)
        {
            var account = await _context.Accounts.FindAsync(accountId);
            if (account == null) return NotFound("Account not found.");

            return Ok(new { twoFactorEnabled = account.TwoFactorEnabled });
        }

        [HttpPost("send-otp")]
        public async Task<IActionResult> SendOtp([FromBody] SendOtpRequest request)
        {
            await _authService.SendOtpAsync(request.PhoneNumber);
            return Ok(new { message = "Mã OTP đã được gửi." });
        }

        [HttpPost("forgot-password/reset")]
        public async Task<IActionResult> ResetPassword([FromBody] VerifyOtpRequest request)
        {
            await _authService.ResetPasswordAsync(request);
            return Ok(new { message = "Đổi mật khẩu thành công." });
        }

        [HttpPost("logout")]
        public async Task<IActionResult> Logout()
        {
            await _authService.LogoutAsync();
            return Ok(new { message = "Đăng xuất thành công." });
        }

        [HttpPost("google")]
        public async Task<IActionResult> GoogleLogin([FromBody] GoogleLoginRequestDto request)
        {
            var response = await _authService.GoogleLoginAsync(request.IdToken);
            return Ok(response);
        }
    }
}
