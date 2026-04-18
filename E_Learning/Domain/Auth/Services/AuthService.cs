using E_Learning.Data;
using E_Learning.Domain.Auth.Configurations;
using E_Learning.Domain.Auth.Dtos;
using E_Learning.Domain.Auth.Interface;
using E_Learning.Entity;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace E_Learning.Domain.Auth.Services
{
    public class AuthService : IAuthService
    {
        private readonly AppDbContext _context;
        private readonly ITokenService _tokenService;
        private readonly AppSettings _appSettings;
        private readonly IHttpContextAccessor _httpContextAccessor;

        public AuthService(
        AppDbContext context,
        ITokenService tokenService,
        IOptions<AppSettings> appSettings,
        IHttpContextAccessor httpContextAccessor)
        {
            _context = context;
            _tokenService = tokenService;
            _appSettings = appSettings.Value;
            _httpContextAccessor = httpContextAccessor;
        }


        public async Task<AuthResponse> RegisterAsync(RegisterRequest request)
        {
            var userName = request.UserName.Trim();
            var email = request.Email.Trim().ToLower();

            var existedUserName = await _context.Users
                .AnyAsync(x => x.UserName.ToLower() == userName.ToLower());

            if (existedUserName)
                throw new Exception("Username already exists.");

            var existedEmail = await _context.Users
                .AnyAsync(x => x.Email.ToLower() == email);

            if (existedEmail)
                throw new Exception("Email already exists.");

            var defaultRole = await _context.Roles
                .FirstOrDefaultAsync(x => x.RoleName == "User");

            if (defaultRole == null)
                throw new Exception("Default role 'User' not found.");

            await using var transaction = await _context.Database.BeginTransactionAsync();

            var user = new User
            {
                UserName = userName,
                Email = email,
                PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
                IsActive = true,
                CreatedAt = DateTime.UtcNow
            };

            _context.Users.Add(user);
            await _context.SaveChangesAsync();

            var profile = new UserProfile
            {
                UserId = user.UserId,
                FullName = string.IsNullOrWhiteSpace(request.FullName) ? userName : request.FullName.Trim(),
                AvatarUrl = null,
                TargetDailyWords = 10,
                CreatedAt = DateTime.UtcNow
            };

            _context.UserProfiles.Add(profile);

            // Gán role qua navigation many-to-many
            user.Roles.Add(defaultRole);

            await _context.SaveChangesAsync();
            await transaction.CommitAsync();

            var roles = user.Roles.Select(r => r.RoleName).ToList();
            var (token, expiresAtUtc) = _tokenService.CreateToken(user, roles);

            return new AuthResponse
            {
                Token = token,
                ExpiresAtUtc = expiresAtUtc,
                UserId = user.UserId,
                UserName = user.UserName,
                Email = user.Email,
                Roles = roles,
                FullName = profile.FullName,
                AvatarUrl = ResolveAvatarUrl(profile.AvatarUrl),
                TargetDailyWords = profile.TargetDailyWords
            };
        }

        public async Task<AuthResponse> LoginAsync(LoginRequest request)
        {
            var key = request.UserNameOrEmail.Trim().ToLower();

            var user = await _context.Users
                .Include(u => u.Roles)
                .Include(u => u.UserProfile)
                .FirstOrDefaultAsync(x =>
                    x.UserName.ToLower() == key ||
                    x.Email.ToLower() == key);

            if (user == null)
                throw new Exception("Invalid username/email or password.");

            var passwordValid = BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash);
            if (!passwordValid)
                throw new Exception("Invalid username/email or password.");

            if (!user.IsActive)
                throw new Exception("Account is inactive.");

            var roles = user.Roles.Select(r => r.RoleName).ToList();

            var (token, expiresAtUtc) = _tokenService.CreateToken(user, roles);

            return new AuthResponse
            {
                Token = token,
                ExpiresAtUtc = expiresAtUtc,
                UserId = user.UserId,
                UserName = user.UserName,
                Email = user.Email,
                Roles = roles,
                FullName = user.UserProfile?.FullName,
                AvatarUrl = ResolveAvatarUrl(user.UserProfile?.AvatarUrl),
                TargetDailyWords = user.UserProfile?.TargetDailyWords ?? 10
            };
        }

        public async Task<CurrentUserResponse> GetMeAsync(Guid userId)
        {
            var user = await _context.Users
                .Include(u => u.Roles)
                .Include(u => u.UserProfile)
                .FirstOrDefaultAsync(x => x.UserId == userId);

            if (user == null)
                throw new Exception("User not found.");

            return new CurrentUserResponse
            {
                UserId = user.UserId,
                UserName = user.UserName,
                Email = user.Email,
                Roles = user.Roles.Select(r => r.RoleName).ToList(),
                FullName = user.UserProfile?.FullName,
                AvatarUrl = ResolveAvatarUrl(user.UserProfile?.AvatarUrl),
                TargetDailyWords = user.UserProfile?.TargetDailyWords ?? 10,
                IsActive = user.IsActive
            };
        }

        public async Task<CurrentUserResponse> UpdateProfileAsync(Guid userId, UpdateProfileRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(x => x.UserId == userId);

            if (user == null)
                throw new Exception("User not found.");

            var profile = await _context.UserProfiles
                .FirstOrDefaultAsync(x => x.UserId == userId);

            if (profile == null)
            {
                profile = new UserProfile
                {
                    UserId = userId,
                    FullName = request.FullName?.Trim(),
                    AvatarUrl = string.IsNullOrWhiteSpace(request.AvatarUrl)
                    ? null
                    : request.AvatarUrl.Trim(),
                    TargetDailyWords = request.TargetDailyWords ?? 10,
                    CreatedAt = DateTime.UtcNow
                };

                _context.UserProfiles.Add(profile);
            }
            else
            {
                if (request.FullName != null)
                    profile.FullName = request.FullName.Trim();

                if (request.AvatarUrl != null)
                    profile.AvatarUrl = string.IsNullOrWhiteSpace(request.AvatarUrl)
                        ? null
                        : request.AvatarUrl.Trim();

                if (request.TargetDailyWords.HasValue)
                    profile.TargetDailyWords = request.TargetDailyWords.Value;

                profile.UpdatedAt = DateTime.UtcNow;
            }

            user.UpdatedAt = DateTime.UtcNow;

            await _context.SaveChangesAsync();

            var roles = await _context.Users
                .Where(u => u.UserId == userId)
                .SelectMany(u => u.Roles.Select(r => r.RoleName))
                .ToListAsync();

            return new CurrentUserResponse
            {
                UserId = user.UserId,
                UserName = user.UserName,
                Email = user.Email,
                Roles = roles,
                FullName = profile.FullName,
                AvatarUrl = ResolveAvatarUrl(profile.AvatarUrl),
                TargetDailyWords = profile.TargetDailyWords,
                IsActive = user.IsActive
            };
        }

        private string ResolveAvatarUrl(string? avatarUrl)
        {
            var request = _httpContextAccessor.HttpContext?.Request;

            var rawValue = string.IsNullOrWhiteSpace(avatarUrl)
                ? _appSettings.DefaultAvatarUrl
                : avatarUrl.Trim();

            if (string.IsNullOrWhiteSpace(rawValue))
                return string.Empty;

            if (rawValue.StartsWith("http://", StringComparison.OrdinalIgnoreCase) ||
                rawValue.StartsWith("https://", StringComparison.OrdinalIgnoreCase))
            {
                return rawValue;
            }

            if (request == null)
                return rawValue;

            return $"{request.Scheme}://{request.Host}{rawValue}";
        }
        public async Task LogoutAsync(Guid userId)
        {
            // For JWT, logout is typically handled on the client side by deleting the token.
            // Optionally, you can implement token blacklisting here if needed.
            await Task.CompletedTask;
        }
    }
}