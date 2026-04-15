using E_Learning.Entity;

namespace E_Learning.Domain.Auth.Interface
{
    public interface ITokenService
    {
        (string token, DateTime expiresAtUtc) CreateToken(User user, List<string> roles);

    }
}
