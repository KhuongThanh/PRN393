using System.ComponentModel.DataAnnotations;

namespace E_Learning.Domain.Admin.Questions.Dtos
{
    public class UpdateQuestionRequest
    {
        public Guid? WordId { get; set; }

        [Required]
        [MaxLength(500)]
        public string QuestionText { get; set; } = null!;

        [MaxLength(500)]
        public string? Explanation { get; set; }

        [Range(0, int.MaxValue)]
        public int DisplayOrder { get; set; }
    }
}
