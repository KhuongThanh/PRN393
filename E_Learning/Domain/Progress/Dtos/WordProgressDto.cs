namespace E_Learning.Domain.Progress.Dtos
{
    public class WordProgressDto
    {
        public Guid? ProgressId { get; set; }
        public Guid WordId { get; set; }
        public string WordText { get; set; } = string.Empty;
        public string Meaning { get; set; } = string.Empty;
        public Guid TopicId { get; set; }
        public string TopicName { get; set; } = string.Empty;

        public bool HasProgress { get; set; }
        public bool IsLearned { get; set; }
        public int CorrectCount { get; set; }
        public int IncorrectCount { get; set; }
        public DateTime? LastStudiedAt { get; set; }
    }
}
