using E_Learning.Domain.Dashboard.Dtos;

namespace E_Learning.Domain.Dashboard.Interface
{
    public interface IDashboardService
    {
        Task<UserDashboardDto> GetUserDashboardAsync(Guid userId);
        Task<AdminDashboardDto> GetAdminDashboardAsync();
    }
}
