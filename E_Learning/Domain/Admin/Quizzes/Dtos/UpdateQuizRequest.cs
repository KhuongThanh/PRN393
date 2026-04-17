using System.ComponentModel.DataAnnotations;

namespace E_Learning.Domain.Admin.Quizzes.Dtos
{
    public class UpdateQuizRequest
    {
        [Required]
        [MaxLength(200)]
        public string QuizTitle { get; set; } = null!;

        [MaxLength(1000)]
        public string? Description { get; set; }

        [Range(1, 300)]
        public int? TimeLimitMinutes { get; set; }

        public bool IsActive { get; set; }
    }
}
