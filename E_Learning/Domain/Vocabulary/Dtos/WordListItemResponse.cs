namespace E_Learning.Domain.Vocabulary.Dtos
{
    public class WordListItemResponse
    {
        public Guid WordId { get; set; }
        public Guid TopicId { get; set; }
        public string WordText { get; set; } = string.Empty;
        public string Meaning { get; set; } = string.Empty;
        public string? PartOfSpeech { get; set; }
        public string? Phonetic { get; set; }
        public string? DifficultyLevel { get; set; }
    }
}
