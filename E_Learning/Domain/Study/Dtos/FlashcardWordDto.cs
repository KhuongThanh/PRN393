namespace E_Learning.Domain.Study.Dtos
{
    public class FlashcardWordDto
    {
        public Guid WordId { get; set; }
        public string WordText { get; set; } = string.Empty;
        public string Meaning { get; set; } = string.Empty;
        public string? ExampleSentence { get; set; }
        public string? PartOfSpeech { get; set; }
        public string? Phonetic { get; set; }
        public string? AudioUrl { get; set; }
        public string? ImageUrl { get; set; }
        public string? DifficultyLevel { get; set; }
    }
}
