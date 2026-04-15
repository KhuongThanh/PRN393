using System.ComponentModel.DataAnnotations;

namespace E_Learning.Domain.Auth.Dtos
{
    public class UpdateProfileRequest
    {
        [StringLength(150)]
        public string? FullName { get; set; }

        [StringLength(500)]
        public string? AvatarUrl { get; set; }

        [Range(1, 500)]
        public int? TargetDailyWords { get; set; }
    }
}
