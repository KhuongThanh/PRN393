namespace E_Learning.Domain.Auth.Dtos
{
    public class CurrentUserResponse
    {
        public Guid UserId { get; set; }
        public string UserName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public List<string> Roles { get; set; } = [];
        public string? FullName { get; set; }
        public string? AvatarUrl { get; set; }
        public int TargetDailyWords { get; set; }
        public bool IsActive { get; set; }
    }
}
