namespace E_Learning.Domain.Admin.Words.Dtos
{
    public class AdminWordListItemDto
    {
        public Guid WordId { get; set; }
        public Guid TopicId { get; set; }
        public string WordText { get; set; } = null!;
        public string Meaning { get; set; } = null!;
        public string? PartOfSpeech { get; set; }
        public string? Phonetic { get; set; }
        public string? DifficultyLevel { get; set; }
        public bool IsActive { get; set; }
    }
}
