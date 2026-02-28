// using FSchool.Application.Interfaces;
// using FSchool.Infrastructure.Repositories;

namespace Microsoft.Extensions.DependencyInjection;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration configuration)
    {
        // 1. Đăng ký Database Context
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("MyCnn")));

        // 2. Đăng ký các Repositories
        // services.AddScoped<IStudentRepository, StudentRepository>();
        // services.AddScoped<IScheduleRepository, ScheduleRepository>();

        return services;
    }
}