using System.ComponentModel.DataAnnotations;

namespace E_Learning.Domain.Admin.Words.Dtos
{
    public class CreateWordRequest
    {
        [Required]
        [MaxLength(200)]
        public string WordText { get; set; } = null!;

        [Required]
        [MaxLength(500)]
        public string Meaning { get; set; } = null!;

        [MaxLength(1000)]
        public string? ExampleSentence { get; set; }

        [MaxLength(100)]
        public string? PartOfSpeech { get; set; }

        [MaxLength(100)]
        public string? Phonetic { get; set; }

        [MaxLength(500)]
        public string? AudioUrl { get; set; }

        [MaxLength(500)]
        public string? ImageUrl { get; set; }

        [MaxLength(50)]
        public string? DifficultyLevel { get; set; }

        public bool IsActive { get; set; } = true;
    }
}