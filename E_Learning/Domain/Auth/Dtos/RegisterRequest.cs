using System.ComponentModel.DataAnnotations;

namespace E_Learning.Domain.Auth.Dtos
{
    public class RegisterRequest
    {
        [Required]
        [StringLength(100)]
        public string UserName { get; set; } = string.Empty;

        [Required]
        [EmailAddress]
        [StringLength(255)]
        public string Email { get; set; } = string.Empty;

        [Required]
        [MinLength(6)]
        public string Password { get; set; } = string.Empty;

        [StringLength(150)]
        public string? FullName { get; set; }
    }
}
