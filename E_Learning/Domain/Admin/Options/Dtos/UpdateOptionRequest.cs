using System.ComponentModel.DataAnnotations;

namespace E_Learning.Domain.Admin.Options.Dtos
{
    public class UpdateOptionRequest
    {
        [Required]
        [MaxLength(300)]
        public string OptionText { get; set; } = null!;

        public bool IsCorrect { get; set; }

        [Range(0, int.MaxValue)]
        public int DisplayOrder { get; set; }
    }
}
