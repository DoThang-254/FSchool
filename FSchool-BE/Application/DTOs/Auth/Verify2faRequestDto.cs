namespace Application.DTOs.Auth
{
    public class Verify2faRequestDto
    {
        public string PhoneNumber { get; set; } = null!;
        public string OtpCode { get; set; } = null!;
    }
}
