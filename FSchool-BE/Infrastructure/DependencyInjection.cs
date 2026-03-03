// using FSchool.Application.Interfaces;
// using FSchool.Infrastructure.Repositories;

using Application.Interfaces.Repositories;
using Application.Interfaces.Services;
using Infrastructure.Data.Seeders;
using Infrastructure.ExternalServices;
using Infrastructure.Repositories;

namespace Microsoft.Extensions.DependencyInjection;

public static class DependencyInjection
{
    public static IServiceCollection AddInfrastructureServices(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<ApplicationDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("MyCnn")));

        services.AddScoped<IAccountRepository, AccountRepository>();
        services.AddScoped<ITokenService, TokenService>();

        services.AddScoped<ISeeder, AccountsSeeder>();
        services.AddScoped<ISeeder, StudentsSeeder>();
        services.AddScoped<ISeeder, StaffsSeeder>();
        services.AddScoped<ApplicationDbContextInitialiser>();
        services.AddHostedService<DatabaseInitializerHostedService>();

        return services;
    }
}