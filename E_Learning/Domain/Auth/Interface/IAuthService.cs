using E_Learning.Domain.Auth.Dtos;

namespace E_Learning.Domain.Auth.Interface
{
    public interface IAuthService
    {
        Task<AuthResponse> RegisterAsync(RegisterRequest request);
        Task<AuthResponse> LoginAsync(LoginRequest request);
        Task<CurrentUserResponse> GetMeAsync(Guid userId);
        Task<CurrentUserResponse> UpdateProfileAsync(Guid userId, UpdateProfileRequest request);
    }
}
