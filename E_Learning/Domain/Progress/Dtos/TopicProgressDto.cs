namespace E_Learning.Domain.Progress.Dtos
{
    public class TopicProgressDto
    {
        public Guid TopicId { get; set; }
        public string TopicName { get; set; } = string.Empty;

        public int TotalWords { get; set; }
        public int LearnedWords { get; set; }
        public int NotLearnedWords { get; set; }

        public int TotalCorrectCount { get; set; }
        public int TotalIncorrectCount { get; set; }

        public DateTime? LastStudiedAt { get; set; }
        public double CompletionRate { get; set; }
    }
}
