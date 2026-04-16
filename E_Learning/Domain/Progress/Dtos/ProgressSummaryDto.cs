namespace E_Learning.Domain.Progress.Dtos
{
    public class ProgressSummaryDto
    {
        public int TotalWords { get; set; }
        public int LearnedWords { get; set; }
        public int NotLearnedWords { get; set; }
        public int TotalCorrectCount { get; set; }
        public int TotalIncorrectCount { get; set; }
        public DateTime? LastStudiedAt { get; set; }
        public double CompletionRate { get; set; }
    }
}
