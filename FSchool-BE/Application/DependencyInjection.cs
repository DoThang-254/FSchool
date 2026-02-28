// BÍ KÍP: Dùng namespace này để Program.cs nhận diện tự động mà không cần using
namespace Microsoft.Extensions.DependencyInjection;

public static class DependencyInjection
{
    public static IServiceCollection AddApplicationServices(this IServiceCollection services)
    {
        services.AddAutoMapper(Assembly.GetExecutingAssembly());

        services.AddValidatorsFromAssembly(Assembly.GetExecutingAssembly());

        // 3. Đăng ký các Service xử lý logic của bạn
        // Lưu ý: Nếu bạn dùng CQRS (MediatR) như Jason Taylor thì dùng services.AddMediatR(...)
        // Nếu bạn dùng Service thuần túy thì viết như sau:
        // services.AddScoped<IStudentService, StudentService>();
        // services.AddScoped<IScheduleService, ScheduleService>();

        return services;
    }
}